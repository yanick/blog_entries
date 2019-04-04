---
url: caribou-update
format: markdown
created: 2013-02-22
tags:
    - Perl
    - Template::Caribou
---

# Showing Off Template::Caribou

> **Fair warning:** 
> I am fully aware that extolling the virtues of your all-new,
> all-shiny templating
> system has high changes to end up mixing the obnoxiousness of a new dad recklessly shoving pictures of his mini-Churchill 
> down your field of vision ("*isn't simply adooorable?*") with the
> self-delusion typically reserved for inventors of perpetual motion engines ("*Sure, there are other
> templating systems. But this one is... special.*"). It that regard, what
> follow ain't going to be pretty one bit.
>
> So if self-indulgent ramblings
> aren't your thing you *might* want to close this browser tab already. But if
> you are here for the entertaining factor... make yourself comfortable, the
> delightful freakshow's about to start!

## Recap

As template systems are all about being a coder-friendly layer between 
inner logic and final output, it's no wonder there are so many of them out
there, for there is no two coders in existence sharing the exact same
definition of what's "friendly'. Don't believe me? Just 
try to push your `.vimrc` to any of your colleague and behold the resulting
tollé; you'll see what I mean.

In any cases, template-wise, I've always had a soft spot for
[Mason](cpan). I've also been attracted to
[Template::Declare](cpan), but it wasn't *exactly* what I wanted.  
So, what was bound to happen happened, and on a cold, wintery night my very own 
[Template::Caribou](http://babyl.dyndns.org/techblog/entry/caribou) 
was born. 

For the longest time, it remained a very rough prototype. But
lately, I began to use it a little more seriously (mostly in my Newsmill and 
Galuga rewrite projects). And since today I finally managed to [write some
half-decent documentation](https://metacpan.org/module/YANICK/Template-Caribou-0.2.0/lib/Template/Caribou/Manual.pod) 
(with heavy emphasis on the "half" part of it) and release it to CPAN, I thought it was the perfect time to hop on the soap
box and count the ways this new antlered wonder might be poised to rock your socks.

## Way no. 1 - It's a Role 

... which means that it can be slapped on any regular Moose class that needs a 
HTML view. Which can be used for the obvious, or for the magnificently weird: 


    #syntax: perl
    package ShowMethods;

    use Moose::Role;
    use Template::Caribou;
    use Template::Caribou::Tags::HTML qw/ :all /;

    with 'Template::Caribou';

    template methods => sub {
        my $self = shift;

        ul {
            li { $_  } for $self->meta->get_method_list;
        }
    };

    # then later on
    use MyClass;
    use Moose::Util qw/ apply_all_roles /;

    my $thingy = MyClass->new;

    apply_all_roles( $thingy, 'ShowMethods' );

    print $thingy->render('methods');


## Way no. 2 - You Can Still Write Straight HTML If you Want To

It's nice that a template system offers you shortcuts and cleaner ways to
write HTML, but sometimes you just
want to pound raw HTML code to get you started, and clean up the (now working)
mess afterward.  Or you want to import already existing HTML and convert it
afterward, as time allows. Happily, Caribou allows that:

    #syntax: perl
    template page => sub {
        print ::RAW <<'END';
    <html>
        <head> ... </head>
        <body> ... </body>
    </html>
    END
    };

Granted, it looks silly, but paves the way for subsequent rewrites that might
look like

    #syntax: perl
    template page => sub {
        html {
            print ::RAW <<'END';
            <head> ... </head>
            <body> ... </body>
    END
        }
    };

then

    #syntax: perl
    template page => sub {
        html {
            show('head');
            show('body');
        }
    };

    template head => sub { print <<'END';
        <head> ... same ungodly mess as before, 
            but encapsulated in its own template </head>
    END
    };

and ultimately

    #syntax: perl
    template page => sub {
        html {
            show('head');
            show('body');
        }
    };

    template head => sub {
        head {
            title { "finally all Cariboutized" };
        }
    };


## Way no. 3 - Templates Can Go In Their Own Files

Thanks to the `Template::Caribou::Files` role, templates for a class can be
defined in separate files so that you don't end up with a gigantic class. 
Using that pattern, a template class will look nice and clean:

    #syntax: perl
    package Greeter;

    use Moose;
    use Template::Caribou;

    with 'Template::Caribou';

    with 'Template::Caribou::Files' => {
        dirs        => [ 'views/greeter' ],
        auto_reload => 1,
    };

    has name => (
        is       => 'ro',
        isa      => 'Str',
        required => 1,
    );

    1;

and will be able to import `.bou` templates off the given directories, which
will look like

    #syntax: perl
    #( $salutation = 'Howdie' )
    
    body {
        h1 { join ' ', $salutation, $self->name };
    };

The `.bou` templates are generated via [Method::Signatures](cpan), so not
only we don't  have to worry about shifting our `$self` but we can also be
fancy, like here, and give it a custom signature.

## Way no. 4 - Auto-Refresh For Development Tinkering

Did you notice the *auto_reload* option in the previous example? As the name suggests, if that
option is set to true, the class will rescan all template directories before 
any new render, which is awesome for development. Right now, for example, in
the [Dancer](cpan) component of Newsmill, I have the action:

    #syntax: perl
    get qr{/edition/(\d+)} => sub {
        my( $nbr ) = splat;
        my $issue = rset('Edition')->find( $nbr )
            or return send_error "Issue '$nbr' not found", 404;

        return Newsmill::View::Issue->new(
            issue => $issue
        )->render('page');
    };
    
Once that is there, I can fiddle with the `.bou` templates all I want without
having to restart the application.

(and, yes, there is a `Dancer::Template::Caribou` lying somewhere in the near
future. But let's not get ahead of ourselves, shall we?)

## Way no. 5 - Templates Are Peopl-- No, Wait, It's Perl Code

One of the reason I prefer `Mason` over `Template::Toolkit` is the direct
access the former gives us to Perl syntax. Unfortunately, because the
resulting templates are a mix of Perl and HTML, even with the best
of intentions they always end up looking like giant hairballs.  
There is now [Mason::Tidy](cpan) to help with that, but as long as there
is HTML involved, let's face it, it's always an uphill battle.

On the other hand, Caribou's templates are pure Perl, which means that a clean
indentation of the code is always only a call to [Perl::Tidy](cpan) away.

It also means that the indentation in the source doesn't reflect on the
output. So the nicely indented 

    #syntax: perl
    html {
        head {
            title { "Hi" };
        }
    }

will become the succinct

    #syntax: xml
    <html><head><title>Hi</title></head></html>

by default (with soon an option to pretty print it for debugging purposes).

## Way no. 6 - Tags

This one is kinda of a given. But since all tags are just Perl functions, it's
worth to point out that they therefore can be quite versatile.

    #syntax: perl
    # in page.bou
    use Template::Caribou::Tags::HTML ':all';

    html {
        body {
            div { attr class => 'left_column';
                show( 'widget' => $_ )
                    for $self->all_widgets;
            };

            div { attr class => 'main';
                print ::RAW $self->body;
            };
        };
    }

    # in widget.bou
    #( $widget )
    div {
        attr id    => $widget->id,
             class => 'widget';
        print ::RAW $widget->content;
    }

## Way no. 7 - Semantic Tags

Look back at the example above. Isn't it silly that we mean
'the left column', and we have to write it 

    #syntax: xml
    <div class="left_column"> ... </div>

? Wouldn't be nicer to take care of the mechanics once, and then use the 
high-level name forevermore, like so:

    #syntax: perl
    # in page.bou
    use Template::Caribou::Tags::HTML ':all';

    # define my custom divs
    use Template::Caribou::Tags
        map { mytag => { -as => $_, class => $_ } }
            qw/ left_column widget main /;

    html {
        body {
            left_column { 
                show( 'widget' => $_ )
                    for $self->all_widgets;
            };

            main { print ::RAW $self->body; };
        };
    }

    # in widget.bou
    #( $widget )
    widget { attr id => $widget->id;
        print ::RAW $widget->content;
    }

## Way no. 8 - Extended Tags Just For HTML

A lot of templating systems try to stay generic. Caribou also does, as far as
`Template::Caribou::Tags::HTML` is concerned. But then there is 
`Template::Caribou::Tags::Extended`, which acknowledges that we are
hip-deep in HTML, and optimizes in function of that. Are you sick and tired to
look up what is the right `<link>` invocation for stylesheets? Well, I am, and
so Caribou's bag of extended tags contains

    #syntax: perl
    css_include "/my.css";

which takes care of all the nitty-gritty details. The shortcuts 
go from the simple, like
    
    #syntax: perl
    a { attr href => 'http://...'; "some link" }

that can become

    #syntax: perl
    anchor 'http://...' => "some link";

to the more... powerful. Like this:

    #syntax: perl
    head {
        # yes, this will convert a LESS stylesheet into classic 
        # CSS
        less q[
            #header {
            h1 {
                font-size: 26px;
                font-weight: bold;
            }
            p { font-size: 12px;
                a { text-decoration: none;
                &:hover { border-width: 1px }
                }
            }
            }
        ];
    };
    body {
        markdown q{
    Because writing a paragraph using Markdown is
    *much* easier on the eyes than using straight 
    HTML.  
    };
    };


## Way no. 9 - It's Pretty Easy To Create Tag Libraries For Anything

Case in point. Newsmill is built with
[Bootstrap](http://twitter.github.com/bootstrap). With basic tags, I could do
things like

    #syntax: perl
    div { attr class => 'row-fluid'; 
        div { attr class => 'span8 offset2";
            ...;
        };
    }

But it's much more legible if we go one level up the semantic ladder:

    #syntax: perl
    use Template::Caribou::Tags::Bootstrap 
        row  => { -as => 'body_row', fluid => 1 },
        span => { -as => 'body_span', offset => 2, span => 8 };

    body_row {
        body_span {
            ...;
        };
    }

## What Lies Ahead

As mentioned earlier, as of today Caribou has some documentation, but it's
still sparse and needs some serious love. The infrastructure is now in working
order (or, at least, can be used for small projects), but needs some cleanup. 
The different tag libraries are there, but need to be thoroughly populate. A
`Dancer::Template::Caribou` should eventually see the light of day to bring
the whole solution together. 

So yeah, there are still a lot of work to be done. But I must say, while I'm 
still half-convinced that the whole endeavor is nothing but an exercise in 
hubristic yak shaving, I kinda begin to think there might be something 
special in there. Something special, and adooooorable. 
