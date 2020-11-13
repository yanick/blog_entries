---
created: 2011-05-09
tags:
    - Perl
    - POD
    - Pod::XML
    - Pod::Find
    - XML::LibXML
---

# Extract the Synopsis of a Module

When I begin to work with a module, most of the time
what I do is to look at its pod, and copy the code in the synopsis 
that I'll use as a a baseline.

Open pod, copy, paste. That's a lot of exhauting work... While I'm pretty
sure there's already a better tool to do it somewhere in CPAN, 
here's my little `podsyn` script that does all the hard work for me:

``podsyn.pl``

Its use on the command line is straigt-forward:

```bash
$ ./files/podsyn.pl Pod::XML

use Pod::XML;
my $parser = Pod::XML->new();
$parser->parse_from_file("foo.pod");
```

And crafting a vim command to do the same shouldn't be too hard either (I'll
try to post one as soon as my vim-fu comes back to me). 
