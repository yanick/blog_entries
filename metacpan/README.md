---
title: MetaCPAN FTW!
format: markdown
created: 17 Dec 2010
tags:
    - Perl
    - CPAN
    - MetaCPAN
    - CPAN-API
    - Galuga
    - WWW::Widget
---

Right now, [Galuga](http://github.com/yanick/Galuga) has a widget that lists my 
CPAN distributions.  But it's a boring old static affair that is updated
manually. Surely in this age of the Web 2.0, I can do better than that.

My first instinct that to go straight for my 
[CPAN author page](http://search.cpan.org/~yanick) and extract the information
off the HTML:

<galuga_code code="Perl">from_search_cpan.pl</galuga_code>

Not too painful, all in all. Mind you, it'd be nicer not to have to fiddle with HTML
tables, but short of having a bona fide API... 

And that's when [Olaf's blog](http://blogs.perl.org/users/olaf_alders/2010/12/searchmetacpanorg-building-a-sexier-cpan-search.html) 
reminds me of [search.metacpan.org](http://search.metacpan.org) and
[the CPAN-API project](https://github.com/CPAN-API/cpan-api/wiki/API-docs). 
After a few minutes of peering at what they have to offer, 
the code above got simplified to:

<galuga_code code="Perl">from_metacpan.pl</galuga_code>

Sweet, isn't?


(The code for both variants of the widget is available at my [WWW-Widget
GitHub repo](http://github.com/yanick/WWW-Widget).)
