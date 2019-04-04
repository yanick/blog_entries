---
title:  Embperl 2.0 chdir quirkiness
url: embperl-quirkiness
format: html
created: 14 Sep 2006
last_updated:
original: use.perl.org - http://use.perl.org/~Yanick/journal/30997
tags:
    - Perl
    - Embperl
---
<p>ah AH! It took me almost one year, but I finally got the sucker!</p><p>In the PerlWar web interface, I have this Embperl upload page. Except that ever since its conception, the little devil fails something like once every five times, without any visible reason.</p><p>Well, the reason, it turns out, is that Embperl 2 doesn't chdir to the page's directory (whereas Embperl 1 did). So if you're trying to open a file using a relative path, it'll work or not depending of the mood and state of the apache process the request is riding.</p><p>The solution? Add the following to the top of the page:</p>
<pre>    [-<br/>        $path = $epreq-&gt;component-&gt;cwd;<br/>
chdir $path or die "couldn't chdir to $path: $!";<br/>    -]</pre>
