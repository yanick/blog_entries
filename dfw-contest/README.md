---
title: Deduping 100 Gigs Worth of Files? Gimme 5 Minutes...
url: dfw-contest
format: markdown
created: 2014-01-11
tags:
    - Perl
    - DFW
    - contest
---

[dfw]: http://dfw.pm.org/

Shortly before the Holidays, I became aware of the
[Dallas/Fort Worth Perl Mongers Winter Hackaton Contest][dfw]. The challenge
was simple enough: here's a directory structure filled with 100G worth of
files, go and find all the duplicate files in there, as fast as you can.

You know me: can't resist a contest. But since I knew I didn't have
heaps of time to sink into it, and because -- let's face it -- the Perl
community is despairingly brim-full of smart peoples who always beat me 
to the finish line, I decided to compete on slightly different terms.
My main objective would be to leverage a maximum from modern Perl
tools so that effort to get a working solution would be minimal.
As for the performance of the solution, I decided that I'd be satisfied, and
that the case for modernity and laziness would be made 
if it was at least in the ballpark of the other entries.

And so it began...

## The Application Interface

Writing code to interact with the users is booooooring.

The hard part, the fun part, the challenging part is to come up with
the function `do_it( $foo, $bar )`. Once this is done, all that remains to do
is to turn the handle and give a way to the user to set `$foo` and `$bar`. And
to validate the incoming values for `$foo` and `$bar`. And document what are `$foo` and
`$bar`. Blergh. It's dotting the i's, and crossing the t's. It's writing the
police report after that blood-pumping drug cartel take-down.

Fortunately, there are a few modules that will take that tedium off yours
hands. One of my favorites is [MooseX-App](cpan:release/MooseX-App), and 
for this project I used its single-command variation,
[MooseX::App::Simple](cpan:MooseX::App::Simple). Its use is pretty
straightforward. The main module of the application is a `Moose` class

``` perl
package Deduper;

use strict;
use warnings;

use MooseX::App::Simple;
```

Attributes of the class that you want to be accessible as options of the 
script are defined using the `option` keyword. Same story for positional
parameters, with the `parameter` keyword. Other attributes stays untouched,
and won't be visible to the user.

``` perl
parameter root_dir => (
    is => 'ro',
    required => 1,
    documentation => 'path to dedupe',
);

option hash_size => (
    isa => 'Int',
    is => 'ro',
    default => '1024',
    trigger => sub {
        my $self = shift;
        Deduper::File->hash_size( $self->hash_size );
    },
    documentation => 'size of the file hash',
);

option stats => (
    isa => 'Bool',
    is => 'ro',
    documentation => 'report statistics',
);

option max_files => (
    traits => [ 'Counter' ],
    isa => 'Int',
    is => 'ro',
    predicate => 'has_max_files',
    default => 0,
    documentation => 'max number of files to scan (for testing)',
    handles => {
        dec_files_to_scan => 'dec',
    },
);

has start_time => (
    is => 'ro',
    isa => 'Int',
    default => sub { 0 + time },
);
```

Last required touch for the class: a `run()` method that will be invoked when
the app is run:

```perl
sub run {
    my $self = shift;

    say join "\t", map { $_->path } @$_ for $self->all_dupes;
}
```

With that, your app is in working condition. Command-line parsing, argument
validation, `--help` text, it's all taken care of for you:

```bash
$ cat ./dedup.pl

use Deduper; 
Deduper->new_with_options->run;

$ ./dedup.pl
Required parameter 'root_dir' missing
usage:
    dedup.pl [long options...]
    dedup.pl --help

parameters:
    root_dir  path to dedupe [Required]

options:
    --hash_size           size of the file hash [Default:"1024"; Integer]
    --help -h --usage -?  Prints this usage information. [Flag]
    --max_files           max number of files to scan (for testing) [Default:
                          "0"; Integer]
    --stats               report statistics [Flag]

```

## Traversing Directory Structures

Traversing directory structures isn't terribly hard. But there are a few
things like symlinks that you have to watch for. What we care about, really,
is to have each file of the structure handed to us on a silver platter. Let's
have somebody else deal with the underlying menial work.

Here, this somebody else is
[Path::Iterator::Rule](cpan:release/Path-Iterator-Rule). With it, visiting all
files of the directory structure boils down to creating an attribute

``` perl
has file_iterator => (
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        return Path::Iterator::Rule->new->file->iter_fast( 
            $self->root_dir, {
                follow_symlinks => 0,
                sorted          => 0,
        });
    },
);
```

and, well, using it

``` perl
while( my $file = $self->file_iterator->() ) {
    # do stuff with $file...
}
```

## A Couple Of No-Brainish Optimizations

Everybody love optimizations that require no more effort than to press a
'turbo' button. On this project, two modules providing that kind of boost were
just begging to be used. 

The first is
[MooseX::XSAccessor](cpan:release/MooseX-XSAccessor), which invests the
accessors of the class with super-speedy XS powers. Alas, that module does not
speed up lazy-defined attributes, which I used in spade. But since its use
only require to drop a

``` perl
use MooseX::XSAccessor;
```

at the top of the file, it's not like I have much to lose anyway.

The second module is
[MooseX::ClassAttribute](cpan:release/MooseX-ClassAttribute). As you probably
realized from the previous code snippets, my code create an object per file.
For 100G worth of files, that turns out to be *lots* of objects. So having
configuration attributes that will all end up having the same value over and
over again for each object would be quite wasteful. In that case, using an 
attribute which value is shared for all objects of the class makes much 
more sense. And, again, using that module is dead simple:

