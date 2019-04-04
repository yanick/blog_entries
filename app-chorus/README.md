---
created: 2013-07-07
tags:
    - Perl
    - Dancer
---

# Dancer Applications As CPAN Modules

Distributing modules via CPAN? A breeze. Distributing applications? Pretty
easy too. Distributing *web* applications? Eeeh... that's getting a little
harder.

The main problem with web applications is that they are not only composed
of Perl code, but also of configuration files, templates, images and whatnots,
and those are a bit trickier to deal with. But, if you remember, that's a
problem [I poked a while ago](blog:sharedir-tarball). The question is,
is that enough?

Spoiler: for simple [Dancer](cpan) applications, it is!

As a guinea pig, I took my buzzword-compliant [Markdown-based presentation
app](blog:chorus),
which offer the added difficulty of requiring to be run over
[Twiggy](cpan). As it turns out, once all the
application files have been nicely tucked under the distrubution
`/share` directory, the main script turns out to be (relatively)
straight-forward:

``` perl
use strict;
use warnings;

use 5.10.0;

use File::ShareDir::Tarball;
use Getopt::Long;
use Path::Tiny;
use Plack::Loader;

require Dancer;

GetOptions( \%::options,
    'appdir=s'
);

my $prez = shift;

$::options{appdir} &&= path($::options{appdir})->absolute;

$ENV{DANCER_APPDIR} = $::options{appdir} ||
    File::ShareDir::Tarball::dist_dir( 'App-Chorus' );

say "using appdir '$ENV{DANCER_APPDIR}'";

# dont' want Dancer to initialize before DANCER_APPDIR
# is set
Dancer->import;

Dancer::load_app( 'App::Chorus', settings => {
    logger          => 'console',
    log             => 'debug',
    presentation    => $prez,
    serializer      => 'JSON',
});

$ENV{PLACK_ENV} = 'PSGI';

Plack::Loader->load('Twiggy', port => 3000 )->run(Dancer::dance());
```

Yes, that's it. We extract the application root dir on-the-fly, unless the
user wants to use their own version (which open the door for customization and
slight performance increase). And then we use the lovely magic of
[Plack::Loader](cpan:module/Plack::Loader) to launch our web app over
*Twiggy*.

And with that, *Chorus* is finally [on CPAN](cpan:release/App-Chorus) (and
[on GitHub](github:yanick/chorus), of course).  Enjoy!
