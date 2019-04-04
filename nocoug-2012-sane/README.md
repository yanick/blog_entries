---
url: nocoug-2012-sane
format: markdown
created: 2012-06-11
tags:
    - Perl
    - NoCOUG
    - contest
---

# NoCOUG contest: a gentler, saner solution

[Last time][previously], I produced my traditional golfed solution for
the [annual NoCOUG contest][challenge]. As I mentioned at the end,
the actual challenge calls for a more generic solution than
originally described in the magazine.  Because there is no glory in
half-solving a problem, I had to come back to it. And because the Great Karmic
Balance could probably use it, I thought I could take advance of the broader 
scope to produces a solution more geared toward elegance and modernism.

And if you *tl;dr*ed the NoCOUG magazine, here's the skinny on the puzzle
at hand: there's a party being planned, and the planner tries to figure out
the smallest set of persons to invite, knowing that if certains persons show
up at the event, others will automatically follow.  There are only positive
dependencies (no-one is going to snob the event if another person attends),
and some of the dependencies involve many persons (e.g., Albus will only
attend if both Carlotta and Falco are there). And that's pretty much. Oh, and
everybody's a wizard, because everything's better with men in dresses and
silly hat.

## Sketching out what we want

As we are striving for something saner and easier to maintain, 
for this round we'll steer away from a script and rather implement 
the solver as a *PartyResolver* object. The object will take only one input:
the list of dependencies.  Which will take the form of 

    #syntax: perl
    $dependencies = [
        # will come              # if are present
        [ qw/ Albus Daisy / ] => [ qw/ Carlotta Falco / ],
        'Falco'               => [ qw/ Albus Carlotta / ],
        Elfrida               => 'Falco',
    ];

Basically, a list of *A* will come if *B* attend, where *A* and *B* can be
either a single person or a bunch of them.

## Picking up the right tools

Picking up the right tools often makes the difference between minimal pain
and no pain at all.  In the golfed solution, I used arrays to represent the
different groups, and bit-masks to capture who's coming to the party and who's
not. Clever, but we can do with less obscure by using [Set::Object](cpan), which
does exactly what we want: represent a set of things with all the utility
methods to insert new elements, test for inclusion, etc.  And, pleasantly
enough, according to the benchmarks given in the module's documentation, we'll
get all that along very respectable performances.

Likewise, where I was going full brute-force on the possible combinations of 
guests in the previous solution, we'll use
[Algorithm::Combinatorics](cpan), which
abstract all that hard mathematical stuff so that we don't have to worry about
it.

With that, we should be good. Time to roll up our sleeves and start coding.

## The *PartyResolver* class

First things first: we declare our package and import our tools:

    #syntax: perl
    package PartyResolver;

    use 5.10.0;

    use strict;
    use warnings;

    use Moose;
    use Method::Signatures;

    use Set::Object;
    use Algorithm::Combinatorics qw/ subsets /;

    use List::MoreUtils qw/ uniq first_index /;
    use List::Util qw/ min /;

Now, I don't know about you, but I never, ever remember what is in
[List::Util](cpan) and what is in [List::MoreUtils](cpan). Next
project, I think I'll start using [List::AllUtils](cpan) and be done with
it (or, even better, write a patch such that `List::MoreUtils` is smart enough
to passthrough the functions that are coming from `List::Util`). 

Anyway, next step is to define the class's attributes. As mentioned, we want
the list of dependencies:


    #syntax: perl
    has dependencies => (
        traits   => [qw/ Array /],
        is       => 'ro',
        required => 1,
        isa      => 'ArrayRef[Str|ArrayRef]',
        handles  => { all_deps => 'elements', },
    );

We'll also need the complete list of guests, which we can be cute and
interpolate from the dependencies:

    #syntax: perl
    sub flatten ($) { ref $_[0] ? @{$_[0]} : $_[0] }

    has guests => (
        is      => 'ro',
        lazy    => 1,
        isa     => 'Set::Object',
        default => method {
            return Set::Object->new( map { flatten $_ } $self->all_deps );
        },
        handles => {
            'nbr_guests' => 'size',
            'all_guests' => 'members',
        },
    );

Attribute-wise, that's it. Now, for the methods, let's implement the main 
one, `seeders_to_invite()`, which will try bigger and bigger seeder groups
until it gets solutions that results in everybody ending up at the party:

    
    #syntax: perl
    method seeders_to_invite {
        for my $group_size ( 1 .. $self->nbr_guests ) {
            my @solutions =
                grep   { $self->makes_full_house($_) }
                map    { Set::Object->new(@$_) }
                subsets( [ $self->all_guests ], $group_size );

            return @solutions if @solutions;
        }
    }

