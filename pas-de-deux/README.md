---
url: pas-de-deux
format: markdown
created: 2012-01-25
tags:
    - Perl
    - Dancer
    - Dancer::Template::TemplateDeclare
---


# A Quick Pas de Deux with Dancer

This is going to be a short one, but potentially useful for anybody writing
a Dancer template module, or just plain curious about [Dancer](cpan)'s guts. So here
goes:

A few weeks ago, it came to my attention that Dancer's
`Dancer::Template::Abstract`, the base class for its template modules,
added a test to verify that the template it receives as an argument is really
a file. Yay. Sanity tests are awesome.  Except... what happens when a
templating system is not file-based? A lot of exceptions and a very sad web
application, that's what happen.

If you haven't guessed yet, yes, there is at least one non-file-based 
`Dancer::Template::*` module out there:
[Dancer::Template::TemplateDeclare](cpan).  And who is the maintainer of
that module? ... aw, come on. <i>Surely</i> you can infer that one. 

So, well, yeah, `Dancer::Template::Abstract` was suddenly a killjoy for poor
`D::T::TD`. And since the Dancer team was, and still is, very busy bringing
Dancer 2 into this world (YAY!) and are up their earlobes in placental duties,
I knew it was a thing I would have to resolve by myself. Dirty Harry style.

As it turned out, once I peeked, proded and understood how `D::T::A` works
under the hood, a decent(ish) solution wasn't too hard to come by.  What I elected
to go for was a classical "show the guards what they want to see while you
keep your stash under the mattress" manoeuver. 

To do the stashing, we augment the method `apply_renderer()` to do our leger
de main before any rendering shenanigan begin:

```perl
sub apply_renderer {
    my ( $self, $view, $tokens ) = @_;

    $tokens->{template} = $view;

    return $self->SUPER::apply_renderer( $view, $tokens );
}
```

Now that our template is safely tucked away, we can get busy and pull the wool
over the object's eyes. This is made easy by the method `view()`, which is
supposed to take in the template name and return the corresponding file.
Instead, we'll make it return something else that will always exist:

```perl
sub view { $FindBin::Bin }
```

I know what you're going to say. *$FindBin::Bin* is a directory, not a file.
As luck would have it, the test in `T::D::Abstract` is `-e` and not `-f`, so
we are okay. If it hadn't been, we would just had to use `__FILE__` or
something else.

And that's pretty much it. There is still the business of retrieving the
stashed template in `render()`, but that's easily done:

```perl
sub render {
    my ($self, $template, $tokens) = @_;

    # just in case render() is called directly
    $template = $tokens->{template} || $template;

    return Template::Declare->show( $template => $tokens );
}
```


With that, everything is back to normal. Now, all I need is a little bit of
time to cook up a patch to make Dancer2 a little more forgiving of `T:D::TD`
and its file-less kin. 

