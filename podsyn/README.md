---
title: Extract the Synopsis of a Module
url: podsyn
format: markdown
created: 9 May 2011
tags:
    - Perl
    - POD
    - Pod::XML
    - Pod::Find
    - XML::LibXML
---

When I begin to work with a module, most of the time
what I do is to look at its pod, and copy the code in the synopsis 
that I'll use as a a baseline.

Open pod, copy, paste. That's a lot of exhauting work... While I'm pretty
sure there's already a better tool to do it somewhere in CPAN, 
here's my little `podsyn` script that does all the hard work for me:

<galuga_code code="Perl">podsyn.pl</galuga_code>

Its use on the command line is straigt-forward:

<pre code="bash">
$ ./files/podsyn.pl Pod::XML

use Pod::XML;
my $parser = Pod::XML->new();
$parser->parse_from_file("foo.pod");
</pre>

And crafting a vim command to do the same shouldn't be too hard either (I'll
try to post one as soon as my vim-fu comes back to me). 
