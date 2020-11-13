---
created: 2011-12-04
tags:
    - Perl
    - Moose
    - Template::Declare
    - Mason
---

# Cross-breeding Template::Declare with Moose 

I'm rather fond of [Template::Declare](cpan). Its killer feature, for me,
is how all tags are expressed via Perl-space syntax, which allows me 
to leverage `perltidy` to turn any great unreadable glob of HTML into nicely
indented code (in comparison, my [Mason](cpan) templates always begin
with the best of intention, and end up looking like the indentation fairy went
berserk).  But it also... irk me. In minimal ways. In ridiculous ways. In ways
that I should overlook. But...

I would *so* love to ditch the global template 
inheritance that is defined via 

```perl
Template::Declare->init( dispatch_to => ['MyApp::Templates'] );
```

and go for a per-object mechanism.

And talking of objects, those OO-like features like mixins and delegation are very cool, but 
they end up implementing a new OO system. These days, [Moose](cpan) is my
hammer, and... wouldn't be nifty if the templating system was built using
all that antlered magic?

Logic says that I should just learn to live with those small warts and resist
the urge to write yet another template system. After all, armies of better
hackers went that route, and between [Template::Declare](cpan),
[Template](cpan), [Mason](cpan) and the many other systems out there, 
the chances that I'll come with something better are infinitesimal leaning on
the delusional.

But logic ain't no fun. So... say hello to 
[Template::Caribou](https://github.com/yanick/Template-Caribou). The goal of
that new template system? Steal or be inspired by a maximal amount of
[Template::Declare](cpan) features, while using Moose as the core engine.

Although the project currently has absolutely no documentation whatsoever and
is quite minimal, I was able to get a basic template running. For the rest of
this blog entry, I'll take you on a tour of that basic sample use, peeling
the system from the outside in, hoping that the glitter of the outer layers
will soften the shocks of the abominations of the inner mechanisms.

## Using an already-defined template

That's the easy-peasy part.

<galuga_code code="perl">basic.pl</galuga_code>

We create an instance of the template class `HelloWorld`, passing along some
useful value, and render the thing.  The resulting output is:

<galuga_code code="xml">output.html</galuga_code>

So far, it looks like any other templating system. Things, however, get
interesting when we are...

## Creating the `HelloWorld` template 

This is where the Moose groove sets in. 

<galuga_code code="perl">HelloWorld.pm</galuga_code>

At the base, it is a simple Moose class. It's the assignation of the 
`Caribou::Template` role, as well of the importation of the functions in
`Template::Caribou::Utils` that bring in the templating magic. 

The templates's definition, via the `template` keyword, is very similar of
the way it's being done with `Template::Declare`. The biggest difference is 
how non-tags are emited. `Template::Declare` has `outs` and `outs_raw`,
`Caribou` considers captures everything printed to the file handles *STDOUT*
and *::RAW*.

The tag helping functions are imported from `Template::Caribou::Tags::HTML`
and `MyTags`, the latter being used for the custom tag `my_img`.

Finally, the template that we originally called (`page`) is defined in the
role `MyWebPage`, which we may expect is going to be re-used by several
templates: 

<galuga_code code="perl">MyWebPage.pm</galuga_code>

## Creating Tags

Custom tags are a big bonus to have. And, oh joy, they prove to be quite easy
(if a little messy) to craft via the use of `Template::Caribou::Utils`'s
`render_tag()`.

<galuga_code code="perl">MyTags.pm</galuga_code>

`render_tag()` takes three arguments: the name of the tag to generate, an
optional manipulation function, and the coderef of the tag's inner block.  

Typically, tags will be defined like `foo` is in the example, but the 
manipulation function is there for cases where some sanity checks or
content/attribute 
massaging are desired.  That function gets two arguments: a hashref to the
attributes of the tag, and a ref to the inner content. For example, if we want
a custom `my_h1` that upper case its text and inject some special style,
it can be done with:

```perl
sub my_h1(&) { render_tag( 'img', sub {
    my ( $attrs, $content ) = @_;
    $attrs->{style} .= "; color: red";
    $$content = uc $$content;
}, shift ) };
```


And that's mostly all that one needs to know to use 
Caribou.  

Now, if you want to stay with a good impression of the beast, you should 
probably stop reading here. 
The next sections deal with what's going on behind the curtain and...
it's going to take a turn for the eldritch.

## The templates are methods

Yup, you read that right. The keyword `template` is just a bit of sugar
that does

```perl
sub template { 
    my ( $meta, $label, $sub ) = @_;

    $meta->add_method( "template_$label" => $sub );
}
```

So the template `foo()` becomes the method `template_foo()`. The end-goal,
here, is to make really easy to pepper `after()`, `before()` and
`around()` modifiers all over the place, so that adding a menu would be as
easy as:

```perl
before template_main => sub {
    $_[0]->render( 'menu' );
};
```

Keeping the templates so simple means that the gymnastics to render
them have to be a little more esoteric. What I ended up doing 
was to use global variables, and to matryoshka the hell out of them.


```perl
sub render {
    my ( $self, $template, @args ) = @_;

    my $method = "template_$template";

    my $output = do
    {
        local $Template::Caribou::TEMPLATE =
            $Template::Caribou::TEMPLATE || $self;
            
        local $Template::Caribou::IN_RENDER = 1;
        local *STDOUT;
        local *::RAW;
        local $Template::Caribou::OUTPUT;
        local %Template::Caribou::attr;
        tie *STDOUT, 'Template::Caribou::Output';
        tie *::RAW, 'Template::Caribou::OutputRaw';
        my $res = $self->$method( @_ );

        $Template::Caribou::OUTPUT 
            or ref $res ? $res : Template::Caribou::Output::escape( $res );
    };

    $output = Template::Caribou::String->new( $output );

    print $output unless defined wantarray or $Template::Caribou::IN_RENDER;

    return $output;
}
```


I'll not explain everything in details, but there are a lot of dirty tricks
there. *STDOUT* and *RAW* are localized and tied to private classes that
grooms and redirects them to *$Template::Declare::OUTPUT*. The current
template object is stored in *Template::Caribou::TEMPLATE* such that the
function `show()` can be used instead of `self->render()`. And there is the
heuristic print/return dance at the end that is done to ensure that the
template will DWIM in most of those cases:

```perl
template foo => sub {
    "just print this";
};

template foo2 => sub {
    say ::RAW "just print <this>";
};

template foo3 => sub {
    p { "foo" };
};

template foo4 => sub {
    h1 { 'Foo!' };
    div {
        p { "foo" };
    }
};

 # etc. Trust me, the fun never ends...
```

And... beside a few other twisted implementation details, that's basically it. 

## But does it blends?

I dunno. The next step is to try it for a real project. Probably for the
rewrite of Galuga. But don't you worry: I'll keep you updated. :-)
