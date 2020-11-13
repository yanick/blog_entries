---
url: play-perl
format: markdown
created: 2013-02-10
tags:
    - Perl
    - Play Perl
---

# Playing with Play Perl

So, this morning I finally clicked on one of the tweets talking about that 
new [Play Perl](http://play-perl.org/) thingy. And then I squealed like a
little girl. A 
socially-oriented todo list for my projects is something I had at the back of
my head for the longest time -- I was pondering making viewable parts of my 
[Hiveminder](http://hiveminder.com) tasks, or creating a 
'yanick' GitHub project just to have the
issue tracker, but this is *much* better.

But, of course, any new shiny discovery comes with an equal amount of
tantalizing unshaved bovine pilosity. Any self-respecting social site must
have external widgets. Would it be easy to hack one for `Play Perl`? Thanks to
a very nice [API](https://github.com/berekuk/play-perl/blob/master/app/api.txt), 
the answer is '*oh yes*':

```perl
#!/usr/bin/env perl 

    use 5.10.0;

    use strict;
    use warnings;

    use LWP::Simple qw/ get /;
    use JSON::XS;
    use XML::Writer;

    my $username = 'yanick';

    my $quests = decode_json get "http://play-perl.org/api/quest?user=$username" ;
    my $user = decode_json get "http://play-perl.org/api/user/$username";

    my @open_quests = reverse 
        sort { @{$a->{likes}||[]} <=> @{$b->{likes}||[]} }
        grep { $_->{status} eq 'open' } 
            @$quests;

    my $w = XML::Writer->new(OUTPUT => \my $output);

    $w->startTag('div');
    $w->startTag('h1');
    $w->dataElement( 
        'a' => ($user->{twitter} ? $user->{twitter}{screen_name} :
            $user->{login}),
        href => "http://play-perl.org/player/$username",
    );
    $w->endTag;
    $w->dataElement( 'div', 'score: ' . $user->{points} );
    $w->dataElement( 'h2' => 'three most upvoted quests' );
    $w->startTag('ul');
    for( @open_quests[0..2] ) {
        $w->startTag('li');
        $w->dataElement( a => $_->{name},
                href => "http://play-perl.org/quest/" . $_->{_id},
                'data-nbr-likes' => $_->{likes} ? scalar @{$_->{likes}} : 0 );
        $w->endTag;
    }
    $w->endTag;
    $w->endTag;

    print $output;
```

Admittedly, it could be more interesting to write the widget straight in
JavaScript so that no server-side work is required.  And while for the first draft I 
did use [XML::Writer](cpan), because it is a heck of a dependable
workhorse, the same logic can of course easily be translated to any
templating system.  With the latter in mind, I had to see what it would like using
`Template::Caribou`, my nascent pet-template project: 

```perl
package Web::Widget::PlayPerl;

    use LWP::Simple qw/ get /;
    use JSON::XS;
    use Method::Signatures;

    use Moose;
    use Template::Caribou;
    use Template::Caribou::Tags::HTML qw/ :all /,
        ;
    use Template::Caribou::Tags::HTML::Extended qw/ anchor /;
    use Template::Caribou::Tags
        mytag => { -as => 'widget',     class => 'widget play-perl' },
        mytag => { -as => 'div_quests', class => 'quests' },
        mytag => { -as => 'div_score',  class => 'score' };

    with 'Template::Caribou';

    has username => (
        is => 'ro',
        isa => 'Str',
        required => 1,
    );

    has nbr_quests_to_show => (
        is => 'ro',
        isa => 'Int',
        default => 3,
    );

    has user_data => (
        is => 'ro',
        isa => 'HashRef',
        lazy => 1,
        default => method {
            decode_json get 'http://play-perl.org/api/user/' . $self->username;
        },
    );

    has open_quests => (
        is => 'ro',
        traits => [ 'Array' ],
        isa => 'ArrayRef',
        lazy => 1,
        default => method {
            my $quests = decode_json get
            'http://play-perl.org/api/quest?status=open;user='.$self->username;

            $_->{likes} ||= [] for @$quests;

            return [
                reverse 
                sort { @{$a->{likes}||[]} <=> @{$b->{likes}||[]} }
                @$quests
            ];
        },
        handles => {
            shift_open_quests => 'shift',
            all_open_quests => 'elements',
        },
    );

    method user_url      { "http://play-perl.org/player/" . $self->username }
    method quest_url($q) { "http://play-perl.org/quest/" . $q->{_id} }

    template widget => method {
        widget { 
        h1 { 
            anchor $self->user_url => $self->username  . " at PlayPerl";
        }; 
        div_score { $self->user_data->{points} || '0'; };
        show('quests');
        };
    };

    template quests => method {
        div_quests {
        h2 { 'top quests' };
        ul {
           for ( grep { $_ }
               ($self->all_open_quests)[0..$self->nbr_quests_to_show] ) {
                li { attr 'data-nbr-likes' => scalar @{ $_->{likes} };
                    anchor $self->quest_url($_) => $_->{name};
                } 
            }
        }
    };

    1;
```


I'll just leave it there as-is, as a teaser for another, upcoming blog entry. 
But, as you can see, it does produce a nice base for our desired widget. A
little bit of CSS here and there, and we should be ready to go:

```bash
$ perl -MWeb::Widget::PlayPerl \
    -E'say Web::Widget::PlayPerl->new( username => "yanick" )->render("widget")'

    <div class="widget play-perl">
    <h1>
        <a href="http://play-perl.org/player/yanick">yanick at
        PlayPerl</a>
    </h1>
    <div class="score">0</div>
    <div class="quests">
        <h2>top quests</h2>
        <ul>
        <li data-nbr-likes="1">
            <a href="http://play-perl.org/quest/5117cbd7db9ca78259000048">
            Create a PlayPerl widget to put on my blog.</a>
        </li>
        <li data-nbr-likes="1">
            <a href="http://play-perl.org/quest/5117c3c7db9ca78359000031">
            Release Galuga 2, based on Dancer.</a>
        </li>
        <li data-nbr-likes="0">
            <a href="http://play-perl.org/quest/5117c3b7db9ca7825900003e">
            Have a totally self-indulgent blog entry about Caribou and
            its merits.</a>
        </li>
        </ul>
    </div>
    </div>

```
