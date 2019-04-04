---
title:  use.perl.org offline journal editing
url: use-perl-org-offline-editing
format: html
created: 20 Sep 2006
original: http://use.perl.org/~Yanick/journal/31063
tags:
    - Perl
    - use.perl.org
---

<p>
    I must admit that I find the journal editing page of use.perl.org
    a wee bit irksome. First, there's the itsy bitsy editing
    box (I'm sure there's a configuration somewhere
    to increase its size, but I haven't found it yet). Then
    there is the HTML formatting that, in these days of wikiness,
    feels awfully verbose and clunky.
  </p><p>
    The first itch, admittedly, can be solved by using Firefox's
    plugin
<a href="https://addons.mozilla.org/firefox/394/" rel="nofollow">ViewSourceWith</a>    , which allow to edit textbox field in your editor of choice.
  </p><p>
    But the second itch remained. So I rolled up my hack sleeves
    and typetty-typed a script that takes in a journal entry
    in good ol' pod, converts it to SlasHTML (using
    <a href="http://search.cpan.org/search?query=Pod%3A%3ASimple;mode=module" rel="nofollow">
      Pod::Simple
    </a>
     and a
    <a href="http://search.cpan.org/search?query=XML%3A%3AXPathScript;mode=module" rel="nofollow">
      XML::XPathScript
    </a>
     template) and then uploads the result to use.perl.org (using

    <a href="http://search.cpan.org/search?query=Slash%3A%3AClient%3A%3AJournal;mode=module" rel="nofollow">
      Slash::Client::Journal
    </a>
    ).
  </p><p>
    The script can be found
<a href="http://babyl.dyndns.org/misc/pod2slash" rel="nofollow">here</a>    . To have it work for you, grep for
    <code>
      cookie_file
    </code>
     in the code and change it the right value for you.
    <pre>
      pod2slash entry.pod
    </pre>
     prints the formatted entry to STDOUT, and
    <pre>
      pod2slash -p entry.pod
    </pre>
     publish it to use.perl.org.
  </p><p>
NOTE: for some reason the upload mechanism seems to choke when there are links. Darn, darn and triple darns.</p>
