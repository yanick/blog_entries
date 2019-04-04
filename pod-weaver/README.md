---
url: taming-pod-weaver
format: markdown
created: 2011-10-08
tags:
    - Dist::Zilla
    - Pod::Weaver
    - rjbs
    - Perl
---

# Taming Pod::Weaver

Let's begin by stating the obvious: [rjbs](http://search.cpan.org/~rjbs/) is a brilliant man, and his
contributions to Perl are as numerous as they are significant. His 
[Dist::Zilla](cpan) alone has poured bucketfuls of much needed grease into 
the process of releasing Perl modules, and has thus
spared the perl community enough grey hair to seriously jeopardize the
revenu stream of all major men's hair treatment companies. I would be
the first in line to get his initials tattoed on my shoulder if it wouldn't
sound so creepy. And disturbing. And hard to explain to my wife. 

Anyway, bottom-line is: rjbs rocks, and the stuff he churns is awesome.

This being said, awesome is not perfect. Talking specifically about the
ecodological system surrounding Dist::Zilla, I don't think I'd shock or
surprise anybody if I was to say that the whole shebang is a little hard
to grok. In that respect, slipping into the Dist::Zilla universe is like
sitting into the batmobile. You know it's a lean, mean, crime-fighting
machine, but where the deuce is the ignition key? 

Mind you, by now it's not so bad if you
want to take <strike>the batmobile</strike> `dzil` out for a ride, as there is 
the [dzil website](http://dzil.org/) as well as many blog posts on the topic. 

But if you want to flip up the hood and tinker with the mechanics? Oh boy.
The documentation is rather minimal (can't blame the man, mind you. He's there
to fight crime, not write car manuals). And rjbs's coding style has a strong 
personal flavor that does take some time to get used to.  And the whole thing
has strong depencendies on more magnificent yet pod-scarce, rjbsyncratic modules (hello
[Config::MVP](cpan)!).

[Pod::Weaver](cpan), which does to POD what Dist::Zilla does to
distribution files, is all that, only moreso.  But it feels so powerful, holds so
much promises to make my life easier once I manage to master it, that I won't
let the steep learning curve deter me. I'll climb down my brain bicycle, and
push it up that hill. And I'll provide a running (well, walking slowly)
commentary as I go along, in the hope that it'll help other peeps who might
want to venture is those exciting yet dark waters.

Okay. Enough preamble. Let's get cracking.

## Step 1: Let's Run Something

If Perl modules are bottles of ketchup, their synopsis is usually the helpful
initial tap that get the red stuff flowing.

Unfortunately, a glimpse of [Pod::Weaver's synopsis](https://metacpan.org/module/Pod::Weaver#SYNOPSIS) 
doesn't lead to a sharp *ah AH!*, but more of a subdued *whu?*.  So we have to
dig a little deeper to understand to use it.

First thing is to understand the actors of that particular drama. Pod::Weaver
itself is the rendering engine. Its purpose is to take a Perl file, like say:

    #syntax: perl
    package Frobuscate::Util;
    # ABSTRACT: all you need to frobuscate your data

    =head1 SYNOPSIS

        use Frobuscate::Util qw/ frob /;

        my $frobbed = frob( $stuff );

    =cut

    use 5.12.0;

    ...

    1;


and munge the POD according to a configuration/doc template file, usually
named '`weaver.ini`'.  In that template file, Pod::Weaver plugins are declared
that will either insert specific pieces of POD in the generated document, or
perform certain transmutations of the original POD/code.  For example, one of
the simplest '`weaver.ini`' we could have is:

    #syntax: bash
    [Leftovers]

The configuration item 'Leftovers', which comes from
`Pod::Weaver::Section::Leftovers` outputs all the POD sections that haven't
been touched by `Pod::Weaver` yet. As for now it's the only directive, it'll 
simply print out the original POD. Not terribly exciting, granted, but it's a start.

So, we have our different ingredients. How do we put them together?

To get something working, I had to cheat and peek at how
[App::podweaver](cpan) was doing it. Simplifying its code, I was able
to come up with the following minimal script to generate and output the weaved
POD:

    #syntax: perl
    use strict;
    use warnings;

    use Pod::Weaver;
    use File::Slurp;
    use PPI::Document;

    my $filename = shift @ARGV;

    # create Pod::Weaver engine, taking 'weaver.ini' config
    # into account
    my $weaver = Pod::Weaver->new_from_config;

    my $perl = File::Slurp::read_file( $filename );

    # get PPI DOM of the file to process
    my $ppi  = PPI::Document->new( \$perl );

    # get its POD as an Pod::Elemental DOM object
    my $pod = Pod::Elemental->read_string(
        join '', @{ $ppi->find( 'PPI::Token::Pod' ) || [] }
    );

    # ...and remove it from the PPI
    $ppi->prune( 'PPI::Token::Pod' );

    # weaver, do your stuff
    my $doc = $weaver->weave_document({
        pod_document => $pod,
        ppi_document => $ppi,
    });

    # print the generated POD
    print $doc->as_pod_string;


The method `weave_document()` is where all the magic happens.
The key thing to know is that the Perl file that we wish to feed the 
method needs to be pre-divided and massaged into two object: an
`PPI::Document` object that contains the code of the file, and an
`Pod::Elemental` object which contains its POD. 

And indeed, if we try it out:

    #syntax: bash
    $ perl weave.pl Util.pm 
    =pod

    =head1 SYNOPSIS

        use Frobuscate::Util qw/ frob /;

        my $frobbed = frob( $stuff );

    =cut
    =cut

Yay! It works!

In the next installment: we'll beef up our '`weaver.ini`', and begin to use
section plugins.
