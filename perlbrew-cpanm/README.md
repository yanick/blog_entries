---
title: Guerilla Perl installations
url: guerilla-perl-installations
format: markdown
created: 2011-01-30
last_updated: 31 Jan 2011
tags:
    - Perl
    - App::cpanminus
    - App::perlbrew
---

**EDIT:** [melo](http://www.simplicidade.org/notes/) pointed out that the 
installation of `cpanminus` could be further simplified via 
`perlbrew install-cpanm`. I didn't know the command. Now I do. :-)

One of the nice things about Perl is that it's so entrenched
in the Unix toolchain that it's very, very rare to find oneself
on a machine that doesn't have it.  But that boon comes with a 
slip-side. Because it's generally part of the core system, we're
usually stuck with what is there. If we're lucky, it's going to be 
5.10 perl (2 year old technology. Not bleeding edge, but no rust yet), 
but chances are it's more going to be vintage 5.8 (7 year old technology).
Mind you, it's not that unusual either to have some 5.6 (venerable 10 year old technology) 
still running around.

But dealing with old perls isn't too bad. Where it gets aggravating is when
you badly need a CPAN module. The obstacles standing between you and the
installation of the module can be manifold. You probably don't have the 
`sudo` keys to the machine. Or there might be a policy in place not to
upgrade any modules without calling the Council of Elrond. Or there might
be a policy to only install modules only via official rpm or deb packages, 
which are likely to either lag behind CPAN or just not bundle the module you
so badly want.

## Brewing our own perl

Fortunately, there's a way out. 
[App::perlbrew](cpan) is a tool that simplifies down to 
triviality the process of making local perl installations. 
With it, any user can, in the span of a few minutes, have 
a working `perl` that is totally independant of whatever 
the system has. This is a win for you -- you're now in control of your `perl`,
and of your destiny -- as well as for the sysadmin, who is now free
of the prickly choice between 
system integrity and users' happiness.


The path to self-sufficient brewing is incredibly easy.
First, you have to download and install `perlbrew`:

<pre code="plain">
$ curl -L http://xrl.us/perlbrewinstall | bash

## Download the latest perlbrew

## Installing
The perlbrew is installed as:

    /home/che/perl5/perlbrew/bin/perlbrew

You may trash the downloaded /tmp/perlbrew from now on.

Next, if this is the first time you install perlbrew, run:

    /home/che/perl5/perlbrew/bin/perlbrew init

And follow the instruction on screen.

## Done. (automatically removes downloaded /tmp/perlbrew)
</pre>

That installed `perlbrew` under the `perl5` directory in your home. 
That
`perl5` directory, incidently, will be where all the Perl installations will
go. That's very convenient to clone your Perl install on other machines
(provided it's the same architecture, 
'`scp -r ~/perl5 che@othermachine:perl5`'
and you're done), or to clean up after yourself (the sysadmin wasn't too keen
on having rogue perls on the machine after all? lucky you, you're one 
'`rm -fr ~/perl5`' away from total denialibility).

Anyway, back to the installation. The next step is to tweak our environment
to use the perls that will be provided by `perlbrew`. To do that, 
we follow `perlbrew`'s instructions. First we do:

<pre code="plain">
$ /home/che/perl5/perlbrew/bin/perlbrew init
Perlbrew environment initiated, required directories are created under

    /home/che/perl5/perlbrew

Well-done! Congratulations! Please add the following line to the end
of your ~/.bashrc

    source /home/che/perl5/perlbrew/etc/bashrc

After that, exit this shell, start a new one, and install some fresh
perls:

    perlbrew install perl-5.12.1
    perlbrew install perl-5.10.1

For further instructions, simply run:

    perlbrew

The default help messages will popup and tell you what to do!

Enjoy perlbrew at $HOME!!
</pre>

And then we add

<pre code="bash">
source /home/che/perl5/perlbrew/etc/bashrc
</pre>

in our `~/.bashrc`.  You can look at the file if you are curious. It's not
doing anything more nefarious than to tweak your `$PERL5LIB` and `$PATH` and a 
few other environment variables.

With that, the `perlbrew` environment is ready and installed. Now let's populate it
with a few perls. First, let's get the latest and greatest:

<pre code="plain">
$ perlbrew install perl-5.12.3
Attempting to load conf from /home/che/perl5/perlbrew/Conf.pm
Fetching perl-5.12.3 as /home/che/perl5/perlbrew/dists/perl-5.12.3.tar.gz
Installing perl-5.12.3 into /home/che/perl5/perlbrew/perls/perl-5.12.3
This could take a while. You can run the following command on another shell to track the status:

  tail -f /home/che/perl5/perlbrew/build.log

(cd /home/che/perl5/perlbrew/build; tar xzf /home/che/perl5/perlbrew/dists/perl-5.12.3.tar.gz;cd /home/che/perl5/perlbrew/build/perl-5.12.3;rm -f config.sh Policy.sh;sh Configure -de '-Dprefix=/home/che/perl5/perlbrew/perls/perl-5.12.3';make;make test &amp;&amp; make install) >> '/home/che/perl5/perlbrew/build.log' 2>&amp;1 
Installed perl-5.12.3 as perl-5.12.3 successfully. Run the following command to switch to it.

  perlbrew switch perl-5.12.3
</pre>

and, why not?, an older one, just in case we want to run our code against
a version matching what we have in our production environment:

<pre code="plain">
$ perlbrew install perl-5.10.1
Attempting to load conf from /home/che/perl5/perlbrew/Conf.pm
Fetching perl-5.10.1 as /home/che/perl5/perlbrew/dists/perl-5.10.1.tar.gz
[ yadah yadah yadah... ]
Installed perl-5.10.1 as perl-5.10.1 successfully. Run the following command to switch to it.

  perlbrew switch perl-5.10.1
</pre>

We'll stop here for the time being, but we could install every
version of Perl of the last 10 years, and cackle like loons as we'd have thus built the
ultimate development environment. The fun doesn't even stop there: we can also
build development versions of perl, and build perls of the same version, but
with different building arguments (with/without threads, for example).

Anyway, for the time being, we have two local perls built, plus the 
system-wide perl. We can see then by doing:

<pre code="bash">
$ perlbrew list
  perl-5.10.1
  perl-5.12.3
* /usr/bin/perl (5.10.1)
</pre>

And switching to one of our home-cooked version is as simple as doing:


<pre code="plain">
$ perlbrew switch perl-5.10.1
$ which perl
/home/che/perl5/perlbrew/perls/perl-5.10.1/bin/perl
che@enkidu:~$ perl -v

This is perl, v5.10.1 (*) built for i686-linux
[..]

$ perlbrew switch perl-5.12.3
$ perl -v

This is perl 5, version 12, subversion 3 (v5.12.3) built for i686-linux
[..]
</pre>

Want to revert to the system perl for a moment? That's not too hard either:


<pre code="bash">
$ perlbrew off
</pre>

## Spicing up the brew with CPAN spiffiness

With our own perl, we are now free to install whichever module we
want without fear of impacting anybody but us.  The classical installation
process would make us use `cpan` from [CPAN](cpan) or `cpanp` from [CPANPLUS](cpan). 
Those interfaces to CPAN (the archive) are true and tried, but their 
extensive configuration can be a little daunting. There is work
being done to make them a little more streamline, but in the meantime there is
a third offering, [App::cpanminus](cpan), which is optimized for
simplicity. 

to install `cpanm`, we'll leverage our brand-new shiny `perlbrew`:


<pre code="plain">
$ perlbrew install-cpanm
</pre>

Done. No, seriously, we're done. `cpanm` can now be used to install all the modules 
you want. If those modules have dependencies, they will automatically be
followed and installed:


<pre code="plain">
$ cpanm XML::LibXML
--> Working on XML::LibXML
Fetching http://search.cpan.org/CPAN/authors/id/P/PA/PAJAS/XML-LibXML-1.70.tar.gz ... OK
Configuring XML-LibXML-1.70 ... OK
==> Found dependencies: XML::SAX, XML::NamespaceSupport
--> Working on XML::SAX
Fetching http://search.cpan.org/CPAN/authors/id/G/GR/GRANTM/XML-SAX-0.96.tar.gz ... OK
Configuring XML-SAX-0.96 ... OK
==> Found dependencies: XML::NamespaceSupport
--> Working on XML::NamespaceSupport
Fetching http://search.cpan.org/CPAN/authors/id/P/PE/PERIGRIN/XML-NamespaceSupport-1.11.tar.gz ... OK
Configuring XML-NamespaceSupport-1.11 ... OK
Building and testing XML-NamespaceSupport-1.11 ... OK
Successfully installed XML-NamespaceSupport-1.11
Building and testing XML-SAX-0.96 ... OK
Successfully installed XML-SAX-0.96
Building and testing XML-LibXML-1.70 ... OK
Successfully installed XML-LibXML-1.70
</pre>

`cpanm` can take a list of module as arguments, or can read them from STDIN,
which means you can make a list of your favorite modules and, on any brand-new
machine do

<pre code="plain">
$ cpanm &lt; my_favorite_modules.txt
</pre>

to get your full armory installed.  Or, for extra-hardcore bonus points, you
could keep your list of favorite modules as a CPAN module and do

<pre code="plain">
$ cpanm Task::BeLike::YANICK
</pre>

But the point is, you now have the power to leverage the power of modern Perl,
no matter where you are. Huzzah!
