---
url: git-cpan-patch-more-git
format: markdown
created: 2014-02-12 
tags:
    - Perl
    - Git::CPAN::Patch
---

# Git::CPAN::Patch Gets A Bit More Magic

When you'll read this, a new version of
[Git::CPAN::Patch](cpan:release/Git-CPAN-Patch)
will soon be arriving on CPAN. This new version adds two new things
that will make peeps squeal in glee (and indubitably breaks a few other
things, but we'll deal with that later on).

## It'll Find Git Repositories For You

Watch:

``` bash
$ git cpan clone Web::Query
Git repository found: git://github.com/tokuhirom/Web-Query.git
creating Web-Query
From git://github.com/tokuhirom/Web-Query
 * [new tag]         0.01       -> 0.01
 * [new tag]         0.02       -> 0.02
 * [new tag]         0.03       -> 0.03
 * [new tag]         0.04       -> 0.04
 * [new tag]         0.05       -> 0.05
 ...
```

Yeah. That's right. If there is a git repository associated with the
module, `git-cpan` will clone that by default. If there is none, or
if you want to clone from the CPAN releases, you can still do that too (and
thanks to Metacpan magic, we don't have to think about BackPAN either):

```bash
$ git cpan clone --norepository Web::Query
creating Web-Query
created tag 'v0.40.0' (c50356722926db2c29437b63d641cab8be89e3ff)
created tag 'v0.60.0' (3a8e599c7ab50216a20700f2b49c115fbb466b32)
...
```

Only want to create the repository with the latest release? Okay:

```bash
$ git cpan clone --latest --norepository Web::Query
creating Web-Query
created tag 'v0.240.0' (bf900cb6133ad2b1c01c5c2a6d04b1367f1c583d)
```

## Tests!

That one is less of a treat for the end-users and more for fellow devs.
`Git::CPAN::Patch` has long been without tests because it almost has
everything that is a pain in the butt to interact with in a testing
context. It's a command-line tool, working on local git repositories
and interacting with elements on the network. Only interactions with a
database is missing to make the misery picture complete. 
But with the use of judicious tools, that pain can be made bearable.

### Take the command line tool out of the command line

`Git::CPAN::Patch` is based on [MooseX::App](cpan:release/MooseX-App), which helps a
lot with this. Indeed, since everything is classes underneath, we can go
straight for that. If we want to run

``` bash
$ git cpan import --root /tmp Git-CPAN-Patch 
```

 we can forgo the gymnastics of external processes and just stay within the
 comfy confines of Perl:

``` perl
my $command = Git::CPAN::Patch::Command::Import->new(
    root => $root,
    thing_to_import => 'Git-CPAN-Patch',
);

# will run the command just as good as from the command line
$command->run;
```

Bonus points: we now also have the `$command` object with which we can now
test individual methods, inspect internal states, etc.

## Fake the Cloud

Again, thanks to the fact that it's all classes underneath, we can engineer
things such that it's easy to replace our
agents to the outside world by things that are more test-friendly. For that
kind of subterfuge, I usually like to reach out for
[Test::MockObject](cpan:release/Test-MockObject):

```perl
use Test::MockObject;

my $metacpan = Test::MockObject->new
    ->set_false( 'module' )
    ->mock( 'release', sub {
        return { hits => {
            hits => [ {
                fields => {
                    name => 'Git-CPAN-Patch',
                    author => 'YANICK',
                    date => '2011-03-06T01:02:03',
                    download_url => './t/corpus/Git-CPAN-Patch-0.4.5.tar.gz',
                    version => '0.4.4',
                }
            } ],
        }}
    } );


my $command = Git::CPAN::Patch::Command::Import->new(
    root => $root,
    thing_to_import => 'Git-CPAN-Patch',
    metacpan => $metacpan,
);
```

And with that, no network connection to worry about. We also
have total control of what the agent passes to the object, ideal to fake
errors, special cases and anything nasty we can come up with.

## Fake the Ground You Walk In

Well, okay, don't fake the ground, but at least create a remote island that won't
bother anybody else via [File::Temp](cpan:release/File-Temp):

``` perl
use File::Temp qw/ tempdir /;
use Git::Repository 'AUTOLOAD';

# create a disposable directory under ./t
# no cleanup because I'm still in debug mode
my $root = tempdir( 'repo_XXXX', CLEANUP => 0, DIR => './t' );

# create the test git repo and its handler
Git::Repository->run( init => $root );
my $git = Git::Repository->new( work_tree => $root );

note "git directory: $root";

Git::CPAN::Patch::Command::Import->new(
    root => $root,
    thing_to_import => 'Git-CPAN-Patch',
    metacpan => $metacpan,
)->run;

# the command ran, so now we should be able to see what it did

is_deeply [ $git->branch( '-a' ) ] => [ '  remotes/cpan/master' ], 
    "branch is there";

is_deeply [ $git->tag ] => [ 'v0.4.4' ], "tag is there";

... and so on, and so forth ...

```

So yeah, from horrible pain in the tuckus to a much more ameniable few lines of fixture fixin' per
test... there's really no excuse anymore for a total lack of tests.
