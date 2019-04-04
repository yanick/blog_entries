---
title: Dancers Just Wanna Have Fonts
url: dancer-plugin-fontsubset
created: 22 jun 2013
tags:
    - Perl
    - Dancer
---

Here's a quick one to warm up...

One of the heavy component of my blog, size-wise, is the 
fonts used by the page headers. Of course, I could easily 
trim down on it by using an image instead, but that'd be rather
sad as one of the raison d'être of the whole thing is to play with
nifty technologies of the future. And what could be niftier, or
more from-the-future than webfonts, I ask you? Rhetorically, that is, because,
really, there are a lot of other niftier things, and more from-the-futuristic.
But that's not the point. The point is... what is the point? Oh yes. Fonts. 

So, yeah, huge ttf files which, really, could be reduced as only a handful of
glyphs are used in the title. Google Font has a [neat
feature](https://developers.google.com/fonts/docs/getting_started#Optimizing_Requests)
where you can request for a subset of characters from a font. How hard it is
to implement a similar feature from within Dancer?

## Step 1. Steal Somebody Else's Hubcaps

Although I'm curious about fonts and all that, learning from scratch how TTF
files are organized seems hard-core. So instead of reinventing the wheel,
why not look on CPAN and... oh lookee, there is `ttfsubset` from
[Font::TTF::Scripts](https://metacpan.org/release/Font-TTF-Scripts) which
seems to do exactly what we want. So, basically, the hard part has already been
done for us. Groovy.

## Step 2. Put Hubcaps on Car. Put Car on Route.

We have the innards required to trim a font, now all we have to do
is to expose it to the world:

``` perl
get 'font/:fontname' => sub {
    my $fontname = param('fontname');

    my $path = "/fonts/$fontname";

    send_error 'font not found', 404 unless -f $path;

    # no text? No job to do
    my $text = param('t') //
        return send_file $path, system_path => 1;

    my @chars = map { ord } sort { $a cmp $b } uniq split //, $text; 

    # generate_subfont encapsulates the magic innards of 
    # 'ttfsubset'
    my $output = generate_subfont( $path, @chars );

    return send_file \$output, content_type => 'application/x-ttf';
};
```

The mechanism is simple: all source *ttf* files are dumped in `public/fonts` (where they can
be accessed directly if we so desire), and any url of the form
`/font/the_font.ttf?t=abc` will return the font subset containing the 
characters passed via the argument `t`.  Technically, we're done!

## Engage Cruise Control

So we now have auto-generated font subsets. But we still have to figure out 
which characters we want. That's a onerous task that would also benefit from
a wee bit of automation. It'd be much better if we could just say

    #syntax: html
    <h1 class="subfont" data-font="myfont">Hello there!</h1>

and have a little jQuery script figure it out:

``` javascript
$(function(){
    $('.subfont').each(function(){
        var characters = $(this).text().split('').sort();
        characters = characters.filter(function(e,i,a){ 
            return characters.lastIndexOf(e) == i 
        }).join('');
        var family = $(this).attr('data-font') + '-' + characters;
        var style = "@font-face { font-family: " + family 
            + "; src: url('/font/" + $(this).attr('data-font') + ".ttf?t=" + characters 
            + "'); }";
        $('body').append( "<style>"+style+"</style>" );
        $(this).css('font-family', family);
    });
});
```

## And Record Everything For Posterity

As a final touch: those subsets will always be the same, so it makes
sense to cache them. For that kind of things, we already have 
`Dancer::Plugin::Cache::CHI` that can help:

``` perl
if( $plugin->use_cache ) {
    *generate_subfont = sub {
        my @args = @_;
        Dancer::Plugin::Cache::CHI::cache()->compute( 'font-' . $args[0] . '-' . join( '', @args[1..$#args] ), sub {
            $_generate_subfont->(@args);
        });
    };
}
else {
    *generate_subfont = sub {
        $_generate_subfont->(@_);
    };
}
```
### All Done, Say Hello To Dancer::Plugin::FontSubset

Add a few options and configurations, and we have 
[Dancer::Plugin::FontSubset](cpan) (also, of course, on
[GitHub](gh:yanick/Dancer-Plugin-FontSubset)), which is bound to be soon joined by a
*Dancer2* sibling.

Enjoy!
