---
created: 2010-08-02
tags:
    - XML::XSS
    - XML::XPathScript
    - Perl
---

# XML::XSS - Templates and Syntaxic Sugar

The first non-development version of [XML::XSS](cpan) has been released
on CPAN. The big delta since the last blog entry 
(<galuga_entry>xpathscript-reborn</galuga_entry>) is the re-introduction of 
templates, and a generous slathering of overloaded shortcuts for 
stylesheet definitions.

To recap the example I used last time, we were trying to convert
the xml snippet

```xml
&lt;section title="Introduction">
    &lt;para>This is the first paragraph.&lt;/para>
    &lt;para>And here comes the second one.&lt;/para>
&lt;/section>
```

into 

```xml
&lt;h1>Introduction&lt;/h1>
    &lt;p class="first_para">This is the first paragraph.&lt;/p>
    &lt;p>And here comes the second one.&lt;/p>
```

And we saw that one of the ways of doing this is

```perl
$xss->set(
    section => {
        showtag => 0,
        intro   => sub {
            my ( $self, $node ) = @_;
            $self->stash->{seen_para} = 0;    # reset flag
            return '&lt;h1>' . $node->findvalue('@title') . '&lt;/h1>';
        },
    } );

$xss->set(
    para => {
        pre   => '&lt;p>',
        post  => '&lt;/p>',
        process => sub {
            my ( $self, $node ) = @_;

            $self->set_pre('&lt;p class="first_para">')
                unless $self->{seen_para}++;

            return 1;
        },
    } );
```

Now, using all the all-new shortcuts available to us, 
we can perform the same logic with 

```perl
$xss.'section'.'showtag' *= 0;

$xss.'section'.'intro' x= q{
    &lt;% $r->stylesheet->stash->{seen_para} = 0; %>
    &lt;h1>&lt;%@ @title %>&lt;/h1>
};

$xss.'para'.'style' %= {
    pre  => xsst q{
        &lt;p &lt;%= 'class="first_para"' x !($r->stylesheet->stash->{seen_para}++) %> >
    },
    post => '&lt;/p>',
};
```

*Tadah!*

...

Hmm... By the pale green hue that your skin suddenly has developed, I think I
should explain this a little bit more.

<h3>The overloading part</h3>

In order to reduce the amount of typing,
I've (ab)used the `overload` pragma to give the stylesheet
a CCS-ish flavor. Its basic use is

```perl
$xss.$element.$attribute *= $something;
```

and is simply a shorthand for

```perl
$xss->get( $element )->set_$attribute( $something );
```

Likewise, 

```perl
$xss.$element.'style' %= {
    pre  => $pre,
    post => $post,
};
```

is a shorthand for

```perl
$xss->set( $element => {
    pre  => $pre,
    post => $post,
});
```


And, yes, it would have been even better to be able to do

```perl
$xss.$element %= {
    pre  => $pre,
    post => $post,
};
```

but alas it doesn't seem to be possible, as this mix of overloaded operators
confuses the Perl parser to no end. Humbug.

<h3>The template</h3>

The templates are created via the `xsst` function automatically exported by
`XML::XSS`.  They are fairly simple affairs that have the usual tags
(`<% ... %>` to evaluate some code, and `<%= ... %>` to evaluate and print),
augmented by a couple of XML/stylesheet-centric ones (`<%~ $xpath %>` to find
the nodes matching the xpath and rendering them and `<%@ $xpath %>` to print
out the value returned by the xpath). There are a few other tags available
(see the 
<a
href="http://search.cpan.org/~yanick/XML-XSS-0.1.3/lib/XML/XSS/Template.pm">XML::XSS::Template
POD</a> for the thorough listing),
but those four are the principal ones.

And as a last bit of magic, the `x=` operator is overloaded such that

```perl
$xss.$element.$attribute x= q{  Hello &lt;%= $r->stylesheet->stash->{name} %> };
```

is really

```perl
$xss.$element.$attribute *= xsst q{  Hello &lt;%= $r->stylesheet->stash->{name} %> };
```

<h3>What Lies Ahead</h3>

First, I'll let the current functionality simmer down and give it a whirl.
For one, I'm still not sure
if that generous smothering of operator overloads is the most brilliant or
dumbest idea I ever had. Using the stylesheet on a few non-trivial test
applications should answer that question.

Then, next in line is implementing a sane way to expand stylesheets. And, of
course, improving the documentation (which still sucks, albeit slightly less than last time). 
And after that? ... We'll see when we get there, shall we? :-)
