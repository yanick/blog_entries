---
url: test-pod-snippets
format: html
created: 23 Aug 2006
last_updated: 21 Nov 2010
original: use.perl.org - http://use.perl.org/~Yanick/journal/30734
tags:
    - Test::Pod::Snippets
---

# Test::Pod::Snippets v0.01 is out!

<p>From T::P::S's manpage:</p><dl> <dt>Fact 1</dt><dd>
In a perfect world, a module's full API should be covered by an extensive
battery of testcases neatly tucked in the distribution's t directory.
But then, in a perfect world each backyard would have a marshmallow tree and
postmen would consider their duty to circle all the real good deals in pamphlets
before stuffing them in your mailbox. Obviously, we're not living in a perfect
world.
</dd>
<dt>Fact 2</dt><dd>
Typos and minor errors in module documentation. Let's face it: it happens to everyone.
And while it's never the end of the world and is prone to rectify itself in
time, it's always kind of embarassing. A little bit like electronic zits on
prepubescent docs, if you will.

</dd></dl>

<p>Test::Pod::Snippets's goal is to address those issues. Quite simply,
it extracts verbatim text off pod documents -- which it assumes to be
code snippets -- and generate test files out of them.
</p>
