---
created: 2014-04-08
tags:
    - Perl
    - vim
---

# Vim::X Update

Just a quick update on [Vim::X](gh:yanick/Vim-X), (if you need
a recap, it was introduced in my previous [blog entry](blog:vim-x)).

## A Use-case

Since I've punted the module to CPAN, I also began to use it a little more seriously,
and it's awesome. For example, when I do work on the
[PerlWeekly](http://perlweekly.com), I plop the urls in a Markdown file

	http://short.com/deadbeef

and I manually change it to be

```perl
### Modern Perl: 2014 Edition is Out
http://www.modernperlbooks.com/mt/2014/04/modern-perl-2014-edition-is-out.html
2014-04-04
```

Blerg. Why do it manually when I can have Perl do it for me?

```perl
package PerlWeekly;

use Vim::X;

sub PWGetInfo :Vim() {
    require LWP::UserAgent;
    require Web::Query;
    require Escape::Houdini;

    no warnings 'uninitialized';

    my ($url) = vim_cursor->content =~ m#(http://\S+)# or return;

    my $resp = LWP::UserAgent->new->get( $url );

    my $content = $resp->content;

    $url = $resp->base;
    my $wq = Web::Query::wq($content);

    # get the title
    my $title = Escape::Houdini::unescape_html($wq->find('head title')->html);

    # get a date
    my $date;
    $date = $1 if $content =~ /published\s+on\s+([^<]+)/i
                or $content =~ /(201\d.\d{2}.\d{2})/;

    vim_cursor->content( 
        join "\n",  '### ' . $title, $url, $date, undef, undef 
    );
}

1;
```

With that, I just have to add the following to my `.vimrc`

```vim
perl push @INC, '/path/to/lib/having/PerlWeekly.pm';
perl use PerlWeekly;

map <leader>,pw :call PWGetInfo()<CR>
```

and my task will be forever easier. Yeah.

## Make the loading easier and lazier

That's good, but it can be made better with the new 
function `VIM::X::load_function_dir()`. That function is there to help
load whole libraries of Perl functions more easily, and more
efficiently.

Basically, the function looks into whatever directory we give it, and will import into Vim-space all
the functions it finds therein. Nicely enough, it'll import them
using Vim's *autocmd* mechanism, so the Perl code will only be sourced
if the function is invoked. This means (a) quick startup time and (b) we'll
only have to load the dependencies that we use, when we use them.

To revisit the example of the first section, we will mode the code from
`PerlWeekly.pm` to `~/.vim/vimx/perlweekly/PWGetInfo.pl` and remove some cruft:

```perl
use Vim::X;

# only loaded on demand, so we can go *WILD*
use LWP::UserAgent;
use Web::Query;
use Escape::Houdini;

sub PWGetInfo :Vim() {

    no warnings 'uninitialized';

    my ($url) = vim_cursor->content =~ m#(http://\S+)# or return;

    my $resp = LWP::UserAgent->new->get( $url );

    my $content = $resp->content;

    $url = $resp->base;
    my $wq = Web::Query::wq($content);

    # get the title
    my $title = Escape::Houdini::unescape_html($wq->find('head title')->html);

    # get a date
    my $date;
    $date = $1 if $content =~ /published\s+on\s+([^<]+)/i
                or $content =~ /(201\d.\d{2}.\d{2})/;

    vim_cursor->content( 
        join "\n",  '### ' . $title, $url, $date, undef, undef 
    );
}
```

And the loading in our `.vimrc` becomes

```vim
perl use Vim::X;

autocmd BufNewFile,BufRead **/perlweekly/src/*.mkd
            \ perl Vim::X::load_function_dir('~/.vim/vimx/perlweekly')
autocmd BufNewFile,BufRead **/perlweekly/src/*.mkd
            \ map <leader>pw :call PWGetInfo()<CR>
```

Getting to be prrrrrrretty nice, don't you think?
