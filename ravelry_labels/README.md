---
created: 2015-01-02
tags:
    - JavaScript
    - Ravelry
---

#  Printing Yarn Labels with QR Codes

And now, for something different, a little bit of
JavaScript consumer-grade duct-taping...

As you probably know, these days I have an addiction involving needles. 

...  No, *no*, **no**, I'm not talking about meth. I mean the other addiction, the one
that involves stitches.

... No, not cage fighting! I mean the one which involve huge intake of fibers.

*sigh* 

Knitting, okay? I'm talking about knitting.

So, anyway, one thing that I regularly do is to lose
the bands going 'round my yarn. Which, if you are not a knitter yourself,
is terribler than it sounds. Without the label, you're likely not to remember 
the yardage, the dye lot and all that good stuff.

As most yarn crafters these days, I'm on [Ravelry](http://ravelry.com) 
(as [yenzie](http://www.ravelry.com/people/yenzie), if you want to say 'hi!').
Amongst other things, under your Ravelry profile, 
you can record your stash o' yarn. So I thought, all the information
is there. Wouldn't it be cool to be able to print new labels from it?

Yes, yes it would be. So I wrote a [GreaseMonkey
script](https://github.com/yanick/greaseyanick/blob/master/Ravelry_Stash_Labels.user.js)
that does just that.  If you have greasemonkey installed on your browser, you
should be able to install it via [this link](https://github.com/yanick/greaseyanick/raw/master/Ravelry_Stash_Labels.user.js).

What does it do? It adds a little 'print label' in the stash set of buttons:

![print label](__ENTRY_DIR__/print.png)

If you click it, it'll generate a label, all ready to print, 
with the information gathered from the page:

![label](__ENTRY_DIR__/label.png)

Notice the QR code in there? If you have a phone/tablet with a QR reader on it,
you can point it to your balls, click, and you'll be sent directly
to your stash page.

Enjoy!

![labelled yarn](__ENTRY_DIR__/labelled.jpg)








