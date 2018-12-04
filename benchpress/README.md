---
created: 2018-12-03
tags:
    - perl
    - Text::Xslate
    - benchmark
---

# Benchpressing Text::Xslate

My compulsive attraction to bovine pilosity is getting ridiculous.

A few years ago, during a New York City hackaton,
I teamed up with Charlie Gonzalez and wrote
a [Pull Request][PR] to move [Text::Xslate](cpan)
from [Mouse](cpan) to [Moo](cpan). The PR was applauded
by some, horrified others. Y'know, the usual.

So, anyway, fast-forwarding
to the present days, the authorities dusted off that old piece of code and
are considering maybe merged it in. But before doing so, they'd like to know
if that switch is impacting performance.

## What's already available

Delightfully enough, `Text::Xslate` already has
benchmarks, using the [Benchmark](cpan)
module.


```bash
19:04 yanick@enkidu ~/work/perl/p5-Text-Xslate
$ perl -Ilib benchmark/for.pl

Perl/5.20.2 x86_64-linux
Text::Xslate/v3.5.7
Text::MicroTemplate/0.24
HTML::Template::Pro/0.9510
          Rate xslate     mt     ht
xslate   431/s     --   -93%   -96%
mt      6222/s  1344%     --   -41%
ht     10479/s  2333%    68%     --
```

Sweet! ... But, wait. I'll have to run that file across different versions,
and cut, paste and assemble a report like a first grader at bricolage-time.

That's straight-forward, but sounds like too much work. Let's design a
benchmark system instead.

## Reaching for the dumb, and amplifying it

