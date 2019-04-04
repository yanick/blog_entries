---
created: 2017-10-22
tags:
  - git
  - dist-zilla
---

# git-mailmap

One of the many [Dist-Zilla](cpan:Dist-Zilla)
plugins that I use is 
[Dist::Zilla::Plugin::Git:Contributors](cpan:Dist::Zilla::Plugin::Git:Contributors).
It peruses the project's commits and automatically draw the
list of contributors, which is then 
added to the `META.*` files. And turned into the
file `CONTRIBUTORS` if you use
[Dist::Zilla::Plugin::ContributorsFile](cpan:Dist::Zilla::Plugin::ContributorsFile)
as well.

But of course, sometimes a contributor will push commits
from different machines, and they can thus appear under
several names/email combos. For example, 
if we look at the contributors of the `PPIx::EditorTools`
repo, we have:

```
$ git shortlog -sne
    51  Gabor Szabo <gabor@szabgab.com>
    20  Ahmad M. Zawawi <ahmad.zawawi@gmail.com>
    16  Yanick Champoux <yanick@cpan.org>
     5  Kevin Dawson <kevin@dawson10.plus.com>
     4  Adam Kennedy <adamk@cpan.org>
     4  Mark Grimes <mgrimes@cpan.org>
     4  Ryan Niebur <rsn@cpan.org>
     3  Steffen Mueller <smueller@cpan.org>
     3  kevindawson <bowtie@cpan.org>
     2  Sebastian Willing <sewi@cpan.org>
     2  Zeno Gantner <zeno.gantner@gmail.com>
     1  Florian Schlichting <fschlich@zedat.fu-berlin.de>
     1  bowtie <bowtie@cpan.org>
```

As we can see, Kevin Dawson is there a few times. It'd be
nice to aggregate his different incarnations under 
a single entity.

Fortunately, we can. Easily too! Git has this concept of
a `.mailmap` file that can maps author names/emails to
canonical values (see the [git
shortlog](https://git-scm.com/docs/git-shortlog) documentation
for all the details).

It's easy. But... it's also work. Wouldn't it be better
if there was a tool to help us populate the `.mailmap`?

... as you might surmise, as of a few hours ago there is one:

<asciinema-player src="/entry/git-mailmap/files/git-mailmap.json" />

The video showcases pretty much all the action the
script does. It'll list the contributors of the current
branch (with purty colors), and allow for a few actions:

* `/regex` filters the authors with the given regular expression.
* `a Somebody <blah@blah.com>` adds a new author entry (for when the canonical entry is not present)
* A list of indexes take the first index to be the canonical
address, and the other ones as the aliases. An asterisk, like in the video, can be used to say "all the selected authors".
* `q` means `quit`, natch. 

If you want me to shut up and just take your money,
the script can be found [on GitHub](https://github.com/yanick/environment/blob/master/bin/git-mailmap).

If you want to know how it looks, soldier on.

## How It's Done

As usual, I leverage the heck of CPAN
to do the minimal amount of work.

First, I use [MooseX::App::Simple](cpan:MooseX::App::Simple)
to take care of the clitudicity of the thing:

```perl
use 5.20.0;
use warnings;

use MooseX::App::Simple;

parameter regex => (
    is      => 'rw',
    default => '',
);

# ... more stuff will go here ...


__PACKAGE__->new_with_options->run;

```

Then to walk the logs, I reach out for
[Git::Wrapper](cpan:Git::Wrapper).

```perl
use Git::Wrapper;
use List::AllUtils qw/ uniq /;

has authors => (
    is => 'rw',
    traits => [ 'Array' ],
    default => sub { [
        uniq( Git::Wrapper->new('.')
            ->RUN( 'log', { pretty => '%aN <%aE>' } ) )
    ] },
    handles => {
        all_authors  => 'sort',
        grep_authors => 'grep',
        add_author   => 'push',
    },
);

sub selected_authors {
    my $self = shift;

    my $regex = $self->regex or return $self->all_authors;

    return $self->grep_authors(sub { /$regex/i });
}
```


We'll only append to `.mailmap`, so we could just use
`open`. But I like [Path::Tiny](cpan:Path::Tiny), and it looks nicer:

```perl
use Path::Tiny;

sub set_aliases {
    my ( $self, $line ) = @_;

    my @authors = $self->selected_authors;

    my( $real, @clones ) = 
        uniq map { $_ eq '*' ? @authors : $authors[$_] }
                split /,|\s+/;

    path( '.mailmap' )->append( map { "$real $_\n" } @clones );

    $self->authors(
        [ $self->grep_authors(sub{ not $_ ~~ @clones } ) ]
    );
}
```

Saw how we have pretty colors? That's all
[Term::ANSIColor](cpan:Term::ANSIColor)'s fault:

```perl
use Term::ANSIColor qw/ colored /;

sub print_authors {
    my $self = shift;
    my @authors = $self->selected_authors;

    my $length = length scalar @authors;
    my $i = 0;

    printf colored( ['Blue'], '%'.$length."d" ) 
            . ". %-20s "
            . colored( [ 'Green' ], '%s' )."\n", 
            $i++, split /(?=<)/, $_ 
        for @authors;
}
```

Finally, for the interaction, I went 
for [IO::Prompt::Simple](cpan:IO::Prompt::Simple):

```perl
use IO::Prompt::Simple;
use experimental 'smartmatch';

sub run {
    my $self = shift;

    while() {

        $self->print_authors;

        given ( prompt "[@{[ $self->regex ]}]" ) {

            $self->regex($1)       when m#^/(.*)#; 

            $self->add_author($1)  when /^a +(.*)/;

            $self->set_aliases($_) when /^\d/;

            return                 when /^q/;
        }
    }
}
```

And there we go. A tool with help menu, colors,
interaction, git perusing and file munging in 116 lines
or so.

Not bad, heh?

