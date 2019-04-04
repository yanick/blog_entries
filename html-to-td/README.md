---
url: html-to-td
created: 2010-12-20
tags:
    - Perl
    - Template::Declare
    - XML::XSS
---

# Generating Template::Declare Code from a HTML Baseline

For the templating system of my web applications, I usually go for
[HTML::Mason](cpan).  It's a wonderful system but, as it 
mixes Perl code with HTML, no matter how hard I try to be well-behaved,
my templates always seem to grow into giant miss-indented smorgasborgs.

Because of that, recently I've also been playing around with 
[Template::Declare](cpan).  As the templates of `Template::Declare` are
pure Perl, not only do I have a fighting chance to keep my indentation 
consistent, but if I fail, [Perl::Tidy](cpan) is there to save my bacon.

Now, one thing with `Template::Declare` is that if I already have some
HTML, writing the template from scratch is a little bit daunting.  On the 
other hand, wouldn't that conversion be a perfect occasion to showcase the
latest development on my own XML templating system, [XML::XSS](cpan)?
Well, yes, I believe it would. :-)

In the latest development of `XML::XSS`, we can not only create stylesheets as
classes, but I've introduced a `style` keyword that makes the syntax much
cleaner. Follow me, I'll show you.

First, nothing too fancy. We just create a stylesheet called
`XML::XSS::Stylesheet::HTML2TD` that inherits from `XML::XSS`.

<galuga_code code="Perl">part1.pl</galuga_code>

And then, we begin with the fun stuff.  For all HTML elements,
we want to morph

    <div class="[..]"> [..] </div>

into something like

    div { attr { class => "[..]" }; outs "[..]"; }

Since we want all HTML elements to be transformed, we use the catchall element
of the stylesheet:

<galuga_code code="Perl">part2.pl</galuga_code>

For the text, we want to wrap it with calls to `outs`.  Except for text nodes
that are nothing but empty spaces, which we'll gladly skip:

<galuga_code code="Perl">part3.pl</galuga_code>

For the pièce de résistance, since we'll eventually ask `Perl::Tidy` to
clean up our code, why not do it directly as we are transforming the document?

<galuga_code code="Perl">part4.pl</galuga_code>

And we are done.  Now we can take a semi-badly formated HTML snippet like this one,

<galuga_code code="xml">snippet.html</galuga_code>


and pass it through `XML::XSS` very new `xss` command-line utility to get
the corresponding `Template::Declare` code:

<galuga_code code="bash">final.bash</galuga_code>


There is still a lot to do, but I'm rrrreally liking the direction `XML::XSS` is 
taking. 
