---
url: a-song-of-graph
format: markdown
created: 2014-02-02
tags:
    - Perl
---

# A Song of Graph and Report, Part I: A Gathering of Stats

Statistics and graphs. They don't always mean much, but they can be
so darn mesmerizing.

It's in that optic that I was looking at the 
[Map of CPAN][cpan_map] the other day and thought "wouldn't it be cool to have
the same view within a distribution?". It's not that I need to do that for
anything specific, mind you. But to have a distribution split into territories based on authors and files...
Maybe animated throughout different releases, to see the ebbs of contributors
and code. I'd be so nifty!

Now, considering that there are many things that can be done with those
statistics -- and because I should probably do some real work between bouts of 
fooling around -- I decided to cut the exercise into different parts.
Therefore, today we'll begin with the essential, if a tad dry, step required
for everything that will follow. Namely: the gathering of the statistics.

## Lay The Blames Around

The good news is that Git already has its `git blame` sub-command
that provide us with a per-line author attribution of the codebase. 
All we have to do is to interface with it, munge its data to our liking, 
and we'll be good to go.

To talk to Git, we'll use [Git::Repository](cpan:release/Git-Repository), with
the help of its plugin
[Git::Repository::Plugin::AUTOLOAD](cpan:release/Git-Repository-Plugin-AUTOLOAD)
to make things a little neater.

## Round Up The Files

So, first step: get the list of the files of the project for a given version tag.


``` perl
use Git::Repository 'AUTOLOAD';

my $project_dir = '.';
my $version     = 'v1.2.3';

my $git = Git::Repository->new( work_tree => $project_dir );

my @files = sort $git->ls_tree( '-r', '--name-only', $version );
```

## Who Did What?

So far, so good. Now, for every file, we want to have a list of its authors,
and how many lines they claim as their own:

```perl
my %file_attribution = map { 
    $_ => file_authors( $git, $version, $_ ) 
} @files;

sub file_authors {
    my( $git, $version, $file ) = @_;

    return [
        map { /\(\s*(.*?)\s*\d{4}-/ } $git->blame( $version, $file )
    ];
}
```

## Same Thing, But Compressed

With the code above, we now have an array for each file, holding the 
name of the author of each line. If we just want to tally
the overall contribution of each author, that's slightly overkill, but
it'll become handy when we'll be ready to draw the author map of each file.

Still... one entry per line, that's quite verbose. Instead, let's try to
scrunch that into a tally of the successive lines associated with the same
author:

```perl
use List::AllUtils qw/ reduce /;

my %file_attribution = map { 
    $_ => file_authors( $git, $version, $_ ) 
} @files;

sub file_authors {
    my( $git, $version, $file ) = @_;

    return reduce {
        if ( @$a and $a->[-1][0] eq $b ) {
            $a->[-1][1]++;
        }
        else {
            push @$a, [ $b, 1 ];
        }
        $a;
    } [ ], map { /\(\s*(.*?)\s*\d{4}-/ } 
               $git->blame( $version, $file );
}
```

Aaaah, yes. Not as dirt-simple as before, but the data structure 
is now much less wasteful.

## Massively Parallel Blaming

Next challenge: `git blame` is a little bit on the slow side. Not
sloth-on-a-diet-of-snails kind of slow, but it does have to spit out
all lines of every file. For big projects, that takes a few seconds.

But... isn't our little `file_authors()` function work in isolation
for each file? Wouldn't that be a perfect moment to whip out some 
parallelization ninja trick? Like... oh, I don't know, try out 
that neat new [MCE](cpan:release/MCE) module that makes the rounds these days?

```perl
use MCE::Map;

my %file_attribution = mce_map { 
    $_ => file_authors( $git, $version, $_ ) 
} @files;

```

And indeed, with the 4 cores of my faithful Enkidu, the overall script
suddenly goes 4 times faster. Considering that all it took was changing a 
`map` to a `mce_map`... yeah, I'll take that.

## Sum Everything Up

We now have our raw numbers. Getting the stats per author is now simple 
bookkeeping:

```perl
my $nbr_lines;
my %authors;

for my $x ( map { @$_ } values %file_attribution ) {
    $nbr_lines += $x->[1];
    $authors{$x->[0]} += $x->[1];
}

# switch into percents
$_ = 100 * $_ / $nbr_lines for values authors;
```

## Put It In A Big Book Of Stats

We'll want to return to those stats, so let's keep them in a file.
Let's make it a JSON file. Everybody loves JSON.

```perl

use JSON_File;

tie( my %stats, 'JSON_FILE', 'stats.json', pretty => 1 );

$stats{$version} = {
    nbr_lines   => $nbr_lines,
    authors     => \%authors,
    files       => \%file_attribution,
};
```

## Time To Generate a Report

The numbers are now ours to do as we see fit. Pretty graphical
stuff will have to wait for the next installments, but why not
create a quick credit roll for the project version we just
munged?