``` perl
package Deduper::File;

use Moose;
use MooseX::ClassAttribute;

class_has hash_size => (
    isa => 'Int',
    is => 'rw',
    default => 1024,
);

sub foo {
    my $self = shift;

    # hash_size can be used as a regular attribute
    my $hs = $self->hash_size;
    ...
}
```

The cherry on top of everything is that those class attributes are 
totally transparent to the rest of the code. Ever find that you want
per-object values after all, change 'class_has' for 'has', and you're 
done.

## Keeping Different Functionalities Nicely Segregated

A bonus that using a Moose-based class brought to the project was to keep 
different functionalities logically apart via method modifiers. For example, 
the `run()` method of an app typically juggles with the different options
requested:

``` perl
sub run {
    my $self = shift;

    my $n = $self->max_files || -1;

    until ( $self->finished ) {
        print $self->next_dupe;
        if ( $n > -1 ) {
            $n--;
            $self->finished(1) if $n == 0;
        }
    }
    $self->print_stats if $self->stats;
}
```

instead, once can encapsulate those different behaviors in separate functions

``` perl
sub check_max_files {
    my $self = shift;

    $self->dec_files_to_scan;
    $self->finished(1) if $self->files_to_scan == 0;
}

sub stats {
    # print a lot of stuff
}

sub run {
    my $self = shift;

    print $self->next_dupe until $self->finished;
}
```

and stitch in whatever is needed at creation time:

``` perl
sub BUILD {
    my $self = shift;

    $self->meta->make_mutable;

    $self->meta->add_after_method_modifier(
        next_dupe => \&check_max_file,
    ) if $self->max_files;

    $self->meta->add_after_method_modifier( run => \&print_stats )
        if $self->stats;

    $self->meta->make_immutable;
}
```

If managed properly, this makes each method much smaller and much more
single-minded. As a nice side-effect, the final application object will only
contain the code that it requires. If the option `--max_file` isn't passed,
the algorithm won't have an additional 'if' statement to deal with per
iteration. It's not much, but it will make the default case just a tad faster.
I must say, however, that this is not a free lunch: if the option is passed,
the running time *will* be slower than if a simple 'if' was used. But that
trade-off can make sense, like here where I'm ready to have a slight penalty
when I run my test runs, but really want to have the tires screeching for the
main event.

## Finally, The Core Algorithm

With all boilerplate stuff dealt with, we can focus on the core problem. After
some experimenting, I ended up with a recipe that isn't exactly
ground-breaking, but seems to be efficient. The encountered files are first
classified by file size. For files of the same size, we compare the first X
bytes of the file (where 'X' is fairly small). If they share that beginning,
we compare their last X bytes (in case we're dealing with file types with the same
preamble). Then, ultimately, we compare full-file digests (using
[Digest::xxHash](cpan:release/Digest-xxHash) which is pretty damn fast).
Everything is only computed if required, and then cached so that we do the
work only once.

Translated into code, it looks pretty much like

``` perl

# in class Deduper

sub next_dupe {
    my $self = shift;

    return if $self->finished;

    while( my $file = $self->file_iterator->() ) {
        $file = Deduper::File->new( path => $file );
        my $orig = $self->is_dupe($file) or next;
        return $orig => $file;
    }

    $self->finished(1);
    return;
}

sub is_dupe {
    my( $self, $file ) = @_;

    return $_ for $self->find_orig($file);

    # not a dupe? enter it in the registry
    $self->add_file($file);

    return;
}

sub find_orig {
    my( $self, $file ) = @_;

    # do we have any file of the same size?
    my $candidates = $self->files->{$file->size}
        or return;

    my @c;

    # only have a sub-hash if we have more than one
    # file, so as not to compute the 'hash' (beginning of the file) 
    # needlessly
    if( ref $candidates eq 'Deduper::File' ) {
        return if $candidates->hash ne $file->hash;
        @c = ( $candidates );
    }
    else {
        @c = @{ $candidates->{$file->hash} || return };
    }

    # first check if any share the same inode
    my $inode = $file->inode;
    for ( @c ) {
        return $_ if $_->inode == $inode;
    }

    # then check if dupes
    for ( @c ) {
        return $_ if $_->is_dupe($file);
    }

    return;
}

sub add_file {
    my( $self, $file ) = @_;

    if( my $ref = $self->files->{$file->size} ) {
        if ( ref $ref  eq 'Deduper::File' ) {
            $ref = $self->files->{$file->size} = { $ref->hash => [ $ref ] };
        }
        push @{$ref->{$file->hash}}, $file;
    }
    else {
        # nothing yet, just put the sucker
        $self->files->{$file->size} = $file;
    }

}

# and then in Deduper::File

sub is_dupe {
    my( $self, $other ) = @_;

    # if we are here, it's assumed the sizes are the same
    # and the beginning hashes are the same

    # different hashes?
    return $self->end_hash eq $other->end_hash
        && $self->digest eq $other->digest;
}
```

## And I Give You The Pudding, Fully Cooked

The application, as submitted to the contest, can be found on
[GitHub](gh:yanick/dfw-contest). 

"And how did it fare, performance-wise?", you ask? Well, if the contest results
are to be trusted, it processed the 100G monster in a little less than 4
minutes which, I think, ain't too shabby. 

Mostly considering that, y'know, 
it turned out to be the best time of all submitted entries. :-)

