---
url: fun-with-template-declare
format: markdown
created: 22 Aug 2011
tags:
    - Perl
    - Template::Declare
    - Dancer
    - File::SharedDir
---

# A Wee Bit of Fun with Template::Declare

As I was crafting my [Dancer](cpan) presentation for 
[Summercamp 2011](http://www.fosslc.org/drupal/sc2011), 
I noticed that there wasn't a Dancer template for 
[Template::Declare](cpan).

Well, now there's [one](http://p3rl.org/Dancer-Template-TemplateDeclare).

While I was at it, I also played with defining templates in their own files
and then importing them in a Template::Declare class (for more involved
templates, I like to have one template per file, to keep the
strain on my brain to a minimum). With the magical
help of Perl's shared directories, it proved to be quite easy.

What I did was to use the `auto` directory associated with the template's
module. For example, for the template module `My::Templates`, I 
dropped the individual templates under the directory `lib/auto/My/Templates`:


    lib/
    ├── auto
    │   └── My
    │       └── Templates
    │           ├── simple.td
    │           └── sub
    │               └── foo.td
    └── My
        └── Templates.pm

Each template file only needs to have the inner template definition. For
example, `simple.td` looks like:

    #syntax: perl
    html {
        body {
            h1 { 'Hello ' . $args->{name} }
        }
    }

Because I'm piggy-backing on Perl's shared directories convention, harvesting 
those template files is a breeze thanks to [File::SharedDir](cpan).


    #syntax: perl
    package My::Templates;

    use Template::Declare::Tags;
    use base 'Template::Declare';

    use File::ShareDir qw/ module_dir /;
    use Path::Class;

    my $base =  dir( module_dir( __PACKAGE__ ) );

    $base->recurse( callback => \&import_template );

    sub import_template {
        my $file = shift;

        return unless $file->isa( 'Path::Class::File' )
            and $file =~ /\.td$/;

        my $content = $file->slurp;

        my $name = $file->relative( $base );

        $name =~ s/\.td$//;

        eval <<"END_CODE";
    template "$name" => sub {
        my ( \$self, \$args ) = \@_;

    #line 1 $f
        $content;
    }
    END_CODE

        die $@ if $@;
    }

    1;

As you can see, the code is pretty straight-forward and fairly minimal.
With `module_dir()`, I grab all the files (recursively, natch) 
with a `.td` extension
within the `auto` directory of the module and use them to build the equivalent
'`template $name => sub { ... }`' declarations.  The only bit of cleverness, if
it can be called thus, is the "`#line 1 $f`" preprocessing command, which will
cause compilation errors to be reported at the right place in the `.td` template file instead than
within `My/Templates.pm`.

In this example, I set the
templates in such a way that the arguments must be passed as an hash ref
and are made accessible to the template via `$args`, but it could easily
be modified to please any other convention/preference.

And that's all there is to it. The template module can be used like any
other `Template::Declare` module, with no apparent difference for the
outside world:

    #syntax: perl
    #!/usr/bin/perl 

    use strict;
    use warnings;

    use My::Templates;

    Template::Declare->init( dispatch_to => [ 'My::Templates' ] );
    print Template::Declare->show( 'simple', { name => 'world' }  );
    print Template::Declare->show( 'sub/foo' );


Nice.  Now, I should probably stop plucking the alpaca's eyebrows
and return to work on my slides...
