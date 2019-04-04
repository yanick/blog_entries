---
created: 2018-08-23
tags: 
    - perl 
    - Parallel::ForkManager 
    - Moo
---

# Parallel::ForkManager v2: the moonager cometh 

I did a thing. Which might end up be one of the achievements engraved under my name
at the CPANtheon, or might cause a swift pitchfork-engineered crowd-sourced
demise. 

Or both. 

Yeah. Both is definitively a possibility.

Anyway. By the time you read this, I will have pushed a new trial version
of [Parallel-ForkManager](cpan:Parallel-ForkManager) to CPAN. This new version
flips the major version number from `1` to `2`, which has been a sign 
since medieval times that holy heck, we better hide children and livestock 
down the cellars 'cause something dark is coming.

In this instance, the big, huge change is an 
overhaul of the package to [Moo](cpan:Moo).

So, what does that mean for you? 

## Good news

If you are a casual user of `Parallel::ForkManager`,
you probably won't even notice it. I took some effort to ensure that 
the API didn't change. To the point that the test cases are still passing
unmodified. Of course, disclaimer: while I *think*
the old code should still run without any problem, I've been wrong
before.

## More good news 

If you ever wished that `Parallel::ForkManager`
would use a different communication mechanism between parent and children, or
that you wanted to tweak some behavior, the change to `Moo` makes it 
ridiculously easy to go wild. 

For example, you'd like the children to bail out using `POSIX::_exit` instead
of the regular `exit()`? That's how you can do it:

```perl
use Parallel::ForkManager;

package Parallel::ForkManager::Child::PosixExit {
    use Moo::Role;
    with 'Parallel::ForkManager::Child';

    sub finish  { POSIX::_exit() };
}

my $fm = Parallel::ForkManager->new(
    max_proc   => 1,
    child_role => 'Parallel::ForkManager::Child::PosixExit'
);
```

Want your parent/children communication go over a REST service?

```perl
package Parallel::ForkManager::Web {

    use HTTP::Tiny;

    use Moo;
    extends 'Parallel::ForkManager';

    has ua => (
        is => 'ro',
        lazy => 1,
        default => sub {
            HTTP::Tiny->new;
        }
    );

    sub store {
        my( $self, $data ) = @_;

        $self->ua->post( "http://.../store/$$", { body => $data } );
    }

    sub retrieve {
        my( $self, $kid_id ) = @_;

        $self->ua->get( "http://.../store/$kid_id" )->{content};
    }
}

my $fm = Parallel::ForkManager::Web->new(2);

   # usual stuff goes here

```

## Under the hood

I'll keep the technobabble short. The overhaul to Moo mostly collapses a
lot of the code into object attributes. The bit of new cleverness I injected 
is that, instead of having functions trying to figure out if they are in the
parent or child process, I now have the forked incarnation of the 
ForkManager object consume a `Parallel::ForkManager::Child` role that
augments the original object with childish behaviors.

## TRIAL and errors

I am usually rather cavalier about major API changes on 
my distributions. The prerogative of authors who are also
the de facto quorum of their userbase, I guess.  But
`Parallel::ForkManager` is different.
Since it is a rather large fish in the CPAN River,
I ought to be slightly more poised and tactful. 

Which is why this new version 
has been released as a *TRIAL*, and it'll remain so for at least one month. If
by the end of September I didn't receive any [panicked
feedback](https://github.com/dluxhu/perl-parallel-forkmanager/issues), I'll take a
deep breath and hit the *fo' real release* button. If there is any panicked 
feedback, it'll be addressed, and the clock will be set back.

That is to say, TL;DR: you do use `Parallel::ForkManager`, do yourself a 
favor, download the trial version and give it a whirl. Because it's
incontestably better for anyone if you discover that I'm a genius on that trial 
release rather than an utter idiot on the next general-use release.




