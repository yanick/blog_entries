---
created: 2015-11-04
---

# Win Some, Test::Some

Gather 'round, children, for I am about to bedazzle you with my next trick...

First, look at that test file.

```perl
use strict;
use warnings;

use Test::More;

subtest eeny  => sub { pass };
subtest meeny => sub { fail };
subtest mo    => sub { pass };
```

See? Nothing there. Just regular `subtest`s. And, indeed,
running it causes no surprises.

```bash
$ perl example.pl 
    # Subtest: eeny
    ok 1
    1..1
ok 1 - eeny
    # Subtest: meeny
    not ok 1
    #   Failed test at example.pl line 9.
    1..1
    # Looks like you failed 1 test of 1.
not ok 2 - meeny
#   Failed test 'meeny'
#   at example.pl line 9.
    # Subtest: mo
    ok 1
    1..1
ok 3 - mo
1..3
# Looks like you failed 1 test of 3.
```

Now, to be truly magical, imagine that the test file is much, much bigger and
all subtests are huge and slow as molasse, and
that you're only interested in `meeny` right now. Wouldn't be cool to just run
that one? Well... Follow my hands, kids...

```bash
$ perl -MTest::Some=meeny example.pl 
    # Subtest: eeny
    1..0 # SKIP Test::Some skipping
ok 1 # skip Test::Some skipping
    # Subtest: meeny
    not ok 1
    #   Failed test at example.pl line 9.
    1..1
    # Looks like you failed 1 test of 1.
not ok 2 - meeny
#   Failed test 'meeny'
#   at lib/Test/Some.pm line 89.
    # Subtest: mo
    1..0 # SKIP Test::Some skipping
ok 3 # skip Test::Some skipping
1..3
# Looks like you failed 1 test of 3.
```

Wait, I'm not done! Don't care about the final number of tests and want all
the uninteresting tests to not only be skipped, but disappear altogether?
Well... Abra... 

*cada*... 

**BRA**

```bash
$ perl -Ilib -MTest::Some=~,meeny example.pl 
    # Subtest: meeny
    not ok 1
    #   Failed test at example.pl line 9.
    1..1
    # Looks like you failed 1 test of 1.
not ok 1 - meeny
#   Failed test 'meeny'
#   at lib/Test/Some.pm line 89.
1..1
# Looks like you failed 1 test of 1.
```

## Not magic after all, only spontaneous etheric transmutation

As all good magic tricks, this one relies on simplicity and sleight of hand.
My new module, [](cpan:Test-Some), wraps Test::More's `subtest` in a function
that skip/bypass the tests if they aren't part of the wanted whitelist.

The whitelist can be defined in a few ways.

### Plain old subtest names

```perl
# will run subtests 'foo' and 'bar'.
use Test::Some 'foo', 'bar';
```

### Anything but that one

You can go negative instead and specify tests you don't want to see run.

```perl
# run all tests but 'foo'
use Test::Some '!foo';
```
Note that a subtest is run if it matches any item in the whitelist, so

```perl
use Test::Some '!foo', '!bar';
```

will run all tests as `foo` is not `bar` and vice versa.

### Regular expressions

It just wouldn't be all that fun if we couldn't use regular expressions in
there as well.

```perl
# run all tests beginning with 'foo'
use Test::Some '/foo';

# or

use Test::Some qr/foo/;
```

Incidentally, the cutesy `/foo` instead of plain old `qr/foo/` is there
so that the shell invocation `perl -MTest::Some=/foo` will work too.

### Tags

We can also flag that we only want the subtests with the given tags to be run

```perl
use Test::Some ':basic';
```

"*Wait*", I hear you say, "*did you say tag?*" Yes I did, my friend, yes I
did. Test::More's `subtest` takes two arguments, the name of the tests and the 
coderef holding the test itself. If you add trailing values, the original
`subtest` will ignore them. But the Test::Some wrapper will consider them to
be tags.

```perl
use Test::Some ':basic';  # will only run subtest 'foo'

subtest foo => sub { .... }, 'basic';

subtest bar => sub { .... }, 'complex', 'auth';

```

 Tadah! Instant, backward-compatible tags for tests! How's that for a
Prestige?

Now, I know that the `sub { ... }` part can get pretty big, and the tags could
get lost in the noise. I don't have a perfect answer for that, but I can at
least offer a mitigating workaround:

```perl
subtest foo => \&_foo, 'tag1', 'tag2';
sub _foo {
    ok something(), "weeee!";
    ...
}
```

### Mix them up

Guess what? We can also mix those tags as we want.

```perl
# run all tests with no tags beginning with 'foo'
use Test::Some '!:/^foo';
```

### Or just do whatever you want

Names, tags and regular expressions are not enough for you? *Sheesh* But okay,
you can also pass a coderef as a condition. The name of the test and its tags
will be passed to it as `$_` and `%_`.

```perl
use DateTime::Functions qw/ now /;

use Test::Some sub {
    # only run important tests on Friday
    now()->day_of_week != 5 or $_{important};
};
```

### Oh yeah, and mum about the whole thing

Almost forgot: the filter '~' means "don't SKIP the tests, but bypass them
altogether". It'll mess up the final number of tests if the test is  using
`plan tests => $n` instead of ``done_testing()`, but if blessed silence
is what you want, `~` will make you happy.

Enjoy!


