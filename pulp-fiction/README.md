---
title: Pulp Fiction
url: pulp-fiction
format: markdown
created: 26 June 2015
tags:
    - Perl
    - Pulp
---

So, these days, I'm having fun splashing in the JavaScript pool. And in the
course of duty I've looked at its popular build systems [Grunt](http://gruntjs.com/) and
[Gulp](http://gulpjs.com/).  They're not bad, and the streaming paradigm of
`Gulp` is rather attractive. But...  it irks me to no end that in JavaScript an anonymous function is 

```javascript
var myfunc = function(blah){ ... }
```

whereas in (signatures-using) 
Perl it's

```perl
my $myfunc = sub(blah){ ... };
```

I mean, `function` is a full 5 characters longer than `sub`. That's madness.
Of course there is CoffeeScript and its ilk, not to mention
the `() => ` of the looming EcmasScript 6. But that's only reasonable
arguments, and I won't let them distract me. Moreover considering I've also been
looking for a reason, any reason, to play with promises and futures.

So, take that, plus the fact that a big, fat pun was begging to be made into a
project, and you understand, that I had no choice, no choice at *all*, but
to create a kind-of Perl port of Gulp, called Pulp.

*Public Service Announcement:* Reading the lasts few entries of this blog
might give you the false impression that writing your own frameworks is cool.
It is not. Cool kids learn already existing tools and leverage them.
Reinventing the wheel only lead to insanity, collapse of one's sense of
right and wrong, and chronic facepalming. Don't do it, mmmmm'kay?

This being said, lemme show you the awesome, cool stuff I've been tinkering
with!

## Building on the most solid of foundations: bad puns

Once I decided to go with `Pulp` as a project name, I decided to go full hog
on the publishing metaphor. The virtual documents being worked upon would be 
`folios`, the building rules would be `proofs`, and the
different actions within those proof stages would satisfy the roles of typists
(introduce new folios), editors (modify folios), binders (aggregate folios
together) and publishers (print out the folios to disk). Compiling the proofs
will be known as 'typesetting', and running them would be 'pressing'. And a
module implementing a bunch of proofs would be a Pulp 'fiction'. Obviously.

For the more, ah, technical foundations of this project, I decided to give a
whirl to [Future](cpan:release/Future). For the moment it's a little overkill
as there is not any parallel work being done. But the groundwork has been
done to allow the use of threads or
[Parallel::ForkManager](cpan:release/Parallel-ForkManager) if (well, okay,
when) I decide the whole thing is looking too sane.

## O sweet Lord. That's terrifying, but I can't look away

Good. For it's time for an example.

Let's say we have a website with a few html pages and
[LESS](http://lesscss.org/) stylesheets. We'd like to convert the less
files into css, aggregate them into a single `style.css` file, and then 
change all the html files such that they have a `link` tag pointing to that
stylesheet.

A possible Pulp fiction that could do that is

```perl
package PoC;

use 5.20.0;

use strict;
use warnings;

use Pulp;
use MooseX::Types::Path::Tiny qw/Path/;

use Pulp::Actions qw/ Src Rename Dest Less WebQuery Concat /;

use experimental 'signatures';

has dest_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => sub {
        Path::Tiny->tempdir;
    },
);

has src_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => 't/corpus/poc',
);

has css_file => (
    isa     => 'Str',
    is      => 'ro',
    default => 'style.css',
);

proof default => sub ($pulp) {
    my $src = quotemeta $pulp->src_dir;
    my $css = $pulp->css_file;

    pulp_src( $pulp->src_dir . '/*' )
    => pulp_rename( sub { s#^$src/## } )
    => {
       qr/\.less$/ => sub{ 
          pulp_less() => pulp_concat($pulp->css_file) 
       },
       qr/\.html$/ => pulp_webquery( sub {
            $_->find('head')->append(
                "&lt;link href='$css' rel='stylesheet' type='text/css'>"
            )
        }),
    }
    => pulp_dest( $pulp->dest_dir );
};

1;
```

And then to run it:

```bash
$ perl -It/lib -MPoC -e'PoC->new->press("default")'
```

Now, I'm sure that everybody who hadn't run for the hills yet are asking
themselves "golly. What just happened?". Let's go through the fiction part by
part.

First, the regular declaration of regular dependencies.

```perl
package PoC;

use 5.20.0;

use strict;
use warnings;

```

Then the use of `Pulp` (which drags Moose in the game), and the declaration of
the different actions we'll be using.

```perl
use Pulp;
use MooseX::Types::Path::Tiny qw/Path/;

use Pulp::Actions qw/ Src Rename Dest Less WebQuery Concat /;

use experimental 'signatures';
```

Since our module is a Moose class, why not be fancy and declare the constants
we'll use -- the source and destination directories, as well as the 
name of the aggregate css file -- as attributes?

```perl
has dest_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => sub { Path::Tiny->tempdir; },
);

has src_dir => (
    is      => 'ro',
    isa     => Path,
    coerce  => 1,
    default => 't/corpus/poc',
);

has css_file => (
    isa     => 'Str',
    is      => 'ro',
    default => 'style.css',
);

```

Now begins the fun stuff. We define the proof *default*

```perl
proof default => sub ($pulp) {
    my $src = quotemeta $pulp->src_dir;
    my $css = $pulp->css_file;

```

First thing the proof should do is to read the source files from disk. That's
a job for the action `Pulp::Action::Src` that we imported via `Pulp::Actions`. 
Secretly, actions are all objects, but they are wrapped in cute little
functions called `pulp_*` to make them easy to write. 

So, anyway, we want to
slurp in all files from the source directory

```perl
    pulp_src( $pulp->src_dir . '/*' )
```

then we want to chop the source directory from the file names

```perl
    => pulp_rename( sub { s#^$src/## } )
```

After that, we want to treat the style and html files differently. Which is
fine, because Pulp proofs have a few flow constructs we can use. In a
nutshell:

* A simple list of actions will act of the folios sequentially.

```perl
    pulp_src(...) => pulp_renamed(...) => pulp_dest(...)
```

In this example, files are read, renamed, and then written back to disk.

* A code ref will be passed the Pulp object, and is expected to return a list
of actions. 

```perl
    pulp_src(...) 
        => sub { my $new_name = $_[0]->css_file; pulp_rename( s/.*/$new_name/) }
        => pulp_dest( ... );
```

The example follows the same logic than the previous one, but we use a sub for
the renaming part to be able to get the new name from the Pulp object.

* An array ref gives different sub-chains of actions that can be done in
parallel.

```perl
    pulp_src(...) 
        => sub { my $new_name = $_[0]->css_file; pulp_rename( s/.*/$new_name/) }
        => [
            [ pulp_something( .. )      => pulp_dest('dest_1') ],
            [ pulp_something_else( .. ) => pulp_dest('dest_2') ],
        ]
```

The two chains will be given the same list of folios. And yes, this is where
things will get magic once we'll have some asynchronousity  throws in.

* A hash ref is like an array ref, but filter the folios based on their
filenames.

```perl
    pulp_src(...) 
        => {
            qr/\.html$/ => sub { ... },
            qr/\.css$/  => sub { ... },
        }
        => pulp_dest(...);
```

* All of those can be mix and matched for extra giggles.

Think about the possibilities. Try not to scream too loudly, not to wake up
the neighbors.

So, all of that to say that for css files, we want to use `Pulp::Action::Less`
which convert less files into css, and then aggregate them all in the file
`style.css`:

```perl
          pulp_less() => pulp_concat($pulp->css_file) 
```

And for the html files, we just want to all the `link` tag with the pertinent:

```perl
       pulp_webquery( sub {
            $_->find('head')->append(
                "&lt;link href='$css' rel='stylesheet' type='text/css'>"
            )
       })
``

And now those two chains, put together within the hash ref:

```perl
    {
       qr/\.less$/ => sub{ 
          pulp_less() => pulp_concat($pulp->css_file) 
       },
       qr/\.html$/ => pulp_webquery( sub {
            $_->find('head')->append(
                "&lt;link href='$css' rel='stylesheet' type='text/css'>"
            )
        }),
    }
```

Finally, we want to take all the folios we have crafted, and dump'em in their
final destination:

```perl
    => pulp_dest( $pulp->dest_dir );
```

And that's it, we're done.
 
## Gritty action

While the core of Pulp uses futures to bounce the folios from one action to
the next, it's all pretty nicely encapsulated such that for any given action
implementation only see the folios.

### Typists, harbingers of chaos

An action that introduce new folios consumes the `Pulp::Role::Action::Typist`
role and must implement `insert()`, which returns a bunch of folios. For example:

```perl
package Pulp::Action::Src;

use strict;
use warnings;

use Moose;

use Pulp::Folio;

use Path::Tiny;
use List::AllUtils qw/ uniq /;

sub pulp_new {
    my( $class, @args ) = @_;
    if( @args and ref $args[-1] eq 'HASH' ) {
        my $options = pop @args;
        $options->{sources} = \@args;
        @args = %$options;
    }
    else { 
        @args = ( 'sources', [ @args ] );
    }
    __PACKAGE__->new( @args );
}

has sources => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => [ qw/ Array / ],
    default => sub { [] },
    lazy    => 1,
    handles => {
        'all_sources' => 'elements',
    },
);

has root_dirs => (
    is      => 'ro',
    isa     => 'ArrayRef',
    traits  => [ qw/ Array / ],
    default => sub { [ '.' ] },
    lazy    => 1,
    handles => {
        'all_root_dirs' => 'elements',
    },
);

sub insert {
    my $self = shift;

    my %files;

    for my $dir ( $self->all_root_dirs ) {
        path($dir)->visit(sub{
            return unless $_->is_file;
            $files{ $_->relative($dir) } ||= $_->absolute;
            return;
        },{ recurse => 1 });
    }

    my @selected;

    for my $source ( $self->all_sources ) {
        log_info { "processing " . $source };
        my $re = $self->path_to_regex($source);
        push @selected, grep { /$re/ } keys %files;
    }

    return map { Pulp::Folio->new(
        original_filename => $files{$_},
        filename => $_,
    )} log_info { join ' ', "collected: ", @_ } uniq @selected;
}

sub path_to_regex {
    my( $self, $path ) = @_;

    $path = '^' . quotemeta($path) . '$';

    $path =~ s#\\\*\\\*#.*(?=/|\$)#g;
    $path =~ s#\\\*#[^/]*#g;

    return $path;
}

with 'Pulp::Role::Action::Typist';

1;
```

... Okay, that was a rather big example. The others are going to be shorter, I
swear.

### Editors, eldritch transmuters of text

Likewise, an action that modify a folio, either content or name, consumes
`Pulp::Role::Action::Editor`, and implements an `edit()` method. 
For example:

```perl
package Pulp::Action::Less;

use 5.10.0;

use strict;
use warnings;

use Moose;
use CSS::LESS;
use PerlX::Maybe;

with 'Pulp::Role::Action::Editor';

has "include_paths" => (
    is => 'ro',
);

has "engine" => (
    is      => 'ro',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return CSS::LESS->new(
            maybe include_paths => $self->include_paths
        );
    },
);

