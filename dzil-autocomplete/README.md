---
url:               dzil-autocomplete
format:            markdown
created:           16 Jun 2010
original:         the Pythian blog - http://www.pythian.com/news/13359/distzilla-autocomplete
tags:
    - dist-zilla
    - Perl
---

# Dist::Zilla autocomplete

Does anyone know of a *Yak Shaving Anonymous*
association  hackers addicted to Tibetan bovine shearing could join?

Anyway, here are two little things I hacked on top of Dist::Zilla
that peeps might find useful.

[The first](http://github.com/yanick/dist-zilla/tree/autocomplete), as hinted by the blog entry's title, is a direct adaptation
of [Aristotle's perldoc-complete](http://github.com/ap/perldoc-complete) for
dzil.  

    $ dzil *<tab>* 
    build     install   new       plugins   rjbsver   smoke     xtest     
    clean     listdeps  nop       release   run       test      


[The second](http://github.com/yanick/dist-zilla/tree/command-plugins) 
is actually the one that started that round of shaving for me.  As
there is about a gazillion Dist::Zilla plugins, I wanted to have a quick way 
to see all the plugins installed on a specific machine.
Enter a new dzil sub-command: `plugins`.  

    $ dzil plugins
    [ lotsa plugins ]
    MatchManifest - Ensure that MANIFEST is correct
    MetaConfig - summarize Dist::Zilla configuration into distmeta
    MetaJSON - produce a META.json
    * MetaNoIndex - Stop CPAN from indexing stuff
    MetaProvides - Generating and Populating 'provides' in your META.yml
    MetaProvides::Class - Scans Dist::Zilla's .pm files and tries to identify classes using Class::Discover.
    MetaProvides::FromFile - In the event nothing else works, pull in hand-crafted metadata from a specified file.
    MetaProvides::Package - Extract namespaces/version from traditional packages for provides
    * MetaResources - provide arbitrary "resources" for distribution metadata
    MetaTests - common extra tests for META.yml
    MetaYAML - produce a META.yml
    [ still lotsa plugins ]

The plugins marked with an asterix are used by the current `dist.ini`.  Also,
give a plugin name to the sub-command, and it'll act as a glorified 
`perldoc Dist::Zilla::Plugin::<Plugin Name>`.  The sweet thing is,
autocomplete also work there:

    $ dzil plugins Pod<Tab>
    PodCoverageTests  PodSyntaxTests    PodVersion        PodWeaver


Both patches are available on [my Github fork of
Dist::Zilla](http://github.com/yanick/dist-zilla). Enjoy! 
