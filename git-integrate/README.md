---
created: 2015-08-29
---

# git-integrate: Bring the Branches Back Home

If lord Byron, or more aptly his daughter, would look how loosely I adhere
to processes, I'm sure either one would agree that while I'm not untrue, I'm
sure fickle as heck. 

It's not that I don't see their values. Not at all. The problem rather lies in
remembering to apply all the steps. Which is why I love [](cpan:Dist-Zilla) so
much; I set the process once, and then I let the software deal with the
tedious tasks of remembering, checking and applying all the required steps 
each time I type `dzil release`.

In the same frame of mind, I have quite a few git shortcuts lying around. Most
are simple aliases, others are slightly more complex scripts. Like this last
entry in my stable: `git-integrate`.

The goal `git-integrate` is to help out merging back feature and
bug branches back into master. The script, as it is now, is quite heavily
tailored to my needs (Perl projects, mostly dzil-powered), but as you will see 
the script can be easily modified to fit pretty much anyone's integration
process. Let me show you.


## Getting out the toolbox

As per usual git magic, the script itself will be called `git-integrate`,
such that invoking

```bash
$ git integrate
```

on the command line will call it. All the cli app shenanigans will be 
dealt by [](cpan:MooseX::App::Simple) and the Git repository interaction
by [](cpan:Git-Repository).

```perl
package Git::Integrate;

use MooseX::App::Simple;
use MooseX::MungeHas 'is_ro';

use Git::Repository 'AUTOLOAD';

use experimental 'signatures';

has git => (
    is => 'lazy',
    default => sub {
        Git::Repository->new( work_tree => '.' );
    },
    handles => { git_run => 'run' },
);

has target => (
    default => 'master',
    documentation => 'branch merged into',
);

# branch to merge
has branch => sub ($self) {
    $self->git->branch =~ /^\* (\S+)/m; $1;
};
```

## Is everything in order?

Eventually, the script will merge the feature branch into the target branch,
but before doing so, there is a couple of things I want to check.

First, is everything properly commited, or is my work tree all dirty with stuff
lying around?

```perl
before run => sub($self) {
    my $status = $self->git->status( '--porcelain' )
        or return;

    die "some files are not commited:\n$status\n";
};
```

Is the feature branch rebased on top of the target branch? (I like my branches
all rebased and neat)

```perl
before run => sub($self) {
    die "not rebased on top of ", $self->target unless
        grep { s/^\* //r eq $self->branch } $self->git->branch( '--contains', $self->target );
};
```

Was I a good boy, and did I add tests for the new code?

```perl
option notestcheck => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

before run => sub($self) {
    return if $self->notestcheck;

    my @tests = $self->git->diff( '--name-only', $self->target, $self->branch, 't' )
        or die "no new tests\n";

    say join "\n\t", "new tests:", @tests;
};
```

And are those tests, and all the other ones, passing?

```perl
option notest => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

before run => sub($self) {
    return if $self->notest;

    die "tests are failing\n" if system 'prove', '-l', 't'; 
};
```

If so, hey, things look good. Let's merge!

## Merge, baby, merge

When merging back to the master branch, I want to edit the changelog with the
new additions. Since I'm rather scatterbrain, it'd be nice to have a view of
all the commit messages of the feature branch to jog my memory.

```perl
use Path::Tiny;

sub run ($self) {
    
    # prepare the log message
    my $log = $self->git->log( '--pretty=full', $self->target . '..' );

    my $msg_file = path( 'git-integrate-msg' );
    $msg_file->spew( $log );

    system 'vim', '-o', $msg_file, 'Changes';

    $msg_file->remove;
```

And since we now have some description in the changelog of what we did in the
merged branch, why not use it as the merge message? 

```perl
    $self->git->commit( '-m', 'changelog', 'Changes' )
        if $self->git->diff( 'Changes' );

    my $msg = "merge branch '" . $self->branch . "'\n\n" 
            . join( "\n", $self->git->diff( $self->target . '..', 'Changes' ) =~ /^(?:[+-] )(.*?)$/mg )
            . "\n\n"; 
```

And let's add some information that GitHub can use to auto-close the related
tickets.

```perl
    $msg .= join ', ', map { "Fixes #$_" } $msg =~ /GH#(\d+)/g; 
```

And with that done, the only have one last step: jump on the master branch and
merge things proper.

```perl
    $self->git->checkout( $self->target );

    $self->git->merge( '--no-ff', '-m', $msg, $self->branch );

    say "merged!";
}
```

Aaaand we're done.

## The Full Script

```
#!/usr/bin/env perl

package Git::Integrate;

use 5.20.0;

use MooseX::App::Simple;
use MooseX::MungeHas 'is_ro';

use Git::Repository 'AUTOLOAD';
use Path::Tiny;

use experimental 'signatures';

option notest => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

option notestcheck => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has git => (
    is => 'lazy',
    default => sub {
        Git::Repository->new( work_tree => '.' );
    },
    handles => { git_run => 'run' },
);

has target => (
    default => 'master',
);

has branch => sub ($self) {
    $self->git->branch =~ /^\* (\S+)/m; $1;
};

before run => sub($self) {
    # first check if all is neatly commited

    my $status = $self->git->status( '--porcelain' )
        or return;

    die "some files are not commited:\n$status\n";
};

before run => sub($self) {
    # are we on top of the target branch?
    die "not rebased on top of ", $self->target unless
        grep { s/^\* //r eq $self->branch } $self->git->branch( '--contains', $self->target );
};

before run => sub($self) {
    return if $self->notestcheck;

    my @tests = $self->git->diff( '--name-only', $self->target, $self->branch, 't' )
        or die "no new tests\n";

    say join "\n\t", "new tests:", @tests;
};

before run => sub($self) {
    return if $self->notest;

    die "tests are failing\n" if system 'prove', '-l', 't'; 
};

sub run ($self) {
    
    # prepare the log message
    my $log = $self->git->log( '--pretty=full', $self->target . '..' );

    my $msg_file = path( 'git-integrate-msg' );
    $msg_file->spew( $log );

    system 'vim', '-o', $msg_file, 'Changes';

    $msg_file->remove;

    $self->git->commit( '-m', 'changelog', 'Changes' )
        if $self->git->diff( 'Changes' );

    my $msg = "merge branch '" . $self->branch . "'\n\n" 
            . join( "\n", $self->git->diff( $self->target . '..', 'Changes' ) =~ /^(?:[+-] )(.*?)$/mg )
            . "\n\n"; 

    $msg .= join ', ', map { "Fixes #$_" } $msg =~ /GH#(\d+)/g; 

    $self->git->checkout( $self->target );

    $self->git->merge( '--no-ff', '-m', $msg, $self->branch );

    say "merged!";

}

__PACKAGE__->meta->make_immutable;

__PACKAGE__->new_with_options->run;
```




