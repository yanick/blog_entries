---
title: Exporting Old use.perl.org Blog Entries
format: markdown
created: 12 Dec 2010
tags:
    - Perl
    - use.perl.org
    - pQuery
    - LWP::Simple
---

This week-end I finally got around importing all my old 
[use.perl.org](http://use.perl.org/journal.pl?op=list&uid=3196)
blog entries to [Fearful Symmetry](http://babyl.dyndns.org/techblog). 
To ease off the migration, I ended up writing two itsy-bitsy scripts.
They're nothing fancy, but in case they might help someone, here they are.

## Harvest the entries

This was easy. For each account, `use.perl.org` has a journal entries
listing page. So the whole operation consisted of grabbing that webpage
and mirror everything on it looking like a journal entry.  Not terribly
sophisticated, but for this specific job it's all we need.

Of the script itself, the most interesting part is `LWP::Simple::getstore()`.
Most people know and use `LWP::Simple::get()`, but more than a few forget its
sibling, which save the retrieved webpage directly to a file -- which is
perfect for harvesting activities like this one. 

<galuga_code code="Perl">harvest_entries.pl</galuga_code>

## Extract the information off the harvested pages

As one might suspect, the harvested `use.perl.org` pages contain a
little bit more than the raw blog entries.  Getting to the information
we want -- the blog entry's title, creation date, body, etc -- is not hard,
but it's a little onerous to do by hand.

There are a lot of way to extract information from a webpage, from quick and
dirty regular expressions (like I did in for the script above) to full-fledged
DOM parsing using, say, [HTML::Tree](cpan).  As I'm playing a lot with
[jQuery](http://jquery.com) these days, I wondered if there was anything Perlish
available offering the same type of interface. Guess what? There is:
[pQuery](cpan).  

After playing with it a little bit, I'd  say that `pQuery` is 
not quite as slick and ready for prime-time as its JavaScript forebear. But
again, for this small task, it allowed me to do the job.

The resulting script is as straight-forward as they come. I used
[Firebug](http://getfirebug.com) to find out which html elements I want, 
tested the resulting paths with jQuery and, once I was happy with the result,
adapted the result to pQuery. 

<galuga_code code="Perl">extract_entry.pl</galuga_code>

## It's harvesting time

With those two scripts ready to go, the harvesting process becomes much less
of a chore:

<pre code="bash">
$ perl files/harvest_entries.pl 
retrieving 38951...
retrieving 38951...

$ perl files/extract_entry.pl 38951 
title: Breaking off from the use.perl.org mothership
date: 10 May 2009
original url: http://use.perl.org/~Yanick/journal/38951


&lt;p>
For the last couple of months, as a concession between
visibility and control, I'd been double-posting my blog
entries both here and on my
personal blog.
But now that my blog is registered on both the
&lt;a href="http://perlsphere.net/" rel="nofollow">Perlsphere&lt;/a> and
&lt;a href="http://ironman.enlightenedperl.org/" rel="nofollow">IronMan&lt;/a> aggregators,
the need for the second posts here has dwindled.  So... I'm going
on a limb and tentatively turn off the echoing.
See y'all on &lt;a href="http://babyl.dyndns.org/techblog" rel="nofollow">Hacking Thy Fearful
Symmetry&lt;/a>!&lt;/p>

</pre>


Of course, there is still the grooming of the `use.perl.org` html, and the
actual importing to the new blogging engine. But... surely a handful of other
scripts can take care of that, right? :-)

