---
url: taming-pod-weaver-2
created: 2011-10-23
tags:
    - Perl
    - Pod::Weaver
    - POD
---

# Taming Pod::Weaver, part 2

In our last episode, we began our journey into the wonderful and only slightly
scary world of [Pod::Weaver](cpan). By the end of the blog entry, we victorously
managed to, hum, mimic `perldoc -u`. Not terribly impressive, maybe, but
a necessary baseline for the upcoming niftiness. 

Niftiness that begins with
today's installment, as we are going to take a closer look at all the Pod::Weaver gnomes
and fairies that we can enlist to help create our POD.

## The Weaver's Bestiary: Plugins, Sections and Bundles

All actions performed to the POD are gone via plugin modules that
are (typically) invoked via the `weaver.ini` configuration file. 

While the extent
of what a plugin module will do is ultimately determined by the
role it implements (more on that in a future blog entry), they are
typically classified by their functionality: **section** modules insert pieces
of documentation in the generated POD, **plugin** modules transforms the input
POD, and **pluginbundle** modules are handy aggregates of individual plugins.

All three kinds of module are invoked similarily in the configuration file.
For example, the configuration

    #syntax: bash
    [@YANICK]

    [-NormalizeCapitalization]
    skip_headers = head2, head3

    [Generic / DESCRIPTION ]

has the bunle *YANICK*, the straight plugin *NormalizeCapitalization*
and the section plugin *Generic*. Each of them can be given parameters
(*NormalizeCapitalization* has the parameter *skip_headers*), as well
as a name (in the example, *DESCRIPTION* for *Generic*). The name,
as we will soon see, is typically used as a shortcut for one of the
parameters.

### *Section* Plugins

The most common plugins you'll likely use, they are the ones
that insert pieces of documentation in the generated POD. 
They exist under the namespace `Pod::Weaver::Section::*`.

#### Pod::Weaver::Section::Generic

The most basic of the bunch is undubitously `Pod::Weaver::Section::Generic`,
which takes the section of the original POD corresponding to its name and drops it 
in the generated POD.  For example, using the configuration

    #syntax: bash
    [Generic / SYNOPSIS]
    required = 1

    [Generic / DESCRIPTION]
    required = 1

    [Generic / BUGS]

    [Generic / SEE ALSO]

and the original POD

    #syntax: perl
    =head1 SEE ALSO

    * L<Pod::Weaver>

    =head1 DESCRIPTION

    Yadah yadah

    =head1 SYNOPSIS

        ...

    =head1 IRRELEVANT

    This section is not that important, after all.

we would get

    #syntax: perl
    


Err.. Nothing? 

... I'll spare you the details of the head-scratching and sleuthing
that went on to discover it, but as it turns out two base plugins have to be 
included in the configuration if we want anything to happen. I'll explain
in more details in the next section, but for the time being just trust me and
add two lines to the configuration:

    #syntax: bash
    [-EnsurePod5]
    [-H1Nester]

    [Generic / SYNOPSIS]
    required = 1

    [Generic / DESCRIPTION]
    required = 1

    [Generic / BUGS]

    [Generic / SEE ALSO]

and then, *tadah*:

    #syntax: perl
    =pod

    =head1 SYNOPSIS

        ...

    =head1 DESCRIPTION

    Yadah yadah

    =head1 SEE ALSO

    * L<Pod::Weaver>

    =cut

The sections are generated in the order that we picked them. The
*IRRELEVANT* section, as it has not been explicitly picked,
is not there. On the flip side, there is no *BUGS* section in the original
POD, so nothing appears in the generated POD. If we wanted that section to be
mandatory and have the weaver
to throw a fit if it's not present, 
we could set its 
*required* parameter to *true*, like we did for the *SYNOPSIS* and
*DESCRIPTION* sections.
the document without it.

Of course, this is only the beginning. Some of the section plugins will inject 
boilerplate text ([Pod::Weaver::Section::Bugs](cpan), 
[Pod::Weaver::Section::License](cpan)),
and yet others,
like [Pod::Weaver::Section::Collect](cpan), will
either introspect the code or use custom pod commands to generate
their given sections.

### Straight-forward plugins

Those are the plugins that live under the namespace `Pod::Weaver::Plugin::*`,
and are prefixed by a minus sign in the configuration file. They 
typically will inspect or groom the input POD.  

For example, 
[Pod::Weaver::Plugin::EnsureUniqueSections](cpan) is doing exactly what it says on
the can, it will issue warnings if duplicate sections are found in the 
generated POD, and [Pod::Weaver::Plugin::Encoding](cpan) will add an
explicit '`=encoding`'
command to the generated POD if none is already present.

As mentioned in the previous section, there is also the two core 
plugins 
[Pod::Weaver::Plugin::EnsurePod5](cpan)
and 
[Pod::Weaver::Plugin::H1Nester](cpan)
that should always be invoked in the configuration. The first one sanitizes the
input POD, whereas the second change the internal [Pod::Elemental](cpan) representation of the POD
DOM such that its elements are all contained by the '`=head1`' sections of the
document. Yes, this is slightly confusing. It's all related to the
Pod::Elemental guts of the underlying POD DOM, which should be transparent to 
Pod::Weaver end-users, and should be automatically dealt with 
behind the scene. But, for the time being, it is  what it is, 
so just take my word for it: add the two magic lines

    #syntax: bash
    [-EnsurePod5]
    [-H1Nester]

to all your `weaver.ini` files, and happiness will ensue.


### Plugin Bundles

And then there are plugin bundles, living under the namespace
`Pod::Weaver::PluginBundle::*`, and prefixed by an '@' in the configuration.
Just like their [Dist::Zilla](cpan) cousins, they are a handy way to aggregate 
many plugins together and turn a 30-section configuration file into:

    #syntax: bash
    [@YANICK]


### The Other Plugins

Did I say that there was three kinds of plugins?

I lied.

It's also possible to user plugins that live outside of the three
namespaces mentioned above, by prefixing their names
with an equal sign in the configuration, like so:

    [=YANICK::Pod::Weaver::Plugins::Foo]

Of course, for clarity's sake it's a better idea to stick to the official
namespaces. But still, it's nice to know that we have this extra-flexibility,
in case a special case would ever pop up.

## In Out Next Episode...

Now that we can can recognize our beasties from the outside, it's time
to see what makes them tick from the *inside*. 
Next time, we build ourselves a nice, shiny new *Section* plugin.
