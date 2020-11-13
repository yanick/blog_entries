---
url: git-cpan-patch-v1
format: markdown
created: 2013-01-01
tags:
    - Perl
    - Git::CPAN::Patch
---

# New And Improved: Git::CPAN::Patch -- Now With MetaCPAN Power

<div style="float: right">
<img src="val_approuve.png" alt="New and Improved!" width="300"/>
</div>

What better way to start the year than to bring a fresh new breath to an old
favorite? And thus, as you read this a new version of [Git::CPAN::Patch](cpan) should be
making its way to CPAN.

This new version is a massive refactoring of the module's guts, which will
affect both end-users and developers. For the best. Mostly. Or so I hope.

## What's In For End-Users?

### One Main Command To Rule Them All

Most obvious, the cli interface has been collapsed to a single main command,
`git-cpan` which, thanks to the way `git` discovers its subcommands, can also
be called the old-fashioned way.

```bash
    # new way to call git-cpan
    $ git-cpan --help
    Missing command
    usage:
        git-cpan command [long options...]
        git-cpan help
        git-cpan command --help

    global options:
        --help --usage -?  Prints this usage information. [Flag]
        --man              Prints the command's manpage [Flag]

    available commands:
        clone         
        format-patch  
        help          Prints this usage information
        import        
        send-email    
        send-patch    
        sources       
        squash        
        update        
        which         

    # but this still works
    $ git cpan sources --help
    usage:

        % git-cpan sources Foo::Bar



    options:
        --backpan          show backpan information [Flag]
        --help --usage -?  Prints this usage information. [Flag]
        --nocpan           show cpan information [Flag]
        --norepository     show repository information [Flag]
        --root             Location of the Git repository [Default:"."]
```


### New Lifecycle

The gaggle of subcommands have been stream-lined and modified.  For the vast
majority of users, it means that the life-cycle of a patch will now look like:

```bash
    $ git-cpan clone Git::CPAN::Patch
    fetching http://cpan.metacpan.org/authors/id/Y/YA/YANICK/Git-CPAN-Patch-0.8.0.tar.gz
    creating Git-CPAN-Patch
    created tag 'v0.8.0' (a0e8c70fd931a796292c92fc9e7576790be4e175)

    $ cd Git-CPAN-Patch/

    $ echo foo >> MANIFEST 

    $ git commit -m "yadah" MANIFEST
    [master 85ab598] yadah
    1 file changed, 1 insertion(+)

    $ git-cpan send-patch
    0001-yadah.patch
    Who should the emails appear to be from? [Yanick Champoux <yanick@cpan.org>] 
    Message-ID to be used as In-Reply-To for the first email? 
    Send this email? ([y]es|[n]o|[q]uit|[a]ll): y
    0001-yadah.patch
    Emails will be sent from: Yanick Champoux <yanick@cpan.org>
    (mbox) Adding cc: Yanick Champoux <yanick@cpan.org> from line 'From: Yanick Champoux <yanick@cpan.org>'

    From: Yanick Champoux <yanick@cpan.org>
    To: bug-Git-CPAN-Patch@rt.cpan.org
    Cc: Yanick Champoux <yanick@cpan.org>
    Subject: [PATCH] yadah
    Date: Tue,  1 Jan 2013 16:58:05 -0500
    Message-Id: <1357077485-17361-1-git-send-email-yanick@cpan.org>
    X-Mailer: git-send-email 1.7.9.5

        The Cc list above has been expanded by additional
        addresses found in the patch commit message. By default
        send-email prompts before sending whenever this occurs.
        This behavior is controlled by the sendemail.confirm
        configuration setting.

        For additional information, run 'git send-email --help'.
        To retain the current behavior, but squelch this message,
        run 'git config --global sendemail.confirm auto'.

    OK. Log says:
    Sendmail: /usr/sbin/sendmail -i bug-Git-CPAN-Patch@rt.cpan.org yanick@cpan.org
    From: Yanick Champoux <yanick@cpan.org>
    To: bug-Git-CPAN-Patch@rt.cpan.org
    Cc: Yanick Champoux <yanick@cpan.org>
    Subject: [PATCH] yadah
    Date: Tue,  1 Jan 2013 16:58:05 -0500
    Message-Id: <1357077485-17361-1-git-send-email-yanick@cpan.org>
    X-Mailer: git-send-email 1.7.9.5

    Result: OK
```

### Friggin' Fast

Last but not least, almost all ties to CPANPlus have been severed in favor
of MetaCPAN, which means that cloning a distribution from CPAN is now, very,
very fast.

```bash
    $ time git-cpan clone Git::CPAN::Patch my-clone-dir
    fetching http://cpan.metacpan.org/authors/id/Y/YA/YANICK/Git-CPAN-Patch-0.8.0.tar.gz
    creating my-clone-dir
    created tag 'v0.8.0' (5640120bf0e1cd7e08429723fd1e737f9e56b487)

    real    0m3.025s
    user    0m1.180s
    sys     0m0.456s
```

### Oh Yeah, I Probably Broke Lotsa Things Too

