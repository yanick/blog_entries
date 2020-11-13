---
created: 2020-07-12
tags:
    - taskwarrior
    - pouchdb
    - bertasker
summary: Foolishly pondering a rewrite of taskwarrior
cover_img:
    src: __ENTRY__/berserker.jpg
    alt: an old engravure of a berserker
---

# Re-imagining taskwarrior

<div style="width: 40%; float: right; margin-left: 1em;">
<img src="__ENTRY__/berserker.jpg" alt="an old engravure of a berserker"
    style="width: 100%"
/>
<div style="font-size: small; text-align:center; margin-bottom; 1em;">
Bert (on the right) about to close a pending task (on the left)</div>
<div style="font-size: small;">
By <span lang="en">Unknown author</span> - Oscar Montelius, Om lifvet i Sverige under hednatiden (Stockholm 1905) s.98, Public Domain, <a href="https://commons.wikimedia.org/w/index.php?curid=4013472">Link</a>
</div>
</div>

I've been using [taskwarrior][] as my todo manager for a few years now. 
It is command line-based, extensible by hooks, and jives pretty darn well with
my style. Yet, this week I caught myself pondering semi-seriously over a rewrite.

## Why?

Taskwarrior is 90% made of pure awesomeness. The remaining 10%, though, can be a little
grating. The main offender category is the syncing
server. The server is, like taskwarrior itself, C-based and easy enough
to compile, but the configuration... uuugh, the configuration. It's not that
it's especially hard, and the documentation is actually fairly decent, but
it's onerous has taking a sprawl through a oatmeal-filled bog. 

Beside that? The core is lovely, and it's only a few stubbles at the
periphery that irritate. Off the top of my head, feature-wise I can only 
give a specific annoyance: the recurrence system, which is a tad janky.

So, are we ready to lose a kingdom for the want of a synchronized nail?
Why not join the original project instead of jumping
straight to rewriting heresies? It'd be the sensible thing to do. But... 
the project is entirely C-based. Great for speed, but where the joy of
programming is concerned... at the risk
of repeating myself: *uuuugh...*

Plus, there is the alluring fact that when you take a hard look at it, taskwarrior (and task management at large) is
not rocket science. Fundamentally, what it does is to keep a bunch of 
documents representing tasks, and provide a collection of commands to create,
update and report on them. Where the magic lies is how taskwarrior managed to
make that collection of commands intuitive and expressive. Pragmatically,
that means writing a similar tool from scratch is not as insane as, say,
writing a Quantum Physic Real-time Simulator. Moreover if we are not actually 
thinking of building that new incarnation from primordial scratches, but
rather upon leveraged bits.

## Battleplan

Okay, so let's pretend for a moment that I *do* want to rewrite taskwarrior.
What tech stack should I go for?

### Task database
    
Since that whole rewriting rigmarole came from the problem of synchronization,
it stands to reason that it'd be the first piece of functionality to consider.
Remember when I said task management is not rocket science? That is
mostly true, excepts for some parts where it's a big fat lie.

Data storage and replication? That'd be one of them. 

Fortunately, I know a database engine that might take care of that hard part.
PouchDB is a light database engine compatible with CouchDB. Originally meant
to be run in the browser, it can also be run via NodeJS and can use a leveldb
or SQLite file as its backend. It implements the CouchDB replication protocol and
replication/syncing is integral to it. Even better, one wants to access a
database instance via http, there's a bare-bone [pouchdb http server][]
available.

### Conflict resolution and task logs

PouchDB is awesome and take care of synchronization and all of that. But it
doesn't do everything. Assuming we have our tasks living on two replicated
databases, we have to think about what we want to do when the task will be
changed on both side.

That's a problem we can attack in many different ways. In this case, my first
instinct is to keep a log of all changes done to a task. With such a log, when a conflict
occurs we can figure out where in the log the two versions bifurcate. If the
changes are non-overlapping we can then have the software do the merging. If
not, we can display the two versions to the user, alongside the logs, and ask
them to figure it out.

Generating that log might sounds painful. But wait! We can use [immer][]. It's
a library providing tools to work with immutable data. And if one mutates data using it
-- and that's the interesting part for us -- it can also auto-generate the associated list 
of deltas. Mind you, we'll still have to do the thinky part for ourselves, but
at least we have a way to delegate the tedious bookkeeping away.

### Brief segue: multi-user 

### CLI commands

`taskwarrior` is a command line application. Since this hypothetical rewrite
is JavaScript-based, it could potentially have browser-based replicates. But
as a first stroke, let's stay close to our roots. Command line it is, and just
like taskwarrior itself, we want a lot of subcommands à la git.

JavaScript has a few libraries helping with the munging of command line
arguments. [yargs][] and [commander][] are two that springs to mind. Both are
good, but yargs is
pirate-themed. So it gets my vote. 

Beyond the arguments munging, who says cli app says pretty colors ([chalk][]
does that). And for reporting all those tasks, we'll have to print tables --
which [columnify][] does nicely enough.

Oh yeah, and then we'll have a lot of date arithmetic and formatting to deal with. 
We'll need [date-fns][] for that.

## Putting the specs together

Gathering all those tech bits together, and we have the first draft of 
a stack:

* [typescript][] -- because that's where all the cool kids are at.
* [pouchdb][] -- nosql goodness, without the behemothian footprint
* [immer][] -- changelogs for free! Plus immutability is nifty.
* [yargs][] -- command-line application made easy, matey!
* [chalk][] -- we are too far in the future for drab black and white.
* [columnify][] -- report, it's all about reports.
* [date-fns][] -- because second since the epoch won't cut it.

All that is lacking is a codename for the project. Hmmm... Like taskwarrior,
but admittedly insane. Mad task warrior... Task berserker...? **Bertasker**!
Yes!  Bonus point: we can name the command-line app `bert`, and forever picture it
as a task-minded loincloth Clippy.

Excellent. Now all that is left to do is, well, write the thing. I actually
have a proof of concept importing tasks from taskwarrior and printing them on
my laptop. I'll clean it up and put it on GitHub in the upcoming days. Stay
tuned!

[taskwarrior]: https://taskwarrior.org
[chalk]: https://github.com/chalk/chalk#readme
[columnify]: https://github.com/timoxley/columnify
[commander]: https://github.com/tj/commander.js#readme
[date-fns]: https://date-fns.org
[immer]: https://immerjs.github.io/immer/docs/introduction
[pouchdb]: https://pouchdb.com 
[pouchdb http server]: https://github.com/pouchdb/pouchdb-server#readme
[typescript]: https://typescriptlang.org/
[yargs]: https://yargs.js.org/