On CPAN there is the module [Dumbbench](cpan) that takes
care of some the mundane parts of running good benchmarks (doing warm-up runs,
detecting and removing outliers, etc). It's already providing more goodies than
`Benchmark` alone, but it's generating ad-hoc reports, and what I would love
to is to get back results in a format where I can throw in all matters of
variables, and then create a report using some more serious tools like
[R](https://www.r-project.org/).

And by "more serious", I totally mean "more shiny and I need an excuse to use
it". Natch.

And this is why I had to write my own benchmark module. Say hello to
[App::Benchpress](https://github.com/yanick/App-Benchpress). It's
not on CPAN as we speak, nor is it really in any shape to be seen in polite
company, but what the heck, we're amongst friends here.

## Benchmark suites

So, how does it work? First, it formalizes benchmark files into suites. For
example, the original benchmark `interpolate.pl` for `Text::Xslate` was

```perl
#!perl -w
use strict;

use Text::Xslate;

use Benchmark qw(:all);

use Config; printf "Perl/%vd %s\n", $^V, $Config{archname};
foreach my $mod(qw(Text::Xslate)){
    print $mod, '/', $mod->VERSION, "\n";
}

my($n, $data) = @ARGV;
$n    ||= 100;
$data ||= 10;

my %vpath = (
    interpolate =>
'Hello, <:= $lang :> world!' x $n

    interpolate_raw =>
'Hello, <:= $lang | raw :> world!' x $n

);

my $tx = Text::Xslate->new(
    path      => \%vpath,
    cache_dir => '.xslate_cache',
    cache     => 2,
);

my $subst_tmpl = qq{Hello, %lang% world!\n} x $n;

my $sprintf_tmpl = qq{Hello, %1\$s world!\n} x $n;

my $vars = {
    lang => 'Template' x $data,
};
printf "template size: %d bytes; data size: %d bytes\n",
    length $vpath{interpolate}, length $vars->{lang};

# suppose PSGI response body

cmpthese -1 => {
    xslate => sub {
        my $body = [$tx->render(interpolate => $vars)];
        return;
    },
    'xslate/raw' => sub {
        my $body = [$tx->render(interpolate_raw => $vars)];
        return;
    },
    'sprintf' => sub {
        my $body = [ sprintf $sprintf_tmpl, $vars->{lang} ];
        return;
    },
};

```

To be fit for `benchpress` consumption, it has to be changed into the module
`Text/Xslate/Benchmark/Interpolate.pm`:

```perl
package Text::Xslate::Benchmark::Interpolate;

use App::Benchpress::Suite;
extends 'App::Benchpress::Suite';

use Text::Xslate;

use Text::Xslate;

my %vpath = (
    interpolate => 'Hello, <:= $lang :> world!' x 100,
    interpolate_raw => 'Hello, <:= $lang | raw :> world!' x 100,
);

my $vars = {
    lang => 'Template' x 10,
};

my $tx = Text::Xslate->new(
    path      => \%vpath,
    cache_dir => '.xslate_cache',
    cache     => 2,
);

benchmark 'xslate' => sub {
    sub { $tx->render(interpolate => $vars) }, {
        xslate_version => Text::Xslate->VERSION
    };
};

benchmark 'xslate/raw' => sub {
    sub { $tx->render(interpolate_raw => $vars) }, {
        xslate_version => Text::Xslate->VERSION
    };
};

benchmark 'sprintf' => sub {
    my $sprintf_tmpl = qq{Hello, %1\$s world!\n} x 100;

    sub { sprintf $sprintf_tmpl, $vars->{lang} }
};

1;
```

Basically, benchmarks are defined by the `benchmark`
definitions that return the coderefs to benchmark as well
as optional environment variables to attach to the result.

## On your benchmark. Get set. GO!

We have a benchmark suite. How do we run it?
Via the cli utility `benchpress`:

```bash
19:45 yanick@enkidu ~/work/perl/p5-Text-Xslate
$ benchpress -I lib -I benchmark Text::Xslate::Benchmark::Interpolate
starting to benchpress
adding suite Text::Xslate::Benchmark::Interpolate
{"perl_version":"v5.20.2","results":{"runtime":{"mean":0.000523631467249679,"sigma":2.66560075608834e-07,"relative_sigma":0.0509060460038649},"iterations":{"per_second":1909.74007970224,"outliers":6,"total":26}},"suite":"Text::Xslate::Benchmark::Interpolate","run_at":"2018-12-04T00:46:21","name":"xslate","xslate_version":"v3.5.7"}
{"xslate_version":"v3.5.7","name":"xslate/raw","run_at":"2018-12-04T00:46:21","results":{"runtime":{"mean":0.000404362156405114,"sigma":4.2649612054344e-07,"relative_sigma":0.105473797136484},"iterations":{"total":23,"outliers":3,"per_second":2473.03063395018}},"suite":"Text::Xslate::Benchmark::Interpolate","perl_version":"v5.20.2"}
{"run_at":"2018-12-04T00:46:21","perl_version":"v5.20.2","suite":"Text::Xslate::Benchmark::Interpolate","results":{"iterations":{"total":36,"outliers":16,"per_second":126592.47155743},"runtime":{"relative_sigma":0.00115608918757334,"sigma":9.13236919502653e-11,"mean":7.89936390132285e-06}},"name":"sprintf"}
```

Each benchmark is one JSON line, reporting the results as well as the
benchmark suite, name, global environment variables as well as those we've thrown in.
The goal here is to pour out all the information in a big, ugly mess of a
heap. The joys of reporting and
data munging fun will be for later.

## Run the suites across versions

Now, I want to make sure my changes didn't decrease performance. This mean
I need to compare the performance of several versions.

No problem. But before we get to it, as the `benchpress` files aren't present
in previous versions of the code, I need to create a worktree of the
repository that will remain stable as we move across tags and branches:

```
# check out the branch 'benchpress' in the directory 'benchpress'
$ git worktree add benchpress benchpress
```

With that done, we can now run our benchmarks across all recent
versions of the module:

```bash
# my shell is 'fish'. would be slightly different in bash
$ for version in v3.5.0 v3.5.1 v3.5.2 v3.5.3 v3.5.4 v3.5.5 v3.5.6;
    git checkout $version;
    benchpress -I lib -I benchpress/benchmark \
        Text::Xslate::Benchmark:: >> benchpress/benchmarks.json;
    end
```

Oh yeah: I didn't want to type all the benchmark modules all the time,
so I reached out to [Module::Pluggable](cpan) so
that I could expand `Text::Xslate::Benchmark::` to all findable
modules in that namespace.

## From stats to report

By now we have a file `benchmarks.json` filled with nice statistics.
But we want tables! We want graphs! Mostly, we want an excuse to play with R!

So I wrote some baby R:

<pre data-src="./report.r"></pre>

Invoked `Rmarkdown`:

```bash
$ R -e "rmarkdown::render('stats.Rmd')"
```

And, **boom**, [a report](./stats.htm) is born.

Tadah.

[PR]: https://github.com/xslate/p5-Text-Xslate/pull/140

