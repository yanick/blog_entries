---
title: Statement Toggler for Vim
url: statement-toggler
format: markdown
created: 13 Dec 2012
tags:
    - Perl
    - vim
---

**Update:** mysz pointed out
[splitjoin](https://github.com/AndrewRadev/splitjoin.vim), a vim plugin very
much in the same spirit as this hack, but generalized to other languages as
well.

**Update:** Also changed the vim mapping to use `<leader>`, as proposed by Joe
Frazer.

Raise your hand if that happened to you before: you have written

    #syntax: perl
    say "*hiccup*" if $eggnog_glass > 3;

and then realized that you also need to run `titubate()` as well if you drank
that many eggnogs?  

Or you wrote

    #syntax: perl
    for my $gift ( @heap ) {
        wrap($gift);
        write_card($gift);
        give($gift);
    }

and after a few rounds of refactoring get down to simply

    #syntax: perl
    for my $gift ( @heap ) {
        give($gift);
    }

which would be much better written with a postfix `for`?

Wouldn't it be nice if there was a way to flip block and postfix statements
with the ease of a single command?  Well, I thought so, so I came up with a
dirty little script:


    #syntax: perl
    #!/usr/bin/env perl 

    use 5.16.0;

    use strict;

    local $/;

    my $snippet = <>;

    $snippet =~ s/^\s*\n//gm;
    my ($indent) = $snippet =~ /^(\s*)/;
    $snippet =~ s/^$indent//gm;

    my $operators = join '|', qw/ if unless while for until /;

    my $block_re = qr/
        ^
        (?<operator>$operators)
            \s* (?:my \s+ (?<variable>\$\w+) \s* )?
            \( \s* (?<array>[^)]+) \) \s* {
                (?<inner>.*)  
            }
            \s* $
    /xs;

    my $postfix_re = qr/
        ^
        (?<inner>[^;]+?) 
        \s+ (?<operator>$operators) 
        \s+ (?<array>[^;]+?) 
        \s* ;
        $
    /xs;

    if ( $snippet =~ $block_re ) {
        $snippet = block_to_postifx( $snippet, %+ );
    }
    elsif( $snippet =~ $postfix_re ) {
        $snippet = postfix_to_block( $snippet, %+ );
    }

    $snippet =~ s/^/$indent/gm;

    say $snippet;

    sub postfix_to_block {
        my( $snippet, %capture ) = @_;

        $snippet = $capture{inner};
        chomp $capture{array};
        $snippet = "$capture{operator} ( $capture{array} ) {\n    $snippet\n}";

    }

    sub block_to_postifx {
        my( $snippet, %capture ) = @_;

        # more than one statement? Don't touch it
        return $snippet if $capture{inner} =~ /(;)/ > 1;

        $snippet = $capture{inner};
        $snippet =~ s/;\s*$//; 

        $snippet =~ s/\Q$capture{variable}/\$_/g;
        $snippet =~ s/\$_\s*=~\s*//g;

        $capture{array} =~ s/\s*$//;

        $snippet .= " $capture{operator} $capture{array};";

        return $snippet;
    }

(And, yeah, it's not the most robust thing ever, and would be better if it was
using [PPI](cpan), but for a first pass, it'll do.)

And then hooking the little macro

    vmap <leader>f :! ~/bin/postfix_toggle.pl<CR> 

to my `.vimrc`. Suddenly, I can turn

    #syntax: perl
    say "*hiccup*" if $eggnog_glass > 3;

into

    #syntax: perl
    if ( $eggnog_glass > 3 ) {
        say "*hiccup*"
    }
    
and 

    #syntax: perl
    for my $gift ( @heap ) {
        give($gift);
    }

into 

    #syntax: perl
        give($_) for @heap;


Cute, isn't? 

Oh, and if you want to see how this experiment will develop, the code will
soon appear on my [GitHub environment project
repo](https://github.com/yanick/environment).
