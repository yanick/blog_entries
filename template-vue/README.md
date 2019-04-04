---
created: 2017-11-18
tags:
    - vue
    - javacript
    - perl
    - template
---

# Vue to a Perl

So, this week I was working on adding relationalish features to 
[DBIx-NoSQL-Store-Manager][], ostenciably to add tagging
functionality to my blog engine. Which is good, but now that I'll have tags, 
I'll also have to change the templates of the blog
to incorporate those tags.

Right now I'm using [Template::Caribou](cpan:Template::Caribou), a Moose-base template system 
written by your truly. And while I still like it, I'm also playing a lot with
[Vue](https://vuejs.org) theses days and really, really like the way it does its single
component `.vue` files. So I began to think about server-side rendering.

But then I thought *hmmm.... when I say server-side, I really mean that I
don't care about the reactive magic of Vue, just its template style. So I
wonder, yes, I wonder... how hard would it be to implement it in Perl?*

Yes. That's right. I'm about show you how to implement a very rough, but
working implementation of the Vue template style in Perl. Because that's
exactly what the
world needs. Another template module. 

## The Single Component File, &agrave; la Perl

## hackthrough

### ./template.txt

So in Vue.js, a single-component file will look something like this.

### ./main.perl

For our Perl version, we'll use modules to be our components, and we will
use Perl's natural instinct to ignore POD directives to put the template
smack there at the top.

### ./entry.perl

And to make the example interesting, we're adding a subcomponent. With
it, we'll be exercising the import of sub-components, `v-for` iterations,
`v-if` conditionals, `{{`interpolations`}}` and attribute `:binding`s.


##/hackthrough


## From Single Component File to good ol' regular Perl

As seen in the code above, I'm already leveraging some Perl goodies.
The template itself will be using [Moose](cpan:Moose), and the templating voodoo will be
encapsulated in the role `Template::Vue`. For now props are simply attributes
of the template's object, and the sub-components are defined via a
`components` attribute. I could have gone and began to DSL in new `props` and
`components` keyword, but for an initial prototype, we can stay with
(relatively) vanilla Moose.

But there is still the template itself that is not yet within our coding
clutch. Well, that's hardly a problem.

## hackthrough

### ./tv1.perl

First things first. We create the role.

### ./tv2.perl

... then we add the `components` attribute, which defaults to be boring as all
hecks.

### ./tv3.perl

Then we add the `template` attribute. 

To extract the template, we find where
the module lives, and we munge the file like savages.

Eventually, we'll be
more civilized and use a POD parsing module. But for now, it'll do.


##/hackthrough

## From template to final output

With that, we have all the pieces we need. Next step: let's process that
template. 

If we look at it, the rendering of a `Vue` template has several steps.
There is the interpolation of the mustache-like expressions in the 
template. There is the exclusing of tags that don't satisfy their 
`v-if` condition. There is the iteration for the tags with a `v-for`
attribute. And there is the interpolation of sub-components. 

Let's deal with
them one by one.


## Step 1: Mustache interpolation

So, yeah, Vue uses a syntax that is close to Mustache. Very close. So very
muchly close that one could be tempted to use
[Template-Mustache](cpan:Template-Mustache)....

## hackthrough

### ./tv3.perl

Remember the template we already have?

### ./tv4.perl @4,5

Bam. 

It's now Mustache-enabled, with its context taken
from the object's attributes.

(NB: at the time of this writing, one itsy bitsy patch needs to be pushed to
`Template::Mustache::Trait` so that it works in that example. I plan to
release it within the week.)


## /hackthrough

### Step 2: `v-if`

## hackthrough

### ./tv5.perl @1

Now we're beginning to manipulate the DOM of the template. For that,
we'll use [Web::Query](cpan:Web::Query), which is heavily inspired from
jQuery.

### ./tv5.perl @9

Basically, we find all nodes that have a `v-if` attribute...

### ./tv5.perl @10,13-16

...since this is a protype, we're slightly gross and assume blindly that the
first token of the expression is a variable to resolve as per the context, and
the rest is a Perl expression. Which is... soooomewhat reasonable.

### ./tv5.perl @13

In any case, if the condition turns out to be false, we delete the node and
never speak of it again.


##/hackthrough

## Step 3: Bindings

## hackthrough

### ./tv6.perl @4

For the bindings, it's almost the same tactic. We go through **all** the
nodes.

### ./tv6.perl @8

We then filter on those that have attributes prefixed with colons. 

The code is
a little on the ugly side because Web::Query doesn't allow to get all
attributes easily. I'll also try to fix this presently.

### ./tv6.perl @11-13

Anyhoo, we populate the attribute `foo` with whatever the variable or method given in
`:foo` interpolate into given the context.

Again, we're playing fast and loose, but we want we could come back and parse
less blindly what is in `:foo`. But that's just finickling around.

##/hackthrough

## Step 4: iterations


## hackthrough

### ./tv7.perl @7

For the `v-for` iterators, same procedure as usual. We look at all
nodes with `v-for` attributes...

### ./tv7.perl @14-20

... and for every item of the list iterate over we make a copy of the tag,
augment the template context with the iteree, and invoke the MIGHTY POWER OF
RECURSION!

ALL* HAIL THE RECURSION GODS!

(*all includes the Recursing Gods themselves, natch)


##/hackthrough

## Step 5: Sub-components

## hackthrough

### ./tv8.perl @8

Last bit, the sub-components. 

Here we find nodes which tag name is the name of a component.

(for now it's assumed that the tag name of the component `Example::Foo` is
`foo`)

### ./tv8.perl @11-12

For those tags, we collect all the attributes, which will be the props of the
sub-components.

### ./tv8.perl @15

And since the sub-component is also a template and only needs to be fed its
props to do its thang, we go ahead, create the object and render it.


##/hackthrough

## BEHOLD!


## hackthrough

### ./tv9.perl

And we are done. With the code we did, plus that last 
method that interconnect the pipeline....

### ./tv10.perl

... we now have a set of components that we can call thus...

### ./tv12.txt

...will give us that.

##/hackthrough

Now, it's not like I just recreated Vue. The reactive part of it really the
*piece de resistance*, and the template and single file component format are
merely delicious, peripheral trimmings. And a lot of parts are at best
penciled in.

But... it's in (arguably) working condition. 

And the `Template::Vue` role as
it stands weights **110** lines. 

Of which 25 are **empty**.

(you can check yourself: the code is on
[GitHub](https://github.com/yanick/Template-Vue))

So, yeah, I guess what I'm trying to say is


*Tadah*.



[DBIx-NoSQL-Store-Manager]: cpan:DBIx-NoSQL-Store-Manager