sub edit {
    my( $self, $folio ) = @_;

    $folio->content( join '', $self->engine->compile( $folio->content ) );
    $folio->filename( $folio->filename =~ s/\.less/\.css/r );

    return $folio;
}

1;
```

See? Toldya it was going to be shorter.

### Binders, coalescers of doom

Binders could have been editors, but for the fact that editors are optimized 
to be per-folio such that each folio can, potentially, zip along its workflow
without having to wait for its slowpoke siblings. So there you have it. Yadah
yadah, consumes `Pulp::Role::Action::Binder`, yadah, must implement
`coalesce`. E.g.:


```perl
package Pulp::Action::Concat;

use 5.10.0;

use strict;
use warnings;

use Moose;
with 'Pulp::Role::Action::Binder';

has filename => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

sub pulp_new {
    my( $class, @args ) = @_;

    return __PACKAGE__->new(filename => @args);
}


sub coalesce {
    my( $self, @folios ) = @_;

    Pulp::Folio->new(
        filename => $self->filename,
        content => join '', map { $_->content } @folios
    );
}

1;
```

### Publishers, spouts of madness

Last but not least (or less -- that was two sections ago),
the publishers. Consume `Pulp::Role::Action::Publisher`, requires `publish`.
E.g.:

```perl
package Pulp::Action::Dest;

use strict;
use warnings;

use Moose;

use Pulp::Folio;

use Path::Tiny;

has dest_dir => (
    is => 'ro',
);

sub pulp_new {
    my( $class, @args ) = @_;
    unshift @args, 'dest_dir' if @args == 1;
    __PACKAGE__->new( @args );
}

sub publish {
    my( $self, $folio ) = @_;
    $folio->filename( path($self->dest_dir)->child($folio->filename)->stringify );
    $folio->write;
    log_info { "writing " . $folio->filename };
}

with 'Pulp::Role::Action::Publisher';

1;
```

## To be continued...

Masterpiece? Incoherent babbling of a madman? I'll let future generations
decide. For the moment, I'll just point out that the project is, as usual,
[on GitHub](https://github.com/yanick/Pulp). And I'll go fetch myself a beer
and move away from they keyboard for a few hours. After all, it /is/ Friday,
and it's safe to say my quota of mad schemes has been reached for this week...

Toodlee-ho!
