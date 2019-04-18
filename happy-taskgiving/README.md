---
created: 2017-11-24
tags:
    - taskwarrior
---

# Happy Taskgiving!

To celebrate Thanksgiving week-end, I'm pushing a new version of 
[Taskwarrior::Kusarigama](cpan:Taskwarrior-Kusarigama) that
adds two commands that might make weekly task reviews a tad easier:
`task-kusarigama review` and and `task-kusarigama decimate`.

## `task-kusarigama review`

When I create new tasks, I typically
don't give them priorities: if it's something I'd like to add at the front of
the queue I tag it with `+focus`, otherwise it just got heaped 
with the general, amorphous blob of things to do. 
The prioritizing usually comes when I do my weekly review,
where one step consists of going through all new, unprioritized tasks and
flesh them out. The goal of the `review` command is to help me breeze through
that process.

What is does is straightforward: it shows me all unprioritized tasks, one by
one, and provides me with a set of one key commands to process them. '`H`',
'`M`'
and '`L`' will set the priority to high, medium or low and move to the next
task. '`.`' will let me modify the task like `task mod` would. '`,`' will append,
'`a`' will let me annotate the task, '`n`' will give up on that task and show me
the next one (I should modify the code so that the command gives me a dirty look
when invoked), etc.

<Asciinema src="/entry/happy-taskgiving/files/review.json" />

## `task-kusarigama decimate`

That subcommand is a little more nifty. I think you'll agree: 
reviewing new tasks is fairly
easy. They are (relatively) small in number and easy to spot.
But during the weekly review, I also like to take a peek at my old tasks. And
that's a little more daunting, because there is so. much. bloody. more. of them. 

So I tried to come up with a good way to stir the task pot that will distribute the
heat evenly (so to speak). What I do is setting a target ratio for my
high/medium/low priority tasks -- right now I'm using 10%/60%/30% -- and move
tasks during the weekly review such that those percentages are met. The goal
being to reevaluate priorities and pertinence of older tasks as time passes,
and to insures that tasks are always reasonable spread
over the emergency spectrum.

That, however, doesn't address the paralyzing effect of leviathanesque
backlogs.
This is where the decimation enters the picture: if I have too
many medium priority tasks and not enough high priority ones (*Ah*!), `decimate`
shows me 10 medium priority tasks and makes me choose which one of the bunch
deserves the promotion. Ten tasks is a good middle-ground number that 
offers enough choices to make picking both manageable and meaningful. 

<Asciinema src="/entry/happy-taskgiving/files/decimate.json" />