And, finally, we need `makes_full_house()`, a test method that takes in a
seeder group of guests, and figure out if it'll result in a full house:


    #syntax: perl
    method makes_full_house($group) {
        # we want a copy, not the original
        $group = Set::Object->new( $group->members );

        my $last_size = 0;
        my @deps      = $self->all_deps;

        while (1) {
            # everybody's in, success!
            return 1 if $group->size == $self->nbr_guests;

            for ( 0 .. $#deps / 2 ) {
                my @who  = flatten $deps[ 2 * $_ ];
                my @deps = flatten $deps[ 2 * $_ + 1];

                $group->insert(@who) if $group->contains(@deps);
            }

            # the group has reached its stable state
            return 0 if $last_size == $group->size;

            $last_size = $group->size;
        }
    }

And that's it. We're one

    
    #syntax: perl
    __PACKAGE__->meta->make_immutable;
    1;


away of being done.

## Put that horse to work

Now that we have our little `PartyResolver` class implemented, solving all
scenarios only become a question of turning the handle:


    #syntax: perl
    my @datasets = ( [
            [qw/ Burdock Carlotta/]      => 'Albus',
            [qw/Albus Daisy/]            => 'Carlotta',
            [qw/Albus Burdock Carlotta/] => 'Elfrida',
            [qw/Carlotta Daisy/]         => 'Falco',
            [qw/Burdock Elfrida Falco/]  => [qw/ Carlotta Daisy/],
            'Daisy'                      => [qw/ Albus Burdock /],
        ],
        [   'Carlotta' => [qw/ Albus Burdock /],
            Falco      => [qw/ Daisy Elfrida /],
        ],
        [   'Carlotta'            => [qw/ Albus Burdock /],
            Falco                 => [qw/ Daisy Elfrida /],
            [qw/ Carlotta Falco/] => [qw/ Albus Burdock Daisy Elfrida /],
        ],
        [   Burdock  => 'Albus',
            Carlotta => 'Burdock',
            Carlotta => 'Albus',
            Elfrida  => 'Daisy',
            Falco    => 'Elfrida',
            Falco    => 'Daisy',
        ],
        [   Burdock                => 'Albus',
            Carlotta               => 'Burdock',
            Carlotta               => 'Albus',
            Elfrida                => 'Carlotta',
            Falco                  => 'Elfrida',
            Falco                  => 'Daisy',
            [qw/ Carlotta Falco /] => [qw/ Albus Burdock Daisy Elfrida /],
        ],
        [   Burdock  => 'Albus',
            Carlotta => 'Burdock',
            Carlotta => 'Albus',
            Elfrida  => 'Daisy',
            Falco    => 'Elfrida',
            Falco    => 'Daisy',
            Carlotta => 'Burdock',
            Albus    => 'Carlotta',
            Albus    => 'Burdock',
            Falco    => 'Elfrida',
            Daisy    => 'Falco',
            Daisy    => 'Elfrida',
        ],
        [   Albus => [qw/ Burdock Carlotta Daisy /],
            Albus => [qw/ Carlotta Daisy Elfrida /],
            Albus => [qw/ Daisy Elfrida Falco /],
        ],
        [   [qw/ Burdock Carlotta Daisy Elfrida Falco /] => 'Albus',
            Albus => [qw/ Burdock Carlotta Daisy Elfrida Falco /],
        ],
    );

    for (@datasets) {
        state $dataset_nbr = 1;

        say "\nProblem ", $dataset_nbr++;

        say join " ", sort $_->members
        for PartyResolver->new( dependencies => $_ )->seeders_to_invite;

        say '*' x 60;
    }

Which, indeed, returns the values we want:

    #syntax: bash
    $ perl party_solver.pl

    Problem 1
    Falco
    Carlotta
    Elfrida
    Albus
    ************************************************************

    Problem 2
    Albus Burdock Daisy Elfrida
    ************************************************************

    Problem 3
    Albus Burdock Daisy Elfrida
    ************************************************************

    Problem 4
    Albus Daisy
    ************************************************************

    Problem 5
    Albus Daisy
    ************************************************************

    Problem 6
    Burdock Falco
    Burdock Daisy
    Burdock Elfrida
    Carlotta Falco
    Albus Falco
    Carlotta Daisy
    Albus Daisy
    Carlotta Elfrida
    Albus Elfrida
    ************************************************************

    Problem 7
    Burdock Carlotta Daisy Elfrida Falco
    ************************************************************

    Problem 8
    Albus
    ************************************************************


Tadah! 

The complete program is also [here](__ENTRY_DIR__/party_solver.pl), 
if you want to play with it.


[previously]:  http://www.pythian.com/news/33537/nocoug-contest-the-perl-dark-horse-entry/
[challenge]: http://bitly.com/JvJS46


