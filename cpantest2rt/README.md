---
title: Generating RT bugs out of CPAN Testers' Reports
url: cpantest-to-rt
format: markdown
created: 2010-10-31
tags:
    - Perl
    - CPAN Testers
    - rt.cpan.org
---


A few hours ago, I received a [CPAN Testers](http://www.cpantesters.org)'s
report. The report was a genuine bug (CPANtesters++. Love you guys), and 
as I made my way to [rt.cpan.org](http://rt.cpan.org)
to create a ticket to track the issue, I
found myself thinking that it'd be nice to have a '*bug this*' button
straight from the smoke report page.

You all know where that kind of thinking leads to, right?

I didn't GreaseMonkey'ed a button into the CPAN Testers page (yet),
but I did the second-best thing. Namely, a little command-line script that 
takes a report url and uses it to auto-generates a bug report to the right
distribution:

<pre code="bash">
$ ./cpantest2rt.pl http://www.cpantesters.org/cpan/report/8648ea2e-e35d-11df-a329-07bc4e7aadc9
</pre>

The [script](https://gist.github.com/yanick/657197.js) is pretty straight-forward. It grabs the bug report off the CPAN Testers site, 
figures out
which distribution we're talking about, generates an email with the report
information, gives you a chance to edit the report (the first line 
is the bug's title, the rest will be its description) and sends the
email on its merry way to `rt.cpan.org`.

In a future iteration, I'll probably switch to using the REST interface to RT,
but for now the email interface is proving to be Good
Enough<sup><i>tm</i></sup>.

