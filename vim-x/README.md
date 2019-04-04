---
url: vim-x
format: markdown
created: 2014-03-23
tags:
    - Perl
    - vim
---

# Vim::X - VimL is Eldritch, Let's Write Perl!

Last week, I finally got around [writing a few macros][vim_macros] to help with conflict
resolution in Vim:

``` viml
" conflict resolution - pick this one / option 1 / option 2
map ,. $?\v^[<=]{7}<CR>jy/\v^[=>]{7}<CR>?\v^[<]{7}<CR>"_d/\v^\>{7}<CR>"_ddP
map ,<  $?\v^[<]{7}<CR><,>.
map ,>  $?\v^[<]{7}<CR>/\v^[=]{7}<CR><,>. 
" ... or keep'em both
map ,m  $?\v^[<]{7}<CR>"_dd/\v[=]{7}<CR>cc<ESC>/\v[>]{7}<CR>"_dd
```

With that, I can go from conflict to conflict and pick sides with the ease of two
keystrokes, never have to manually 
delete those `<<<<<<<`, `=======` and `>>>>>>>` lines again. Sweet, eh?

Now, any sane person would have stopped there. Me, I found myself thinking
it'd be nice to transform that line of garblage into a neat little function. 

There is an obvious problem, though: my VimL-fu is pretty weak. 
However, my vim is always compiled with Perl support. Sure, the 
[native interface][perl-using] is kinda sucky, but... maybe we can improve on
that?

## Interfacing Vim with Perl

That's where `Vim::X` enter the picture (yes, I know, rather poor name.
Anybody has a better suggestion?). The module has two functions: 

1. give us a bunch of helper functions to interact with Vim as painlessly as
possible.
2. deal with all the fiddly bridgey things required to give us access to 
functions defined in Perl modules from Vim.

## Putting the 'V' back in 'DWIM'

`Vim::X` comes with a small, but growing, bag of helper functions, as well as
with helper classes -- `Vim::X::Window`, `Vim::X::Buffer`, `Vim::X::Line` --
that provide nice wrappers to the Vim entities. I still have to document them
all, but the implementation of my 'ResolveConflict' function should give you
an idea of how to use them:

``` perl
package Vim::X::Plugin::ResolveConflict;

use strict;
use warnings;

use Vim::X;

sub ResolveConflict {
        my $side = shift;

        my $here   = vim_cursor;
        my $mine   = $here->clone->rewind(qr/^<{7}/);
        my $midway = $mine->clone->ff( qr/^={7}/ );
        my $theirs = $midway->clone->ff( qr/^>{7}/ );

        $here = $side eq 'here'   ? $here
              : $side eq 'mine'   ? $mine
              : $side eq 'theirs' ? $theirs
              : $side eq 'both'   ? $midway
              : die "side '$side' is invalid"
              ;

        vim_delete( 
                # delete the marker
            $mine, $midway, $theirs, 
                # and whichever side we're not on
            ( $midway..$theirs ) x ($here < $midway), 
            ( $mine..$midway )   x ($here > $midway),
        );
};

1;
```

Sure, it's more verbose than the original macros. But now, we have a fighting
chance to understand what is going on. As it my habit, I am overloading the
heck of my objects. For example, the line objects will be seen as their line
number, or their content, depending of the context. Evil? Probably. But make
for nice, succinct code:

``` perl

sub Shout {
    my $line = vim_cursor;
    $line <<= uc $line;
}

```

## Fiddly bridgey things

This is where I expect a few 'oooh's and 'aaaah's. So we have
'ResolveConflict' in a Perl module. How do we make Vim see it?

First, you add a ':Vim' attribute to the function:

``` perl
sub ResolveConflict :Vim(args) {
    ...
```

Then, in your `.vimrc`:

``` viml
" only if the modules aren't already in the path
perl push @INC, '/path/to/modules/';

perl use Vim::X::Plugin::ResolveConflict

map ,<  call ResolveConflict('mine')
map ,>  call ResolveConflict('theirs')
map ,.  call ResolveConflict('here')
map ,m  call ResolveConflict('both')
```

Isn't that way more civilized than the usual dark invocations?

## One more step down the rabbit hole

Once I had my new 'ResolveConflict' written, it goes without saying that 
I wanted to test it. At first, I wrote a [vspec][vspec] test suite:

