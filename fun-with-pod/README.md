---
created: 2014-12-19
tags:
    - Perl
    - POD
---

# Fun in POD-land

I love to tinker with tools, utilities, tweaks, anything that can be used
to make grease the production chain into stupendously slick efficiency. So it
stands to reason that I'd be drawn to documentation, its format, its
processors, the tools to display and search it. Heck, I've even been known to
actually read it, now and then.

Documentation, in the Perl sphere, means
[POD](http://perldoc.perl.org/perlpod.html). It's a fairly
simple markup format, but with just enough twists to make things...
interesting.

As POD is as old as Perl, there is plenty of modules out there to
parse it, and to generate output in pretty much all the usual formats.
There are none, however, that does exactly what I want.

What do I want? I want simplicity. I want extensibility. I want trivially
simple manipulations. And I think I want a peppermint tea. Don't move,
I'll be back in 5 minutes.

Aaah, that's better. Where was I? Oh yes, wants. To be more pragmatic, there
are two use cases I'm pursuing. 

The first one is the transformation of 
POD documents into any other format. I did a first foray into that when
I played with PDF documents and [Pod::Manual](cpan:Pod::Manual). That project
is still on the backburner, and these days I'm also eyeing exporting
Perl distribution documentation as [Dash](http://kapeli.com/dash)/[Zeal](http://zealdocs.org/) docsets.

The second one is POD extension/manipulation in the context of distribution
building. "But there are [Pod::Elemental](cpan:Pod::Elemental) and
[Pod::Weaver](cpan:Pod::Weaver) for that!", I hear you say. And you are
right. But I have a confession to make:

`Pod::Elemental` and `Pod::Weaver` scare the everlasting bejeesus outta me.

Although fear can keeps me away only for so long. Underneath the initial
gasp, I think that what disatisfy me is that each POD solution that I found
on CPAN that gives me DOM manipulating powers is a special snowflake of
a parser. Meaning that I have to learn about its DOM structure, its
node descending rules, all that jazz. Meh. It's all hard work. Why couldn't it
be simpler? Like, couldn't it be just like a jQuery-enabled page, where
getting a section could be as simple as `$('head1.synopsis')`
and moving it elsewhere be one `$some_section.insert_after($some_other_section)`?

If you found yourself nodding at that last paragraph, keep reading.
If, on the other hand, you felt the cold finger of dread run down your spine,
you might want to go and get your comfort blanket before soldiering on...

## It's all too complicated. Let's use XML!

To be honest, that's not something I was expecting to say
of my own volition. But, really, this is the type of stuff
XML was born to do. Considering how well-understood XML/HTML is,
it kinda makes sense to use it as the core format. And with that
type of document, we don't have to invent a way to move around in the
DOM tree -- there are already XPath and CSS selectors that are there for that.
And lookee, lookee, there's [Web::Query](cpan:Web-Query) that would give us
access to CSS and XPath selectors (for XPath selectors, just wait a few
days for its next release to be out), and nifty jQuery-like DOM-manipulating
methods.

In a nutshell, that's what I wanted to try: create a prototype of a pipeline
that would slurp in some POD, allow to easily muck with it, and spit it out
as whatever is desired.

The prototype, [Pod::Knit](gh:yanick/Pod-Knit), exists. It's still
extremely alpha, but it's already at a point where an owner tour might be in
order. Here, follow me...

## POD comes in...

First thing on the agenda: read some POD and convert it to some XML
document. Now, writing this part myself, considering how many POD
parsers are out there, would be silly. Well, sillier than the rest
of my plan, that is. So I went shopping on CPAN.

At  first, I found [Pod::POM](cpan:Pod-POM). Its [HTML
output](cpan:module/Pod::POM::View::HTML) takes some 
liberties with the formatting attributes, so I wrote
a quick [generic XML view module](cpan:Pod-POM-View-XML).

... And only then realized the parser isn't easily extended to 
accept new POD elements. Dammit.

So I switched to [Pod::Simple](cpan:Pod-Simple)
and [Pod::Simple::DumpAsXML](cpan:module/Pod::Simple::DumpAsXML),
making the POD-to-XML journey look like:

``` perl
use Pod::Simple::DumpAsXML;

my $parser = Pod::Simple::DumpAsXML->new;

$parser->output_string( \my $xml );

$parser->parse_string_document( $source_code );

print $xml;
```

So far, so good.

## Close the doors, we're altering the patient

Now the fun part comes: modifying the document.

As I want extensibility and modularity, I went for a plugin approach, where
the POD document (presented as a thinly wrapped `Web::Query` object)
would be passed through all the plugins in different stages.

And to make it real, I crafted a set of plugins that would
exercise the basic manipulations I'd expect the framework to support:


```yaml
---
plugins:
    # create the '=head1 NAME' section from the package/#ABSTRACT lines
    - Abstract
    # add an AUTHORS section
    - Authors:
        authors:
            - Yanick Champoux
    # grok '=method' elements
    - Methods
    # sort the POD elements in the given order
    - Sort:
        order:
            - NAME
            - SYNOPSIS
            - DESCRIPTION
            - METHODS
            - '*'
            - AUTHORS

```

Let's now see the different processing stages, and how those plugins implement
them.

### Stage 1: POD parser configuration

First, when the `Pod::Simple` parser is created, each plugin
is given the chance to tweak it. For the moment, this is
mostly to give them the opportunity to declare new POD elements.
For example, the 'Methods' plugin has

```
package Pod::Knit::Plugin::Methods;

use Moose;

with 'Pod::Knit::Plugin';

sub setup_parser {
    my( $self, $parser ) = @_;

    $parser->accept_directive_as_processed( 'method' );
}
```

### Stage 2: Preprocessing, aka putting those Russian Dolls together

The second stage is the "preprocessing" stage, where plugins take the
raw output of `Pod::Simple::DumpAsXML` and groom it into
the desired base structure. In most of the cases, that will be
turning the raw flat list of elements given by `Pod::Simple` 
into a structure form.

For example, the raw head elements look like

```
    &lt;head1>DESCRIPTION&lt;/head1>
    &lt;para>Blah blah&lt;para>
    &lt;verbatimformatted>$foo->bar&lt;/verbatimformatted>
    &lt;para>More blah&lt;/para>
    &lt;head1>OTHER SECTION&lt;/head1>
    ...
```

but what we want is

```
    &lt;head1>
        &lt;title>DESCRIPTION&lt;/title>
        &lt;para>Blah blah&lt;para>
        &lt;verbatimformatted>$foo->bar&lt;/verbatimformatted>
        &lt;para>More blah&lt;/para>
    &lt;/head1>
    ...
```

There's an implicit plugin, `HeadsToSections`, that take care of that.
And in our example, the plugin 'Methods' does the same thing for 
`=method` elements, slurping in the relevant following elements:

``` perl
sub preprocess {
    my( $self, $doc ) = @_;

    $doc->find( 'method' )->each(sub{
            $_->html(
                '&lt;title>'. $_->html . '&lt;/title>'
            );
            my $done = 0;
            my $method = $_;
            $_->find( \'./following::*' )->each(sub{
                return if $done;

                my $tagname = $_->tagname;

                return if $done = !grep { $tagname eq $_ } 
                                        qw/ para verbatimformatted /;

                $_->detach;
                $method->append($_);
            });
    });

}
```

### Stage 3: Do your thing

Finally, the stage where we can expect the document to
be in the proper format, and where the plugins can go wild.

Things can be inserted. Based just on configuration items:

``` perl
package Pod::Knit::Plugin::Authors;

use Moose;

use Web::Query;

with 'Pod::Knit::Plugin';

has "authors" => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        my $self = shift;
        [];
    },
);

sub transform {
    my( $self, $doc ) = @_;

    my $section = wq( '&lt;over-text>' );
    for ( @{ $self->authors } ) {
        $section->append(
            '&lt;item-text>' . $_ . '&lt;/item-text>'
        );
    }

    # section() will return the existing
    # section with that title, or create
    # a new one if it doesn't exist yet
    $doc->section( 'authors' )->append(
        $section
    );
}
```

Or by looking at the source code or whatever
`Pod::Knit` makes accessible to the plugins.

``` perl
package Pod::Knit::Plugin::Abstract;

use Moose;

use Web::Query;

with 'Pod::Knit::Plugin';

sub transform {
    my( $self, $doc ) = @_;

    my( $package, $abstract ) =
        $self->source_code =~ /^\s*package\s+(\S+);\s*^\s*#\s*ABSTRACT:\s*(.*?)\s*$/m
            or return;

    $doc->section( 'name' )->append(
        join '',
        '&lt;para>',
            join( ' - ', $package, $abstract ),
        '&lt;/para>'
    );
}
```

Things can also be modified.

``` perl
package Pod::Knit::Plugin::Methods;

...

sub transform {
    my( $self, $doc ) = @_;

    my $section = $doc->section( 'methods' );

    $doc->find( 'method' )->each(sub{
        $_->detach;
        $_->tagname( 'head2' );
        $section->append($_);
    });

}

```

Or reordered. 

```perl
package Pod::Knit::Plugin::Sort;

use Moose;

with 'Pod::Knit::Plugin';

has "order" => (
    isa => 'ArrayRef',
    is => 'ro',
    lazy => 1,
    default => sub {
        []
    },
);

sub transform {
    my( $self, $doc ) = @_;

    my $i = 1;
    my %rank = map { uc($_) => $i++ } @{ $self->order };
    $rank{'*'} ||= $i;   # not given? all last

    my %sections;
    $doc->find('head1')->each(sub{
            $_->detach;

            my $title = uc $_->find('title')->first->text =~ s/^\s+|\s+$//gr;
            $sections{$title} = $_;
    });

    for my $s ( sort { ($rank{$a}||$rank{'*'}) <=> ($rank{$b}||$rank{'*'}) } keys %sections ) {
        $doc->append( $sections{$s} );
    }
}

1;
```

Basically, anything goes.

## Delicious sausages come out

With the transformed document being XML with a specific schema,
we're now free to use whatever transformation engine we want. 
To make the prototype go full circle, I had to re-translate
that XML into POD. And to do that, I resorted to good ol' insane
[XML::XSS](cpan:XML-XSS):

``` perl
package Pod::Knit::Output::POD;

use Moose::Role;

use XML::XSS;

sub as_pod {
    my $self = shift;

    my $xss = XML::XSS->new;

    $xss->set( 'document' => {
        pre => "=pod\n\n",
        post => "=cut\n\n",
    });

    $xss->set( "head$_" => {
        pre => "=head$_ ",
    }) for 1..4;

    $xss->set( 'title' => {
        pre => '',
        post => "\n\n",
    });

    $xss->set( 'verbatimformatted' => {
        pre => '',
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^/    /mgr;
        },
        post => "\n\n",
    });

    $xss->set( 'item-text' => {
        pre => "=item ",
        post => "\n\n",
    });

    $xss->set( 'over-text' => {
        pre => "=over\n\n",
    });

    $xss->set( '#text' => {
        filter => sub {
            s/^\s+|\s+$//mgr;
        }
    } );

    $xss->set( 'para' => {
        content => sub {
            my( $self, $node ) = @_;
            my $output = $self->render( $node->childNodes );
            $output =~ s/^\s+|\s+$//g;
            return $output . "\n\n";
        },
    } );

    $xss->render( $self->as_xml );
}

1;
```

Mind you, it's not nowhere near complete. But it's enough to make `Pod::Knit` 
take

``` perl
package Foo::Bar;
# ABSTRACT: Do things

=head1 SYNOPSIS

    blah blah
    blah

=method one

Do things

    $self->one
    and   some    stuff


=method two

Do other things.

Not used often.

=head1 DESCRIPTION

Blah

=head2 subtitle

More blah

=over

=item foo

something

=item bar

=back

```

and end up with 

``` perl
=pod

=head1 name

Foo::Bar - Do things

=head1 SYNOPSIS

    blah blah
    blah


=head1 DESCRIPTION

Blah

=head2 subtitle

More blah

=over

=item foo

something

=item bar

=head1 methods

=head2 one

Do things

    $self->one
    and   some    stuff

=head2 two

Do other things.

Not used often.

=head1 authors

=over

=item Yanick Champoux

=cut
```





