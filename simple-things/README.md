---
title: Making Simple Things Easy
url: simple-things
format: markdown
created: 9 Feb 2013
tags:
    - Perl
---

> <i>Hai!</i>
>
> <i>There is that web page listing a bunch of PDF files. Is there a way to</i>
> <i>get them all and, while we are at it, collate'em into a single document? </i>
> 
> <i>Kthxbai</i>

    #syntax: perl
    #!/usr/bin/env perl 

    # usage: $0 <the_url>

    use 5.16.0;

    use Web::Query;
    use LWP::Simple;
    use Path::Tiny;
    use List::AllUtils qw/ reduce /;
    use CAM::PDF;

    ( reduce { $a->appendPDF($b); $a } @{
        wq( $ARGV[0] )
        ->find('a')
        ->filter( sub {
            $_[1]->attr('href') =~ /\.pdf$/;
        })
        ->map( sub {
            my $temp = Path::Tiny->tempfile;
            $temp->spew( get( $_[1]->attr('href') ) );
            CAM::PDF->new($temp);
        })
    }) ->cleanoutput('aggregate.pdf');


You're welcome.
