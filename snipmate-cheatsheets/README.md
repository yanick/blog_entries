---
title: SnipMate Cheatsheets Generator
url: snipmate-cheatsheets
format: markdown
created: 17 Apr 2012
tags:
    - Perl
    - Template::Caribou
    - vim
    - snipmate
---

Although 
[SnipMate](http://www.vim.org/scripts/script.php?script_id=2540) is a powerful
Vim plugin, I don't use it as nearly often as I should. Mostly because I
simply don't remember all the delicious snippets that it brings at my
fingertips. The solution to that silly situation is, fortunately, quite simple: I need
a way to print cheatsheets for those snippet files.

Now, anybody with a sensible bone in their body would have written a small
script to turn a snippets file into an html file and be done with it. Me, I
saw an opportunity to work a little more on my [Template::Caribou](cpan)
pet project.

Bottom-line: there is now the files `snipmate_cheatsheet.pl` and
`snipmate_index.pl` in [Template::Caribou's
repo](https://github.com/yanick/Template-Caribou). They can be used straight
from the repo checkout as follow:

    #syntax: bash
    # create one cheatsheet
    $ perl -Ilib -Iexamples/lib \
        examples/snipmate_cheatsheet.pl ~/.vim/snippets/perl.snippets

    # create'em all, with an index in bonus
    $ mkdir cheatsheets
    $ cd cheatsheets
    $ perl -I../lib -I../examples/lib ../examples/snipmate_index.pl

And the result they should give you should be just like
[that](__ENTRY_DIR__/index.html).

If all you care about is the final product, you can already stop reading, hurry to
go clone my repo and run the advertised scripts to generate your very own
batch of ready-to-print cheatsheets.  If you are curious to see what weird new
twists I've added to my template system, and what the classes that generate
the index and cheatsheets look like, soldier on.

## What's New, Caribou?

While no change was made to the core engine, I've sprinkled some additional sugar
that should make the writing of tags a little easier.

In that regard, the most notable new feature is the ability to generate custom
tags per-template. Because while

    #syntax: perl
    div { attr class => 'snippet';
        div { attr class => 'header';
            div { attr class => 'keyword'; 
                $label; 
            };
            div { attr class => 'comment';
                $comment; 
            };
        };
    };

is already okay, 

    #syntax: perl
    div_snippet {
        div_header { 
            div_keyword { $label; };
            div_comment { $comment; };
        };
    };

would be awesome. And now it's totally possible by creating those special tags with
`Template::Caribou::Tags`:

    #syntax: perl
    use Template::Caribou::Tags
      mytag => { 
        -as => 'span_placeholder', class => 'placeholder', tag => 'span' 
      },
          # if 'tag' is not given, defaults to 'div'
      mytag => { -as => 'div_snippet', class => 'snippet' },
      ...
 
Along the same lines, I've also introduced some shortcut tag functions, `css`
and `anchor` as part
of the collection provided by `Template::Caribou::Tags::HTML`:

    #syntax: perl
    css <<'END_CSS';
        body { color: magenta; }
    END_CSS

    anchor 'http://foo.com', 'a link';
    anchor 'http://foo.com', sub { 'a ' . bold { 'link' } };


Nothing earth-shattering, as they are strictly equivalent to

    #syntax: perl
    style {
        attr type => 'text/css';
        "body { color: magenta; }";
    }

    a {
        attr href => 'http://foo.com';
        'a link';
    };

    a {
        attr href => 'http://foo.com';
        'a ' . bold { 'link' };
    }


But I think it's fair to say that they provide comfortable shorthands for their
most common uses.

And, finally, although I won't use it directly in this case, tag attributes can
now be queried and appended to:

    #syntax: perl
    div {
        ... # lotsa stuff

        attr '+class' => 'important' if attr('id') eq 'TheOne';
    }


## Cheatsheet Template

Enough shameless display of mechanics. Now, let's put all those toys together to generate ourselves a pretty
cheatsheet, shall we? First, package declaration and import of all important
stuff:

    #syntax: perl
    package SnipMate::Snippets;

    use 5.14.0;

    use strict;
    use warnings;

    use Method::Signatures;

    use Moose;

    use MooseX::Types::Path::Class;

    use Template::Caribou::Utils;

    use Template::Caribou::Tags::HTML qw/ :all /;

    use Template::Caribou::Tags
        mytag => { 
            -as => 'span_placeholder', class => 'placeholder', tag => 'span' 
        },
        map { ( mytag => { -as => "div_$_", class => $_ } ) } qw/
            comment code snippet keyword snippets header
        /
        ;

    with 'Template::Caribou';


Notice that I just created the custom tags `div_comment`, `div_code`, etc,
on-the-fly. And if you catch yourself thinking that it would be a good idea to
have the *-as* parameter defaults to `$tag_$class`, well, so do I. But I
didn't find the proper way to twist [Sub::Exporter](cpan) to my bidding
there yet... Dark gods provide, it should be there for the next iteration though.

Once done with the preamble, we define a couple of attributes that are going
to hold the snippet information:

    #syntax: perl
    has snippet_file => (
        is => 'ro',
        isa => 'Path::Class::File',
        coerce => 1,
        required => 1,
    );

    has snippets => (
        is => 'ro',
        lazy => 1,
        builder => '_build_snippets',
    );

Next comes the builder `_build_snippets`, where we parse the snippets file.
It's not the most elegant parsing ever done, but it's serviceable. And it
comes with a bonus: comment lines with two '#' are seen as being section
names, useful for peeps like me who want to know which snippets are for
general Perl stuff, for Catalyst, for Dancer, etc.

    #syntax: perl
    method _build_snippets {
        my @lines = $self->snippet_file->slurp;

        my @all_snippets;
        my $current_title;
        my @current_snippets;

        my $i = -1;
        LINE:
        while( my $line = $lines[++$i] ) {
            if ( $line =~ s/^##\s*(.*?)\s*/$1/ ) {
                if ( @current_snippets ) {
                    push @all_snippets, 
                        [ $current_title => @current_snippets ];
                }
                $current_title = $line;
                @current_snippets = ();
                next LINE;
            }

            if ( $line =~ s/^\s*snippet\s+(.*)// ) {
                my $snippet = $1;
                my $comment;
                if ( $i > 0 and $lines[$i-1] =~ /^#(.*)/ ) {
                    $comment = $1;
                }
                my $code = $lines[++$i];
                $code =~ s/^(\s+)//;
                my $spaces = $1;
                $code .= $lines[$i] while $lines[++$i] =~ s/^$spaces//;

                push @current_snippets, [ $snippet, $comment, $code ];
            }
        }

        push @all_snippets, [ $current_title => @current_snippets ] 
            if @current_snippets;

        return \@all_snippets;

    }


And after this, it's templates all the way down. We first have the top-level
template, the webpage
itself:

    #syntax: perl
    template webpage => method {
        html {
            head { 
                show('style');
            };
            body { 
                h1 {  $self->snippet_file->basename };
                div_snippets {
                    show( 'section' => @$_ ) for @{ $self->snippets };
                }
            };
        }
    };

Then the individual sections:

    #syntax: perl
    template section => method( $title,@snippets ) {

        h2 { $title } if $title;

        show( 'snippet' => @$_ ) for @snippets;
    };

Which are made of snippets:

    #syntax: perl
    template snippet => method ( $label, $comment, $code ) {
        div_snippet {

            div_header { 
                div_keyword { $label; };
                div_comment { $comment; };
            };

            div_code sub {
                my $regex = qr#(\$\{\d+.*?\})#;

                for ( split $regex, $code ) {
                    if ( /$regex/ ) {
                        span_placeholder { $_ };
                    }
                    else {
                        print $_;
                    }
                }
            };
        }
    };


And the last touch, the style sheet:

    #syntax: perl
    template style => sub {
        css <<'END_CSS';

    @page { size: landscape; }

    body {
        font-family: monospace;
    }

    h2 { 
        background-color: 
        darkblue; color: white; 
        padding: 3px;
        text-align: center;
    }

    .header { border-bottom: 1px black solid; }

    .keyword {
        display: inline-block;
        font-size: 1.5em;
    }

    .comment {
        float: right;
        font-style: italic;
    }

    .desc {
        margin-top: 0.5em;
    }

    .code {
        padding-left: 0.5em;
        white-space: pre;
        margin-top: 1em;
        overflow: hidden;
    }

    .placeholder {
        color: red;
    }

    .snippets {
        -moz-column-count: 3;
        -moz-column-gap: 20px;
        -moz-column-rule: 1px solid black;
    }

    .snippet {
        column-break-inside: avoid; /* doesn't work. boo */
        display: inline-block;      /* workaround for column-break suckiness */
        width: 100%;
        margin-bottom: 1em;
    }

    END_CSS

    };

Incidentally, yes, it took me almost as much time figuring out how to use
CSS3's columns with Firefox than it took me to implement the rest.  The Web is
truly a horrible, horrible place. 

For the index generator, it's
all of the same, only more simple still:


    #syntax: perl
    package SnipMate::Index;

    use 5.14.0;

    use strict;
    use warnings;

    use Method::Signatures;

    use Moose;

    use MooseX::Types::Path::Class;
    use SnipMate::Snippets;

    use Template::Caribou::Utils;
    use Template::Caribou::Tags::HTML qw/ :all /;

    with 'Template::Caribou';

    has 'snippet_dir' => (
        isa => 'Path::Class::Dir',
        is => 'ro',
        default => $ENV{HOME}.'/.vim/snippets',
        coerce => 1,
    );

    has snippet_files => (
        is => 'ro',
        traits => [ 'Array' ],
        lazy => 1,
        default => sub {[
            map  { Path::Class::file($_) }
            grep { /\.snippets$/ }
            $_[0]->snippet_dir->children
        ]},
        handles => {
            'all_snippet_files' => 'elements'
        },
    );

    template webpage => method {
        html { body { ul { 
            li {
                anchor $_->basename.'.html' => $_->basename;
            } for $self->all_snippet_files;
        } } }
    };

    method generate_pages {
        for ( $self->all_snippet_files ) {
            generate_snippet_file( $_, $_->basename . '.html' );
        }
    }

    sub generate_snippet_file {
        my ( $src, $dest ) = @_;
        open my $fh, '>', $dest or die $!;

        print $fh SnipMate::Snippets->new( snippet_file => $src)
                        ->render('webpage');
    }

    __PACKAGE__->meta->make_immutable;

    1;


And that's all there is to it. Nifty, isn't? 
