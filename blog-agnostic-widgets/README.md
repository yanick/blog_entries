---
url: blog-agnostic-widgets
created: 2010-10-11 
tags:
    - Perl
    - Catalyst
    - Mason
    - Blog
    - Widgets
    - WWW::Widgets
---

# Blog-Agnostic Widgets

Please, someone stop me if this has already been done elsewhere...

While I was raking the leaves yesterday, I was entertaining thoughts about 
new widgets for [Galuga](http://github.com/yanick/Galuga).  From there, I
began to think that while there's a thousand and one different blog engines 
out there, it's kinda silly that, for each of them, we re-write
almost-identical 
HTML and Javascript for the different widgets and badges we adorn them
with.  Wouldn't be be nice if there was a standard way to write those widgets so that 
we they could be used and shared across all Perl blog engines? 

Cue in [WWW::Widget](http://github.com/yanick/WWW-Widget), probably the most
trivial API ever designed.  Written as a Moose Role, it requires from
wannabe-widget classes only two things: that they pass all configuration
elements at object-creation time, and implement a `as_html()` 
method.  

And that's pretty much it. The role auto-wraps the HTML generated by `as_html()`
in a `div` with two classes, *WWW-Widget* and *WWW-Widget-ThisWidgetClass* 
so that the display can be controlled via CSS.  And, for the
laziness-inclined,  the role also overloads the object's
stringification to be an alias to `as_html()`. 

Bottom-line, in Galuga (which uses Catalyst and Mason), I can now take care
of my widgets by having the following in my configuration:

```html
<widgets>
    <PerlIronMan>
        id yanick
    </PerlIronMan>
    <Twitter>
        username yenzie
    </Twitter>
</widgets>
```

and put this stanza in my template:


```perl
% while ( my ( $widget, $conf ) = each %{ $c->config->{widgets} } ) {
%   my $package = 'WWW::Widget::'.$widget;
%   eval "use $package; 1" or next;
%   $conf ||= {};  # in case there's no configuration item
    <% $package->new( %$conf ) %>
% }
```

The module is not yet available on CPAN, but should be soon (as soon as I
distributionify the code, slap a little bit of documentation on it, and make
sure I'm not reinventing an already existing wheel).
