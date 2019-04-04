---
title: Making Docsets
url: making-docsets
format: markdown
created: 2015-08-24
tags:
    - Perl
---

UPDATE: I've added a link to the [generated Swagger docset](./swagger_2_0.tgz), as it was requested
in the comment section.

Call me old-fashioned, but it always make me slightly uncomfortable to rely on
online
documentation. I always feel like I'm yelling *"HEY, WHAT'S THE NAME OF THE
JQUERY FUNCTION THAT FIND ALL THE ELEMENTS AFTER FOO?"* across three floors.
It feels... rude. Not to mention a waste of perfectly good vocal chords.

In that regard, I'm rather fond of [Dash][dash] and its Linux counterpart,
[Zeal][zeal]. And it's rather nice that the documentation format it uses
(called 'docsets') is
HTML. Which means that it's easy to create new ones.

Which is a good thing, because I'm currently learning [Swagger][swagger], and
there is no docset for its specs.

So I decided to go ahead and write that docsets.

And a module that would make the indexing and paraphernalial files formation
more automatic.

And, y'know, make it pretty too.

So, I grabbed the Markdown-formatted specs off GitHub and went to work:

```perl
#!/usr/bin/env perl 

use 5.20.0;

use strict;
use warnings;

use Dash::Docset::Generator;
use Text::MultiMarkdown qw/ markdown /;
use Path::Tiny;
use Web::Query::LibXML;
use List::Util qw/ pairs /;

my $docset = Dash::Docset::Generator->new( 
    name => "Swagger 2.0",
    platform_family => 'swagger',
    output_dir => '.',
    homepage => 'https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md',
);

# specs were already processed by Text::MultiMarkdown
my $index = new_doc();
$index->find('body')->append( path('index.html')->slurp );

```

I could have kept the whole specs in a single document, but where would be the
fun in that? Instead, I used `Web::Query` to chop sections into their own
files:

```perl
my %files = ( 'index.html' => $index );

# process all the schema objects
$index->find('h4')->each(sub{
    warn $_->text;
        
    return unless $_->text =~ / ^ (.*) \s+ Object \s* $ /x;
    my $file = $1.'.html' =~ s/ /_/gr;

    my $t = $_->text;
    $_->find('a')->attr( 'docset-type' => 'Object' );
    $_->find('a')->attr( 'docset-name' => $t );

    my $content = wq('&lt;html>&lt;head/>&lt;body/>&lt;/html>');

    $files{$file} = $content;

    $content->find('body')->append($_)->append($_->next_until('h4'));
    $_->next_until('h4')->remove;
    $_->remove;

    $content->find( 'a' )->each( sub {
        my $ref = $_->attr('name') or return;
        my $xpath = "//a[\@href='#$ref']";

        $_->find(\$xpath)->each(sub{
            $_->attr('href', $file . $_->attr('href') );
        }) for values %files;
    });


});

{
    # process the type section
    
    my $type = wq('&lt;html>&lt;head/>&lt;body/>&lt;/html>');
    my $x = $index->find('h3')->filter(sub{ $_->text =~ /Data Types/ });
    my $t = $x->text;
    my $a = $x->prepend( '&lt;a/>' );

    $a->attr( 'docset-type' => 'Type' );
    $a->attr( 'docset-name' => $t );

    my $block = $x->add( $x->next_until('h3') );
    $type->find('body')->append($block);
    $block->remove;

    $files{'types.html'} = $type;

    $type->find( 'a' )->each( sub {
        my $ref = $_->attr('name') or return;
        my $xpath = "//a[\@href='#$ref']";

        $_->find(\$xpath)->each(sub{
            $_->attr('href', 'types.html' . $_->attr('href') );
        }) for values %files;
    });

}

```

And then I fed those documents into my new
[Dash-Docset-Generator](http://github.com/yanick/Dash-Docset-Generator),

```perl
$docset->add_doc( $_->[0], $_->[1] ) for pairs %files;
```

Added some pizzazz with GitHub-inspired (well, okay, pretty much straight
stolen) style:

```perl
$docset->add_css( 'github-style.css' );
```

And, why not, syntax highlighting:

```perl
$docset->add_js( 'prism.js' );
$docset->add_css( 'prism.css' );
```

And boom

```perl
$docset->generate;


sub new_doc {
    wq( '&lt;html>&lt;head/>&lt;body/>&lt;/html>' );
}

```

We have a new docset:

<div align="center">
<img src="__ENTRY_DIR__/zeal.png" alt="Zeal screenshot with Swagger 2.0" />
</div>

(which can be [downloaded](./swagger_2_0.tgz) too, if you feel like it).



  [dash]: https://kapeli.com/dash
  [zeal]: http://zealdocs.org/
  [swagger]: http://swagger.io/
