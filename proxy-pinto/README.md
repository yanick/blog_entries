---
title: Picking Packages With Pass-through, Proxied Pinto 
url: proxy-pinto
format: markdown
created: 2013-01-03
updated: 15 Jan 2013
tags:
    - Perl
    - Pinto
---

> **Edit:** Jeffrey reminded me of a much easier way to accomplish the proxy
> dance. Look at the end of this entry for a new, shocking ending to this tale.

A long time ago, I wrote a small Catalyst app called
[dpanneur](http://babyl.dyndns.org/techblog/entry/dpanneur-your-friendly-darkpancpan-proxy-corner-store),
a CPAN proxy which main goal was to cache requested modules so that I could
quickly seed a local darkpan mirror. Since then technology marched on
and the magnificent [Pinto](cpan) made its entrance. `Pinto` is miles and
leagues superior to anything I could ever dream to achieve with `dpanneur`, so it's
with a total lack of regrets that I declared that the king is dead, long live
the Pinto. 

Well, *almost* with a total lack of regrets. While adding any module to
a Pinto repository is only a

```bash
$ pinto pull Git::CPAN::Patch
```

away, it's still one command to type. Wouldn't be nice to be able to have a
proxy mode, just like `dpanneur` had? Well, as it turns out, thanks to the
beautifully clean innards of `Pinto`, such a proxy is a small
[Dancer](cpan) app away:

```perl
package PintoProxy;

    use Dancer ':syntax';

    use CPAN::Cache;
    use Path::Class;
    use Pinto;

    # workaround for silly RT55160
    *CPAN::Cache::_static = *CPAN::Cache::static;

    # the stack that will absorb our proxied packages
    my $stack = 'proxy';
    my $pinto_dir = dir( $ENV{PINTO_REPOSITORY_ROOT}, $stack );

    my $pinto = Pinto->new( root => $ENV{PINTO_REPOSITORY_ROOT} );

    my $cache = CPAN::Cache->new(
        remote_uri => 'http://search.cpan.org/CPAN/',
        local_dir  => 'public',   # to take advantage of the default behavior
                                  # of 'send_file'
    );

    # we want to get the list of modules fresh from CPAN
    get '/modules/02packages.details.txt.gz' => sub {
        my $file = $cache->mirror( request->path ) 
            or return send_error 400;

        return send_file(request->path);
    };

    get '/**' => sub {
        my $path = request->path;

        my $pinto_path = $pinto_dir->file($path);

        unless ( -f $pinto_path ) {  
            # not there? Try to pull

            ( my $target = $path ) =~ s#/authors/id/./../##;

            $pinto->run( 'pull', norecurse => 1, stack => $stack, targets => [ $target ] );
        }

        return send_file $pinto_dir->file($path), system_path => 1;
    };

    true;
```

And indeed:

```bash
$ pinto list -s bleeding | grep Acme::EyeDrops

    $ alias darkpan='cpanm --mirror http://localhost:3000/ --mirror-only'

    $ darkpan Acme::EyeDrops
    --> Working on Acme::EyeDrops
    Fetching http://localhost:3000/authors/id/A/AS/ASAVIGE/Acme-EyeDrops-1.60.tar.gz ... OK
    Configuring Acme-EyeDrops-1.60 ... OK
    Building and testing Acme-EyeDrops-1.60 ... OK
    Successfully installed Acme-EyeDrops-1.60
    1 distribution installed

    $ pinto list -s bleeding | grep Acme::EyeDrops
    rf  Acme::EyeDrops
```

Tadah!

## Or, Y'know, You Could Have Done It the Easy Way...

... by using what pinto already provides:

```bash
$ alias darkpan='pinto install --message="proxy import" -v --pull '

    $ darkpan Acme::EyeDrops
    Pulling distribution http://cpan.perl.org/authors/id/A/AS/ASAVIGE/Acme-EyeDrops-1.60.tar.gz
    Pulling distribution http://cpan.perl.org/authors/id/P/PE/PETDANCE/Test-Pod-Coverage-1.08.tar.gz
    Pulling distribution http://cpan.perl.org/authors/id/R/RC/RCLAMP/Pod-Coverage-0.22.tar.gz
    Pulling distribution http://cpan.perl.org/authors/id/A/AN/ANDK/Devel-Symdump-2.08.tar.gz
    Acme::EyeDrops is up to date. (1.60)
```


To my defense, last time I had checked the argument *--message* wasn't there
yet and `pinto` was forcefully asking for a commit message, which was
kinda spoiling the transparent proxy thing. 

Note that this method and mine are
very similar, but will exhibit some slight differences in behavior due to the
fact that mine is querying CPAN directly, and this one here goes through
Pinto's database. Caveat Emptor and all that, as usual.

