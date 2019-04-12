---
title: Gentlemen, set your keyboards to 'optimized'
url: keyboard-optimized
format: html
created: 2006-09-13
original: use.perl.org - http://use.perl.org/~Yanick/journal/30983
tags:
    - Perl
    - vim
---

	<p>Yesterday, I decided to put in action two of the neato
keyboard layout optimization tricks
that I got from the the vim tips
<a href="http://www.vim.org/tips/" rel="nofollow">rss feed</a>.</p><p> <b>optimization 1: ( $caps_lock, $esc ) = ( $esc, $caps_lock )</b> </p><p>In vim, one hits <code>ESC</code> a gazillion time a day and
<code>CAPS LOCK</code> maybe, on two or three times a century. Yet, the first
key is located at the outside periphery of the keyboard while the
second sits, fat and proud, in the middle of things. Not fair. Well,
doing a <code>xmodmap escapswapper</code> fix that engineering blunder,
where <code>escapswapper</code> is:</p><blockquote><div><blockquote><div><p> <tt>! Swap caps lock and escape<br/>remove Lock = Caps_Lock<br/>keysym Escape = Caps_Lock<br/>keysym Caps_Lock = Escape<br/>add Lock = Caps_Lock</tt></p></div> </blockquote></div> </blockquote><p> <b>optimization 2: y/123456789/!@#$%^&amp;*()/ </b> </p><p>When one programs in Perl, one gets to type '$', '@' and '%'
six times per line (or more, if you're a Perl golfer or
swear a lot in your comments). In comparison, numbers are used
a wee bit less frequently. And yet, it's the symbols that
get the shift tax. Not fair. Again, a little remapping easily
corrects this gross injustice:</p><p> <i>in <code>~/.vimrc</code> </i> </p><blockquote><div><blockquote><div><p> <tt>autocmd FileType perl source ~/.vim/my/perl_map.vim</tt></p></div> </blockquote></div> </blockquote><p> <i>and in <code>~/.vim/my/perl_map.vim</code> </i> </p><blockquote><div><blockquote><div><p> <tt>" map each number to its shift-key character<br/>inoremap 1 !<br/>inoremap 2 @<br/>inoremap 3 #<br/>inoremap 4 $<br/>inoremap 5 %<br/>inoremap 6 ^<br/>inoremap 7 &amp;<br/>inoremap 8 *<br/>inoremap 9 (<br/>inoremap 0 )<br/>" and then the opposite<br/>inoremap ! 1<br/>inoremap @ 2<br/>inoremap # 3<br/>inoremap $ 4<br/>inoremap % 5<br/>inoremap ^ 6<br/>inoremap &amp; 7<br/>inoremap * 8<br/>inoremap ( 9<br/>inoremap ) 0</tt></p></div> </blockquote></div> </blockquote>
