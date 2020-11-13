---
created: 2010-12-27
tags:
    - Perl
    - Pod::Manual
    - PDF
    - Moose
    - Module::Pluggable
---

# Pod::Manual Starring in the Timeless Classic "It's a Wonderful PDF"

(Apologies for the truly terrible blog entry title. The Holiday season's
tv programmation is somewhat corrupting me.)

[Pod::Manual](http://babyl.dyndns.org/techblog/entry/pod::manual) was born a
little bit more than three years ago (*three* years? Egad, times *does*
fly...), and because of a severe lack of tuit, kind of lingered in
alpha-land ever since. But now, thanks to the Holidays and a long vacation 
stretch, I had the opportunity to return to the project and 
[do terrible things to it](https://github.com/yanick/pod-manual/tree/xmas).
The code is even more alpha than it was before, and it's now in a post-hack
shamble, but at least it has been moosified and (or so I hope) pushed in the
right direction.

## Good sir, it's been 3 years. We could use a recap.

Oh yes, right. `Pod::Manual` was created of my wish to print out nice manuals
out of the POD of big projects like [Moose](cpan) or 
[Catalyst](http://search.cpan.org/dist/Catalyst-Runtime).  To do that, two big
steps are involved: gathering the raw material and transmutate it into
something that can be printed.

## Step 1: Gather the manuscripts

Perl's POD system serves us well for the *one module = one manpage* model,
but for bigger distributions having quite a few documentation pieces, it has
its weaknesses. To wit:

<dl>
<dt>No order or hierarchy between documents</dt>
<dd>
This is no problem for distributions that have a mere handful of modules, but 
a first glance at, say, [Moose](cpan) is more daunting. Which
documentation should I read first? Which one is important for a user? For
someone who want to play with the guts of the system?  Usually, the problem is
solved by having a <code>Foo::Manual</code> or <code>Foo::TableOfContent</code> pod document thrown in the 
mix, but it'd be nice to have a way to physically gather together the
different documents into a big one (or several big ones aimed at different
audiences).
</dd>
<dt>Repetitive sections</dt>
<dd>
While it makes sense to have the <code>VERSION</code>, <code>AUTHOR</code> and <code>COPYRIGHT</code> sections 
present in the documentation of every module of a distribution, they sure
become great paper-wasters when they are printed out.  Wouldn't be great, for
a paper version of the PODs, to just skip over sections that we don't care
about (say the <code>VERSION</code> that is being printed on the cover page anyway)?  And
for sections that we *do* care about, but that don't change between PODs of a
same distribution, maybe it would make sense to print it only once, in an
appendix?</dd>
<dt>No table of content</dt>
<dd>
Unfortunately, paper doesn't offer full-text searches. In consequences, 
if a POD results in more than 40 printed pages, I usually find myself craving
a table of content, with page number references. And, likewise, I want my
pages numbered, with titles and stuff in the headers and footers. 
</dd></dl>

### Building the manual

And that's where `Pod::Manual` fits in.  Let's say that I want to build a
manual for [Dist::Zilla](cpan). Then I could do:

<SnippetFile src="dist-zilla.pl" />

Let's go over that again, in a more detailed fashion.

What I did was to first create the 
the class `Pod::Manual::DistZilla` that inherits from `Pod::Manual`. (Mind you, 
creating a subclass is not strictly necessary, but it helps re-use and, as
we'll see in a few lines, allows for a nifty trick with 
[Module::Pluggable](cpan)). 

```perl
package Pod::Manual::DistZilla;

use Moose;

extends 'Pod::Manual';

use Module::Pluggable search_path => ['Dist::Zilla::Plugin'];
```

Then, because we're using a class, I'm grabbing the singleton instance for it.

```perl
my $manual = __PACKAGE__->master;
```

I assign the title of the manual.

```perl
$manual->title('Dist::Zilla');
```

I don't want to see the `VERSION` sections.

```perl
$manual->ignore( ['VERSION'] );
```

And I want to have one instance of the `COPYRIGHT AND LICENSE` section 
punted to the appendix (with the rest being ignored).

```perl
$manual->move_one_to_appendix( ['COPYRIGHT AND LICENSE'] );
```

That done, I can now add the main `Dist::Zilla` modules I want to see in the manual. 

```perl
$manual->add_module( [ qw/
    Dist::Zilla
    Dist::Zilla::Tutorial 
/ ] );
```

Because I can't resist being a cleaver monkey, I used
`Module::Pluggable` to throw in all the 
`Dist::Zilla::Plugin::*` modules that I have installed on my
machine. But since those modules might be coming from other
distributions than the core `Dist::Zilla`, I don't want to ignore
the `VERSION` or `COPYRIGHT` sections for them.


```perl
$manual->ignore( [] );
$manual->move_one_to_appendix( [] );

$manual->add_module( [ $manual->plugins ] );
```

Finally, we drop a `$manual;` as a last piece of cleverness.  As `$manual`
evaluates to `true`, our code can be used as a normal module:

```perl
use Pod::Manual::DistZilla;

my $manual = Pod::Manual::DistZilla->master;

print $manual->as_docbook;
```

or used with `do` if we don't want to install the module or play with `lib`.

```perl
my $manual = do 'path/to/DistZilla.pm';

print $manual->as_docbook;
```

(That's going to be useful later on to make the command-line interface as
supple as possible.)

## Step 2: Warm up the printing press

### At the core: DocBook

Now we have our manual object, but we still have to output it in some
useful format. `Pod::Manual` is using
[DocBook](http://www.docbook.org/) as its base format, and we can 
get to it by doing:

```perl
print $manual->as_docbook;
```

Or, if we have a `css` file that we want to associate to the resulting
DocBook:

```perl
print $manual->as_docbook( css => '/path/to/file.css' );
```

### Beyond DocBook

`DocBook` is nice as a starting point, but let's not forget that our
end-goal is to have something printable, like a `pdf` file.

The tricky part with that, though, is that not only the roads to get
to a `pdf` file are numerous, but they are also usually relying on third-party
software (`XSLT` stylesheets and transformation engines, `LaTeX`, etc) that
might or might not be present on any given machine.
Trying to implement a single transformation method would probably doom
`Pod::Manual` to work only on my own system. So I decided to take the plugin
approach instead. Manual formatters are roles that can be slapped on
`Pod::Manual` classes, and should provide a <code>as_<i>format</i></code> and/or a
<code>save_as_<i>format</i></code> method.  That way we can let the user who want
to generate the manual pick himself the roles he'll need to get there.
To be nice, we can even provide a little command-line utility script
that can do that for us:

<SnippetFile src="./podmanual.perl" />

### A first PDF formatter using Prince

For a first way to get to the golden `pdf` format, I went the
easy way and used the [Prince](http://www.princexml.com/) XML
to PDF translator. While `Prince` is not free, 
they do offer a free version of it for non-commercial uses which
add a little icon on the first page -- something I can quite live with.
Its main appeal -- beside the gorgeous output it produces -- is the 
direct `DocBook` to `pdf` translation. Only a `css` stylesheet is required
and the little translation engine does all the magic.

So what I did was to encapsulate the work in
`Pod::Manual::Formatter::PDFPrince`:

<SnippetFile src="./PDFPrince.perl" />

And now, provided that `prince` is installed on our machine, we can generate
our first `pdf` from the script describe in the first section:

```bash
$ podmanual --formatter=PDFPrince \
            --as=pdf              \
            --output=dist-zilla-prince.pdf examples/dist-zilla.pl 
creating d.pdf...
done
```

The resulting `pdf` is [here](./dist-zilla-prince.pdf).  The
format still has to be tweaked to be truly pretty, but... we have a table of
content! we have pages that look like pages from a real book!  Woohoo!

### PDF the good ol' Knuth fashioned way

For those who prefer good old `LaTeX` processing, I'm also 
working on upgrading the powerful, but slightly eldritch
`Pod::Manual::Docbook2LaTeX` into `XML::XSS::Stylesheet::Docbook2LaTeX`.
That's a topic for another blog entry, but once I'm done, we'll be able to get
`LaTeX` output by doing

```bash
$ podmanual --formatter=LaTeX --as=latex \
    --output=dist-zilla.latex examples/dist-zilla.pl 
```

and use it to generate the `pdf` via

```bash
$ podmanual --formatter=LaTeX,PDFLaTeX --as=pdf \
    --output=dist-zilla.pdf examples/dist-zilla.pl 
```

## What Lies Ahead

A heck of a lot of work lies ahead.  The hardest part if to juggle through the 
different formats.  In some cases (*cough* LaTeX *cough*), I have to get
reacquinted with it as it's been a very long while since I last used it. And
then there's fiddling with the code such that doesn't look too much like the logic
wasteland it currently is. Oh yes, and there's that documentation thing I
should also do at some point.

*Buuut* I wanted to share the work of the last few days, just to let the people
that have been looking around for a fresher copy of the `Moose` and `Catalyst`
manuals I'd generated the first time around know that there's reason to hope
that a new version of those should be available in a not-so-distant future.
:-)


