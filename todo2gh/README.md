---
title: Pushing Your Code TODOs to GitHub Issues
url: todo2gh
format: markdown
created: 2013-01-30
last_updated: 31 Jan 2013
tags:
    - Perl
---

> **Update:** I also updated the RT to GitHub exporter I've showcased 
> [some time ago](http://babyl.ca/techblog/entry/rt-to-github) 
> to v3 of the GitHub
> API. It's available in my [env repo](https://github.com/yanick/environment/blob/master/bin/rt-to-github.pl) as well.

A quick one. Wouldn't it be cool to be able to scan your code for all *TODO*s
and *FIXME*s and generate GitHub issues out of them? Well, I thought so too,
so:

    #syntax: perl
    #!/usr/bin/perl 

    use 5.16.0;

    use strict;
    use warnings;

    use Path::Iterator::Rule;
    use Path::Tiny;
    use List::AllUtils qw/ indexes before apply first /;
    use Git::Repository;
    use IO::Prompt::Tiny qw/prompt/;
    use Net::GitHub;

    my $git = Git::Repository->new( work_tree => '.' );

    # my remote is always named 'github', you might have to 
    # adapt to your habits
    my( $project ) = first { /^github/ } $git->run( 'remote', '-v' );
    $project =~ s/^.*?://;
    $project =~ s/\.git.*$//;

    my $github = Net::GitHub->new(
        login => 'you', 
        pass => 'yourpassword',
    );

    $github->set_default_user_repo( split '/', $project );

    Path::Iterator::Rule->new
        ->file
        ->name( qr/\.p[lm]$/ )
            # I'm too lazy for the next() dance...
        ->and( sub{ 
            my $path = path($_);

            my @lines = $path->lines;
            process_todo( $path, $_, \@lines ) for indexes { 
                /^ \s* \# \s* (?:TODO|FIXME) /x and not /\[GH\d+\]/ 
            } @lines;

            return 0; # we don't want to collect the files
        })
        ->all( @ARGV );

    sub process_todo {
        my( $file, $nbr ) = @_;
        my @lines = @{$_[2]};

        my $subject = $lines[$nbr] =~ s/^.*?#\s*(?:TODO|FIXME)\s*//r;
        my @body = apply { s/^\s*#\s?// } before { !/^\s*#/ }  @lines[$nbr+1..$#lines];

        # TODO don't assume master
        my $url = "https://github.com/$project/blob/master/$file#L$nbr";
        $url .= '-' . ($nbr+@body) if @body;

        say $subject;
        say "";
        say @body;

        prompt( "create Issue? (y/N)", 'n' ) =~ /y/ or return;

        my $isu = $github->issue->create_issue( {
            "title" => $subject,
            "body" => join( '', @body, "\n\n", $url ),
            labels => [ 'code todo' ],
        } ) or die "error in creating issue";

        say "issue ", $isu->{number}, " created";
        say $isu->{html_url};
        say "";

        my $issue = $isu->{number};

        $lines[$nbr] =~ s/(TODO|FIXME)/$1 [GH$issue]/;

        $file->spew(@lines);
    }


And with that little beauty, you can do

    #syntax: bash
    $ todo2gh.pl lib

in the root of your project and it'll sniff all the modules and scripts and,
for all TODO found of the format

    #syntax: perl
    # TODO frobusnicate the loop
    # some details that will end up in the issue's body

it'll prompt you if you want to create an issue and automagically convert
the TODO to

    #syntax: perl
    # TODO [GH3] frobusnicate the loop
    # some details that will end up in the issue's body

Meanwhile, a new issue will now live on GitHub, with the proper title and
label, and a nice link in the body leading to that exact place in the code.

Enjoy!

(And if you are interested to improve on the script, it lives
for the time being [in my env
repo](https://github.com/yanick/environment/blob/master/bin/todo2gh.pl))


