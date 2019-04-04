---
created: 2016-03-06
---

# The Taskwarrior's Kusarigama

I'm in love again. Well, okay, that's slightly inexact. Love has
to do with dates. And this is more about task management.

(*ba bum tssssssh*)

Okay, seriously now.  Managing my tasks is something that I tried to do for a
long time, and never quite succeeded in doing in a satisfactory manner. In
the days of yore, my ex-ex-company arranged for a [Franklin
Planner](https://franklinplanner.fcorgp.com) seminar, and it helped. And then
I read [Getting Things Done](http://gettingthingsdone.com/) (it helped too).
But I tried to manage things on paper, and it didn't stick. And then I tried
many, many software solutions across the years. Web services, shell aliases,
vim plugins. A lot of them came *soooooo*
close to be good solutions, but you know how particlar us hackers are about
our itches; a scratchpost taking care of 90% of the itch can be just as
maddening as no scratchpost at all.  The offering that came the closest to 
make me happy was Hiveminder, by [Best Practical](https://bestpractical.com/). By now the service is
discontinued, but if you feel brave the source code has been 
[made available on GitHub](https://github.com/bestpractical/hiveminder/).

And then, by chance I came across a (to me) new task management 
tool: [Taskwarrior](http://taskwarrior.org). It is cli-based, but comes
with a daemon that makes it possible to keep tasks on several machines
synchronized. It does tagging, recurrences, can hide tasks for a time, and has
some inspired urgency algorithm. Even
better: it supports excellent JSON exporting/importing and has a hook 
system *a la* Git that opens the doors wide for customization.


## Hooks that get the jab done

Taskwarrior run hooks for four types of event: when the command is launched, when
a new task is added, when a task is modified, and when the command terminates. 
Just as for Git, the hooks are simple executables put in the `~/.task/hook` folder.
The scripts are passed information about the task command being used, have
access (and can alter) the tasks being created/modified, and have the capacity
to abort the whole process.

## Turning those hooks into deathly weapons

This is already very good. But you know me. Leaving *very good* alone is not
something I do. So I wrote a plugin system,
[Taskwarrior::Hooks](https://github.com/yanick/Taskwarrior-Hooks) to manage those hooks. 
It's not on CPAN yet because I still have to write the documentation, but let
me give you a sneak peak.

### Equipping the Taskwarrior

First thing is to drop in scripts that will invoke the `Taskwarrior::Hooks`
system on all events. We can do that manually


    #!/usr/bin/env perl
    # file: ~/.task/hooks/on-launch-tw_hooks.pl

    use Taskwarrior::Hooks;

    Taskwarrior::Hooks->new( raw_args => \@ARGV )
        ->run_event( 'launch' ); # change event for the 4 scripts, natch

or we can use the helper script that is included in the project, `twhooks`,

    $ twhooks install
    Installing hooks in /home/yanick/.task/hooks
    '/home/yanick/.task/hooks/on-exit-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-add-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-launch-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-modify-tw_hooks.pl' already exist, skipping
    Performing plugins setup...
    Done

After that, we specify which plugins we want to use, and tweak the Taskwarrior
configuration to accomodate them. For example

    $ task config twhooks.plugins Renew,Command::Before,Command::After,GitCommit

    # config for Renew plugin
    $ task config uda.renew.type    string
    $ task config uda.renew.label   creates a follow-up task upon closing
    $ task config uda.rdue.type     string
    $ task config uda.rdue.label    next task due date
    $ task config uda.rwait.type    string
    $ task config uda.rwait.label   next task wait period

    # etc

Or, again, using `twhooks`

    $ twhooks add Renew Command::Before Command::After GitCommit
    setting plugins to Renew, Command::Before, Command::After, GitCommit
    Config file /home/yanick/.taskrc modified.

    $ twhooks install
    Installing hooks in /home/yanick/.task/hooks
    '/home/yanick/.task/hooks/on-exit-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-add-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-launch-tw_hooks.pl' already exist, skipping
    '/home/yanick/.task/hooks/on-modify-tw_hooks.pl' already exist, skipping
    Performing plugins setup...
    -Taskwarrior::Hooks::Plugin::Renew
    -Taskwarrior::Hooks::Plugin::Command::Before
    creating pseudo-report 'before'
    Config file /home/yanick/.taskrc modified.
    -Taskwarrior::Hooks::Plugin::Command::After
    creating pseudo-report 'after'
    Config file /home/yanick/.taskrc modified.
    -Taskwarrior::Hooks::Plugin::GitCommit
    Done

And that's it. Taskwarrior will now use those plugins. 

Now, let's have a look at a few of those plugins, and see what
the system can allow us to do.

### GitCommit - doing stuff *en passant*

The simplest plugins, those that don't do anything to the tasks themselves.  
In the case of the `GitCommit` plugin, it turns the `~/.task` directory into a 
Git repository and perform a commit each time a command modify tasks. Why?
Simply because, while Taskwarrior has history and an `undo` command, Git is
still the ultime hackish backup mechanism for things that save their data in a text-ish
format.

So, what does this plugin looks like? It looks like this:

    package Taskwarrior::Hooks::Plugin::GitCommit;

    use strict;
    use warnings;

    use Moo;

    extends 'Taskwarrior::Hooks::Hook';

    with 'Taskwarrior::Hooks::Hook::OnExit';

    use Git::Repository;

    sub on_exit {
        my $self = shift;

        my $dir = $self->data_dir;

        unless( $dir->child('.git')->exists ) {
            Git::Repository->command( init => $dir );
            $self .= "initiated git repo for '$dir'";
        }

        my $git = Git::Repository->new( work_tree => $dir );

        # no changes? Fine
        return unless $git->run( 'status', '--short' );

        $git->run( 'add', '.' );
        $git->run( 'commit', '--message', 'on-exit saving' );
    };

    1;

Pretty self-explanatory. Except maybe for the `$self .= "blah";` part.
Taskwarrior hooks are expected to spit out optional feedback when things go
well, or an error message if the hook aborts the operation. Aborting, and its
error message are taken care of with issuing a `die` (we'll see an example of
that in a subsequent plugin. For the feedback, it can be provided via
`$self->add_feedback( "blah" )`, but I went a step cuter and overloaded the `.=` 
operator to do the same thing.

### ProjectAlias - grooming tasks

Next step: having a plugin that modify tasks as they are created or modified.
For example, with Taskwarrior you assign projects to tasks using the
`project:foo` construct. That's long. I want to use `@` instead.

    package Taskwarrior::Hooks::Plugin::ProjectAlias

    use strict;
    use warnings;

    use Moo;

    extends 'Taskwarrior::Hooks::Hook';

    with 'Taskwarrior::Hooks::Hook::OnAdd';
    with 'Taskwarrior::Hooks::Hook::OnModify';

    sub on_add {
        my( $self, $task ) = @_;

        my $desc = $task->{description};

        $desc =~ s/(?:^|\s)\@(\w+)// or return;

        $task->{description} = $desc;

        $task->{project} = $1;
    }

    sub on_modify { 
        my $self = shift;
        $self->on_add(@_);
    }

    1;

Wasn't very hard to implement, was it? The tasks are passed to the `on_add` and
`on_modify` as structures, and the JSON conversions are done by the plugin
system for you. And while we can't see it here because it's a trivialy simple
plugin, the `on_modify` method also get the old state of the task, and even
provide the delta between the old structure and the new, to make detection of
changes as easy as possible.

### Renew - orchestring follow-up actions

Okay, this is were things might get more interesting. Remember I mentioned
Taskwarrior does recurrence? It does, but it only do "clockwork" recurrences.
That is, if you set up a task to repeat itself every week on Monday, a new
instance of the task will appear on each Monday, no matter if you complete the
previous instance or not. Sometimes, that's what we want, but there are tasks
-- like, say, watering the plants --
where we'd want the new task to be created when (and relative to) the previous
instance is complete.

Fortunately, implementing that kind of behavior with our plugins is not too
onerous. We tag those repeating tasks with a new attribute (`renew`), and
will monitor when tasks get done to intervene and create their next iteration.

    package Taskwarrior::Hooks::Plugin::Renew;

    use strict;
    use warnings;

    use Clone 'clone';
    use List::AllUtils qw/ any /;

    use Moo;
    use MooseX::MungeHas;

    extends 'Taskwarrior::Hooks::Hook';

    with 'Taskwarrior::Hooks::Hook::OnExit';

    use experimental 'postderef';

    # will be used by `twhooks install`
    has custom_uda => sub{ +{
        renew   => 'creates a follow-up task upon closing',
        rdue    => 'next task due date',
        rwait   => 'next task wait period',
    } };

    sub on_exit {
        my( $self, @tasks ) = @_;

        # only interested by closing tasks
        return unless $self->command eq 'done';

        my $renewed;

        for my $task ( @tasks ) {
            next unless any { $task->{$_} } qw/ renew rdue rwait /;
            $renewed = 1;

            my $new = clone($task);

            delete $new->@{qw/ end modified entry status uuid /};

            my $due = $new->{rdue};
            $new->{due} = $self->calc($due) if $due;

            my $wait = $new->{rwait};
            $wait =~ s/due/$due/;
            $new->{wait} = $self->calc($wait) if $wait;

            $new->{status} = $wait ? 'waiting' : 'pending';

            $self->import_task($new);
        }

        $self .= 'created follow-up tasks' if $renewed;
    }

    1;


Still not too bad, isn't? And now we can create one of those renewing tasks
via

    $ task add renew:1 rdue:now+1week rwait:due-3days Water plants


### Before, After - adding new commands

Something that I love about `Git` is how any script named `git-something` is
invoked as the `something` subcommand for `git`. Taskwarrior, out of the box,
doesn't do that. At least, not exactly. **But** it allows for custom reports. 
So... If we were a devious lot, we could piggyback on that feature, and use a
plugin to detect if that report-cum-command is invoked, and hijack the process
with it...

And, if nothing else, we *are* a devious lot... Devious, and lazy. Which is
why `Taskwarrior::Hooks` implements a pseudo-event "onCommand", which
intercepts those reports for us at launch-time.

For our example here, we have `Before`, which creates a new task and mark it
as a depedency of an already-existing task. In other words, we'll be able to
do

    $ task 100 before Do the thing that must come first

instead of

    $ task add Do the thing that must come first
    $ task 100 mod depends:*whatever task id that new task has*

And we do that via

    package Taskwarrior::Hooks::Plugin::Command::Before;

    use 5.10.0;

    use strict;
    use warnings;

    use Moo;

    extends 'Taskwarrior::Hooks::Hook';

    with 'Taskwarrior::Hooks::Hook::OnCommand';
    with 'Taskwarrior::Hooks::Hook::OnExit';

    sub on_command {
        my $self = shift;

        my $args = $self->args;
        $args =~ s/(?<=task)\s+(.*?)\s+before/ add revdepends:$1 /
            or die "'$args' not in the expected format\n";

        system $args;
    };

    sub on_exit {
        my $self = shift;

        for my $task ( grep { $_->{revdepends} } @_ ) {
            for my $depending ( split ',', $task->{revdepends} ) {
                system 'task', $depending, 'mod', 'depends:' . $task->{uuid};
            }
        }
        
    }

    1;

Cute, eh?

## More to come

Assuming that I don't get distracted by other shinies, the cleaned-up,
documented version of `Taskwarrior::Hooks` should hit CPAN at some point.
Until then, there is the [GitHub
repo](https://github.com/yanick/Taskwarrior-Hooks).
I will also share my `fish` shell completion file as soon as it stabilize. And
there is little doubt that a few utility scripts will pop up before long as
well. So... stay tuned!
