---
format: html
created: 2007-07-14
original: use.perl.org - http://use.perl.org/~Yanick/journal/33807
tags:
    - Pod::Manual
    - Perl
---

# Pod::Manual

<p>A while ago, <a href="http://use.perl.org/~Yanick/journal/33028" rel="nofollow">I hacked together a way to
gather many pod files into a single pdf file</a>.
Well, finally I got around
cleaning up the code and released it as
<a href="http://search.cpan.org/~yanick/Pod-Manual/" rel="nofollow">Pod::Manual</a>.</p><p>
It's still very muchly alpha quality, but the basics seem to work.
For example, the following works (at least on my machine)[<a
href="%23footnote" rel="nofollow">*]:</a> </p><blockquote><div><p> <pre>use Pod::Manual;
 
my $manual = Pod::Manual->new({ title => 'Catalyst' });
 
$manual->add_chapter( $_ ) for qw/
    Catalyst::Manual::About
    Catalyst::Manual::Actions
    Catalyst::Manual::Cookbook
    Catalyst::Manual::DevelopmentProcess
    Catalyst::Manual::Internals
    Catalyst::Manual::Intro
    Catalyst::Manual::Plugins
    Catalyst::Manual::Tutorial
    Catalyst::Manual::Tutorial::Intro
    Catalyst::Manual::Tutorial::CatalystBasics
    Catalyst::Manual::Tutorial::BasicCRUD
    Catalyst::Manual::Tutorial::Authentication
    Catalyst::Manual::Tutorial::Authorization
    Catalyst::Manual::Tutorial::Debugging
    Catalyst::Manual::Tutorial::Testing
    Catalyst::Manual::Tutorial::AdvancedCRUD
    Catalyst::Manual::Tutorial::Appendices
    Catalyst::Manual::WritingPlugins
/;
 
$manual->save_as_pdf( 'catalyst_manual.pdf' );</pre></p></div> </blockquote><p>At this stage of the game, bug reports and feature requests
would be very welcome. As well as suggestions for other
example manuals.</p><p>[*] caveat: for the moment you need <code>TeTeX</code> installed
to generate pdf documents. One of the items on my todo list is
to allow for other means to generate the pdf (<code>jadetex</code>,
<code>FOP</code>, etc)</p>