``` viml
describe 'basic'

    perl push @INC, './lib'
    perl use Vim::X::Plugin::ResolveConflict

    before
        new
        read conflict.txt
    end

    after
        close!
    end


    it 'here mine'
        normal 3G
        call ResolveConflict('here')

        Expect getline(1) == "a"
        Expect getline(2) == "b"
        Expect getline(3) == "c"
    end

    it 'here theirs'
        normal 6G
        call ResolveConflict('here')

        Expect getline(1) == "d"
        Expect getline(2) == "e"
        Expect getline(3) == "f"
    end

    it 'mine'
        normal 6G
        call ResolveConflict('mine')

        Expect getline(1) == "a"
        Expect getline(2) == "b"
        Expect getline(3) == "c"
    end

    it 'theirs'
        normal 6G
        call ResolveConflict('theirs')

        Expect getline(1) == "d"
        Expect getline(2) == "e"
        Expect getline(3) == "f"
    end

    it 'both'
        normal 6G
        call ResolveConflict('both')

        Expect getline(1) == "a"
        Expect getline(2) == "b"
        Expect getline(3) == "c"
        Expect getline(4) == "d"
        Expect getline(5) == "e"
        Expect getline(6) == "f"
    end

end
```

But then I found myself missing my good ol' TAP. If only there was an
interface to run those Perl modules within v--

oh.

So I changed the test suite to now look like:

``` perl
package ResolveConflictTest;

use Vim::X;
use Vim::X::Plugin::ResolveConflict;

use Test::Class::Moose;

sub test_setup {
    vim_command( 'new', 'read conflict.txt' );
}

sub test_teardown {
    vim_command( 'close!' );
}

sub here_mine :Tests {
    vim_command( 'normal 3G' );
    vim_call( 'ResolveConflict', 'here' );

    is join( '', vim_lines(1..3) ) => 'abc', "here, mine";
    is vim_buffer->size => 3, "only 3 lines left";
};

sub here_theirs :Tests { 
    vim_command( 'normal 6G' );
    vim_call( 'ResolveConflict', 'here' );

    is join( '', vim_lines(1..3) ) => 'def';
    is vim_buffer->size => 3, "only 3 lines left";
};

sub mine :Tests {
    vim_call( 'ResolveConflict', 'mine' );

    is join( '', vim_lines(1..3) ) => 'abc';
    is vim_buffer->size => 3, "only 3 lines left";
};

sub theirs :Tests {
    vim_call( 'ResolveConflict', 'theirs' );

    is join( '', vim_lines(1..3) ) => 'def';
    is vim_buffer->size => 3, "only 3 lines left";
};

sub both :Tests {
    vim_call( 'ResolveConflict', 'both' );

    is join( '', vim_lines(1..6) ) => 'abcdef';
    is vim_buffer->size => 6, "only 6 lines left";
};

__PACKAGE__->new->runtests;

```

I also wrote a little `vim_prove` script to run the show:

``` perl
#!perl -s

exec 'vim', qw/ -V -u NONE -i NONE -N -e -s /,
    ( map { 1; '-c' => "perl push \@INC, '$_'" } split ":", $I ),
    '-c', "perl do '$ARGV[0]' or die $@",
    '-c', "qall!";
```

Aaaand whatdyaknow:

``` bash
$ perl bin/vim_prove -I=lib contrib/test.vim
#
# Running tests for ResolveConflictTest
#
    1..5
        ok 1
        ok 2 - only 6 lines left
        1..2
    ok 1 - both
        ok 1 - here, mine
        ok 2 - only 3 lines left
        1..2
    ok 2 - here_mine
        ok 1
        ok 2 - only 3 lines left
        1..2
    ok 3 - here_theirs
        ok 1
        ok 2 - only 3 lines left
        1..2
    ok 4 - mine
        ok 1
        ok 2 - only 3 lines left
        1..2
    ok 5 - theirs
ok 1 - ResolveConflictTest
```

## What's Next?

The current [prototype][github] is on GitHub. I'll try to push it to CPAN once
I have a little bit of documentation and a little more order in the code. But
if you are interested, please, fork away, write plugins, and PR like there is
no tomorrow.

[github]: https://github.com/yanick/Vim-X
[vspec]: https://github.com/kana/vim-vspec
[vim_macros]: https://github.com/yanick/environment/commit/2b06e50f8c700a4476e946562c3cae13556ef36c
[perl-using]: http://vimdoc.sourceforge.net/htmldoc/if_perl.html