The dark side of any major rewrite: lots of options previously supported have
been put on ice, and I doubtlessly messed up here and there. But such is the
price of progress... In any case, just be prepared to caveat your emptor when
you'll download the new version and -- by all means -- don't be shy about
submitting bug reports.

## Under The Hood

Huge changes here. I wanted for a long time to tighten the way the module's
scripts are handled and cut a little bit on the `system()` calls. After
test-driving [MooseX::App::Cmd](cpan),
[MooseX::App](cpan) and [MooX::Cmd](cpan), I decided to try my luck
with [MooseX::App](cpan) (the three modules, incidentally, are very close
to each other in term of feature-set. To decide which one would be best for me, I ended up writing the same
Proof of Concept mini-app with each of them. If anyone's interested, I can
share the results on GitHub)

Net result: everything is much more concise and organized. 

Functionality 
used by more than one command got shoved in roles. For example, interactions
with the repository are now the dominion of `Git::CPAN::Patch::Role::Git`:

```perl
    package Git::CPAN::Patch::Role::Git;

    use strict;
    use warnings;

    use Method::Signatures;
    use version;
    use Git::Repository;

    use Moose::Role;
    use MooseX::App::Role;
    use MooseX::SemiAffordanceAccessor;

    option root => (
        is => 'rw',
        isa => 'Str',
        default => '.' ,
        documentation => 'Location of the Git repository',
    );

    has git => (
        is => 'ro',
        isa => 'Git::Repository',
        lazy => 1,
        default => method {
            Git::Repository->new(
                work_tree => $self->root
            );
        },
        handles => {
            git_run => 'run',
        },
    );

    method last_commit {
        eval { $self->git_run('rev-parse', '--verify', 'cpan/master') }
    }

    method last_imported_version {
        my $last_commit = $self->last_commit or return version->parse(0);

        my $last = join "\n", $self->git_run( log => '--pretty=format:%b', '-n', 1, $last_commit );

        $last =~ /git-cpan-module:\ (.*?) \s+ git-cpan-version: \s+ (\S+)/sx
            or die "Couldn't parse message:\n$last\n";

        return version->parse($2);
    }

    method tracked_distribution {
        my $last_commit = $self->last_commit or return;

        my $last = join "\n", $self->git_run( log => '--pretty=format:%b', '-n', 1, $last_commit );

        $last =~ /git-cpan-module:\s+ (.*?) \s+ git-cpan-version: \s+ (\S+)/sx
            or die "Couldn't parse message:\n$last\n";

        return $1;
    }

    method first_import {
        return !$self->last_commit;
    }

    1;
```


One of the very nice things about this is that as soon as a command consumes
that Git role, it automatically absorbs the cli options related to it
as well. Lovely DRY stuff, that is.

Another win in term of DRYness is how commands that build on each other don't
have to repeat anything.  For example, the `clone` command is just like
`import`, but also initialize the Git repository and smack the `master` branch
on the CPAN checkout. And its module reflects just that:


```perl
    package Git::CPAN::Patch::Command::Clone;

    use 5.10.0;

    use strict;
    use warnings;

    use autodie;
    use Path::Class;
    use Method::Signatures;

    use MooseX::App::Command;

    extends 'Git::CPAN::Patch::Command::Import';

    before import_release => method($release) {
        state $first = 1;

        return unless $first;

        my $target = $self->extra_argv->[1] || $release->dist_name;

        say "creating $target";

        dir($target)->mkpath;
        Git::Repository->run( init => $target );
        $self->set_root($target);

        $first = 0;
    };

    after import_release => method(...) {
        $self->git_run( 'reset', '--hard', $self->last_commit );    
    };

    __PACKAGE__->meta->make_immutable;

    1;
```

### Doing Things to MooseX:App

Although I said that `MooseX::App` was the cli system module closest to what I
wanted, as you can suspect it wasn't *exactly* what I wanted. So I had to do a
couple of things. Some fairly clean and already pushed as patches, others...
shamefully monkeypatched from within Git::CPAN::Patch (I know, I know, I'm a
bad boy).  I added a global `--man` option sprouting the whole
script's manpage via [Pod::Usage](cpan) to go along the already-present `--help`.
I was also not in love with the commands using underscores instead of dashes,
and that got easily fixed. And lastly, the usage summary for the sub-commands
was hard-coded, which is distinctly sub-optimal when they are supposed to take
arguments. Well, what I did so far is fairly horrible (and will be made less
atrocious soon, I swear), but I'm happy to report that the usage now mirrors
the sub-command's `SYNOPSIS`.

```bash
    $ git-cpan send-patch --help
    usage:

        % git-cpan sendpatch

    description:
        This command runs git cpan-format-patch and then if there is one patch
        file runs git cpan-send-email.
        
        Multiple patches are not sent because git send-email creates a separate
        message for each patch file, resulting in multiple tickets.

    options:
        --help --usage -?  Prints this usage information. [Flag]
        --root             Location of the Git repository [Default:"."]
```

## What's Next?

Clearly, fixing all that I broke during the refactoring frenzy. Then, tapping
in the fact that the MetaCPAN information includes the location of the
module's official repository to add the possibility to clone the module from there as well.
And, continuing in that vein, looking into potential synergies between
`Git::CPAN::Patch` and [App::gh](cpan).