``` perl
use 5.10.0;

use List::AllUtils qw/ part /;

my( $minor, $major ) = part    { $authors{$_} >= 1 } 
                       reverse 
                       sort    { $authors{$a} <=> $authors{$b} } 
                       keys    %authors;

my $lines = $nbr_lines;

# 1000000 => 1,000,000 
1 while $lines =~ s/^(\d+)(\d{3})/$1,$2/;

say <<"END";

# CREDIT ROLL

This is the list of all persons who had their hands in
crafting the $lines lines of code that make
this version of $project, according to `git blame`.

This being said, don't take those statistics too seriously, 
as they are at best a very naive way to judge the contribution 
of individuals.  Furthermore, it doesn't take into account the army 
of equaly important peoples who report bugs, worked on previous
versions and assisted in a thousand different ways. For a glimpse of
this large team, see the CONTRIBUTORS file.

## The Major Hackarna

All contributors claiming at least 1% of the lines of code the project.

END

    printf "    * %-50s %2d %%\n", $_, $authors{$_} for @$major;

    if ( $minor ) {
        say "\n\n## The Minor Hackarna\n\n",
            "With contributions of: \n";

        say "    * ", $_ for @$minor;
    }
}

```

Running that against the latest release of 
[Dancer](cpan:release/Dancer) gives us:

```
# CREDIT ROLL

This is the list of all persons who had their hands in
crafting the 32,944 lines of code that make
this version of Dancer, according to `git blame`.

This being said, don't take those statistics too seriously, 
as they are at best a very naive way to judge the contribution 
of individuals.  Furthermore, it doesn't take into account the army 
of equaly important peoples who report bugs, worked on previous
versions and assisted in a thousand different ways. For a glimpse of
this large team, see the CONTRIBUTORS file.

## The Major Hackarna

All contributors claiming at least 1% of the lines of code the project.

    * Alexis Sukrieh                                     30 %
    * franck cuny                                        17 %
    * Sawyer X                                           10 %
    * Damien Krotkine                                     7 %
    * David Precious                                      6 %
    * ambs                                                5 %
    * Yanick Champoux                                     4 %
    * Michael G. Schwern                                  2 %
    * sawyer                                              1 %
    * Alberto Simoes                                      1 %
    * Mark Allen                                          1 %
    * Ovid                                                1 %


## The Minor Hackarna

With contributions of: 

    * mokko
    * Fabrice Gabolde
    * Philippe Bruhat (BooK)
    * Alex Kapranoff
    * LoonyPandora
    * chromatic
    * Anton Gerasimov
    * geistteufel
    * Paul Driver
    * Pedro Melo
    * sdeseille
    * David Moreno
    * Naveed Massjouni
    * Gabor Szabo
    * Rick Myers
    * Alex Kalderimis
    * Sam Kington
    * Max Maischein
    * Colin Keith
    * pdl
    * David Golden
    * JT Smith
    * Flavio Poletti
    * Nate Jones
    * William Wolf
    * Dagfinn Ilmari MannsÃ¥ker
    * Stefan Hornburg (Racke)
    * Chris Andrews
    * Kaitlyn Parkhurst
    * Oliver Gorwits
    * Perlover
    * Squeeks
    * Rowan Thorpe
    * CPAN Service
    * John Wittkoski
    * David Steinbrunner
    * Felix Dorner
    * Alessandro Ranellucci
    * Danijel Tasov
    * Al Newkirk
    * Mikolaj Kucharski
    * Kent Fredric
    * Kirk Kimmel
    * Vyacheslav Matyukhin
    * niko
    * Tom Hukins
    * jamhed
    * Franck Cuny
    * Joshua Barratt
    * James Aitken
    * Jesse van Herk
    * rowanthorpe
    * Roman Galeev
    * Marc Chantreux
    * Alex C
    * Martin Schut
    * Naveed
    * Michal Wojciechowski
    * Olof Johansson
    * Naveen
    * Ilya Chesnokov
    * Roberto Patriarca
    * boris shomodjvarac
    * Tom Wyant
    * Lee Carmichael
    * Jacob Rideout
    * Richard SimÃµes
    * Rik Brown
    * Alan Haggai Alavi
    * jonathan schatz
    * Dennis Lichtenthaeler
    * Emmanuel Rodriguez
    * smashz
    * David Cantrell
    * Xaerxess
    * Ask BjÃ¸rn Hansen
    * Paul Fenwick
    * Lee Johnson
    * Jonathan "Duke" Leto
    * Tim King
    * Olivier MenguÃ©
    * YOUR_NAME
    * Brian Phillips
    * Fayland Lam
    * adamkennedy
    * Craig Treptow
    * Jonathan Scott Duff
    * Joel Roth
    * Mark A. Stratman
    * ironcamel
    * John Barrett
    * Brian E. Lozier
    * Florian Larysch
    * Nicolas Oudard
    * Grzegorz RoÅ¼niecki
    * Christian Walde
    * Maurice
    * Sebastian de Castelberg
    * scoopio
    * Paul Tomlin
    * FranÃ§ois Charlier
    * Anirvan Chatterjee
    * jonasreinsch
    * Neil Hooey
    * Hans Dieter Pearcey
    * Lars Thegler
    * Murray
    * Adam J. Foxson
    * Tatsuhiko Miyagawa
    * sebastian de castelberg
    * Craig
    * Jakob Voss
    * isync
    * Mark Stosberg
    * Assaf Gordon
    * Hagen Fuchs
    * Ivan Paponov
    * Roman Nuritdinov
    * Tom Heady
    * Michael Genereux
    * Duncan Hutty
    * Alfie John
    * Matthew Horsfall (alh)
```
## On Our Next Episode

... things get interesting as we'll tackle transforming those stats 
into an author-colored map of the distribution. *Weeee!*

[cpan_map]: http://mapofcpan.org
