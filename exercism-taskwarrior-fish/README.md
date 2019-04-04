---
created: 2017-03-07
---

# Quick Quack Hack: Efishciently track Exorcism progress with Taskwarrior

(The *Quick Quack Hacks* is a new category/experiment for my blog. The goal is
to burp quickly and furiously a tweak I've written for my environment.
Explanations will be minimals. Reasonability won't even be considered.)

So... I've been suckered into starting the Ruby
language track at [Exercism.io](http://exercism.io). 
Since I track my tasks via [Taskwarrior](http://taskwarrior.org), I
should add an entry. And by *I*, I of course mean [a small script](https://github.com/yanick/environment/blob/master/bin/exercism-task.pl).

```perl
#!/usr/bin/env perl

# usage: exorcism.pl _track_

use 5.20.0;

use Web::Query;
use Taskwarrior::Kusarigama::Wrapper;

my $lang = shift;

my $nbr_problems = wq('http://exercism.io/languages')
    ->find('p')
    ->filter(sub{ lc($_->text) eq lc $lang })
    ->next
    ->text +0 
        or die;

my $task = Taskwarrior::Kusarigama::Wrapper->new;

say $task->add( "$lang track +$lang", 
    { project => 'exercism', goal => $nbr_problems } 
);
```

The script uses [Web-Query](cpan:Web-Query) for web scraping, and 
[Taskwarrior::Kusarigama::Wrapper](cpan:Taskwarrior::Kusarigama::Wrapper) to
interact with Taskwarrior. Quick and to the point:

```
$ perl exercism-task.pl ruby
Created task 512.

$ task 512
No command specified - assuming 'information'.

Name                Value
ID                  512
Description         ruby track +ruby (0/84)
Status              Pending
Project             exercism
Entered             2017-03-07 17:55:44 (5s)
Last modified       2017-03-07 17:55:44 (5s)
Virtual tags        PENDING READY UDA UNBLOCKED LATEST PROJECT
UUID                51acffb7-a64e-46a7-a95a-bff1353e5f1c
Urgency                1
quantifiable target 84

    project      1 *    1 =      1
                             ------
                                1

```

Oh yeah, incidentally, the goal and progess is a functionality bit managed by
[Taskwarrior::Kusarigama::Plugin::Command::Progress](cpan:Taskwarrior::Kusarigama::Plugin::Command::Progress).

## Get thee behind me, fishie

Just like there is no fun in creating the task by hand, manually updating
my progress just won't do. Instead, I use a custom [fish function](https://github.com/yanick/environment/blob/master/fish/functions/vaderetro.fish) that, 
upon completion of a problem, submit it to exercism, and fetch the next one,
record my progress, and brag about it all on some Slack channels.

```
function vaderetro 

    set lang ( basename ( readlink -f .. ) )

    set exercism ( basename ( readlink -f . ) )

    set entry \
        scalar      'src/main/scala/*.scala' \
        perl6       '*.pm' \
        javascript  '*.js' \
        ecmascript  '*.js | grep -v -e spec -e gulp' \
        ruby        '*.rb | grep -v -e test' \
        swift       '*.swift | grep -v -e main -e Test'

    exercism submit ( eval ls $entry[( math 1 + ( contains -i $lang $entry ) )] )

    emit exercism $lang $exercism

    exercism fetch $lang

end

function _vaderetro.taskwarrior --on-event exercism

    task +$argv[1] project:exercism progress $argv[2]

end

function _vaderetro.brag --on-event exercism

    if test $argv[1] = swift
        echo "yanick exorcised '$argv[2]'" | slacker -c swift -n exercism -i :imp: 
    end

    if test $argv[1] = ecmascript
        echo "yanick exorcised '$argv[2]'" | slacker -c node -n exercism -i :imp: 
    end

    echo "yanick exorcised '$argv[1]/$argv[2]'" | slacker -c projecteuler -n exercism -i :imp: 
end
```

Short. Sweet. Works.


```
18:13 yanick@enkidu ~/work/exer/exercism/ruby/run-length-encoding
$ vaderetro

Submitted Run Length Encoding in Ruby.
Your submission can be found online at
http://exercism.io/submissions/c18439eedb2f4814842dd2d4a14d5bc0

To get the next exercise, run "exercism fetch" again.
506 ===---------------- 16/84
ran custom command 'progress'

    New: 1 problem
Binary (ruby) /home/yanick/work/exer/exercism/ruby/binary

unchanged: 0, updated: 0, new: 1

$ task 506
No command specified - assuming 'information'.

Name                Value
ID                  506
Description         ruby track       (16/84)
                      2017-03-07 18:13:21 run-length-encoding
Status              Pending
Project             exercism
Entered             2017-03-07 13:23:59 (5h)
Last modified       2017-03-07 18:13:21 (39min)
Tags                ruby
Virtual tags        ANNOTATED PENDING READY TAGGED UDA UNBLOCKED PROJECT
UUID                644b1cad-ec1d-4c91-9964-d6add9368b06
Urgency              2.6
quantifiable target 84
where we're at      16

    project          1 *    1 =      1
    annotations    0.8 *    1 =    0.8
    tags           0.8 *    1 =    0.8
                                ------
                                   2.6

Date                Modification
2017-03-07 13:25:12 Progress set to '15'.
                    Description changed from 'ruby track (0/84)' to 'ruby track  (15/84)'.
2017-03-07 18:13:21 Annotation of 'run-length-encoding' added.
                    Description changed from 'ruby track      (16/84)' to 'ruby track       (16/84)'.


```
