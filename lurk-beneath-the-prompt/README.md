---
created: 2020-01-25
tags: 
    - fish 
    - prompt
---

# What lurks beneath the prompt

> *Note:* This is actually a pretty old blog entry. It was meant to be part of a series of multi-author "show me your prompt, I'll show you mine" entries. The series never came to lift off, but since it'd be a shame to trash a perfectly good -- if slightly mothball scented -- blog entry, here you go, enjoy!


Some people's desks are impeccable affairs of clean efficiency and proper
practicality. At the core, spacious emptiness. At the peripheries, stationaries,
neatly sorted in razor-precise rectilignous, throughly sensical arrangements.

And then there are the desks of other peoples. The jumbled jungles of papers
and pens, piled up helter skelter. The manic mixes of official officious fixtures
and playful trinkets. The toys that go click-clack, the herd of mugs migrating
through a plain peppered with paper clips, the funny carton strips and the
occasional printed out cheatsheet.

Can you guess which category my own desk falls into?
And my command-line environment is no different:

<img src="./cli-yanick-1.png" alt="Yanick's cli prompt" />

Mind you, I say this without shame, without apologies.
I am a magpie, I like to try all the shiny new things. And I love to build
things to solve problems. Not because I particularly need  the problems
solved. Just because, y'know, solving problems is fun.

So it's no wonder my prompt might give the impression to be a little...
involved?


## It starts fishy

First thing to mention, is that on my own machine, I'm 
running [Fish](https://fishshell.com) as my shell. Fish is a shell 
optimized for user-friendly interaction. It offers intelligent autocomplete,
cluefull coloring of keywords, and support weird and cool features like event
triggering. Why not the much more prevalent [ZSH](http://www.zsh.org/), you ask? Well, I
gave it a try, but (amongst other things) found its own auto-complete
system much more byzantine than its pisciform
counterpart. So with Fish I stayed.

The [main
file](https://github.com/yanick/environment/blob/master/fish/functions/fish_prompt.fish)
defining my prompt is both an incredible mess and simple. Messy because what I
did was to take an already-existing prompt and hack it to my liking, and
simple because the different lines of the prompts end up being abstracted into
independent sub-calls. So I'll ask of you a favor: delicately avert your eyes
from the file itself, and thrust me when I say that the crux of it ends up
being akin to

    function fish_prompt

        __task.prompt

        __yanick_prompt_current_time
        __yanick_prompt_user
        __yanick_prompt_status

        __prompt_pwd
        
        git prompt

        __yanick_prompt_sigil
    end


## From the bottom up

If we start at the bottom of the prompt, we have

    ⥼

In other words: a simple sigil -- `⥼` when I'm myself, `#` when I'm root
-- and nothing else. Makes things easier when I copy and paste my command
lines. No time, no path, nothing that I have to scrub away before moving to a
ticket. 

And yes, this is the first and last time in this article where I'll sing the
virtues of simplicity. Savour the moment.

### A symbolic segway

By the by, you might wonder "why that symbol, and not the classic `$`?"
Because that symbol is the unicode symbol for fish tail, and that way I can
recognize which of my terminals are running under fish, and which ones are
running bash. 

Incidentally, a nifty tool to find such unicode symbols is [uni](https://metacpan.org/release/App-Uni), which
allows to do text searches on unicode symbol descriptions:

    ⥼ uni fish

    ⥼ - U+0297C - LEFT FISH TAIL
    ⥽ - U+0297D - RIGHT FISH TAIL
    ⥾ - U+0297E - UP FISH TAIL
    ⥿ - U+0297F - DOWN FISH TAIL
    ⻥- U+02EE5 - CJK RADICAL C-SIMPLIFIED FISH
    ⿂- U+02FC2 - KANGXI RADICAL FISH
    🍥 - U+1F365 - FISH CAKE WITH SWIRL DESIGN
    🎣 - U+1F3A3 - FISHING POLE AND FISH
    🐟 - U+1F41F - FISH
    🐠 - U+1F420 - TROPICAL FISH

## Next stop: git central

Next line is my [git status
line](https://github.com/yanick/environment/blob/master/bin/git-prompt), 
which is only displayed when I'm in a
git repository. 

I'm going to tell you one of my little secrets. A lot of
people find Git to be hard to master. And they are right --
Git *is* hard to master -- but often that difficulty is magnified by the lack of
visibility of all the balls flying in the air. Which files are currently in
the index? Does the local branch follows an upstream remote branch? Is this
push going to be a fast-forward or trigger merging mayhem?

My solution is have my prompt give me a maximum amount of information,
forcefully shoved right
there in front of my eyes every single time I run a command.

Indeed, looking at my screenshot I know that I have untracked files 
(the circled question mark), that I have uncommited modifications in 
the checkout (the pencil), that I'm on branch `log/cli-prompt-yanick` that
follows the branch of the same name in the `origin` remote, and that the
local branch is ahead of exactly 1 commit over its remote (and we can push
cleanly).

And that's only a part of the information that can appear on that line. The
full roster of possible symbols is

<img src="./cli-yanick-2.png" alt="git prompt symbols" />

### Return to Symbolism

Some of you might have noticed that some of the symbols that I use come from
GitHub's octicon font. That's a piece of candy that took me *years* of
rollicking rtfm good fun (not to mention a foray into the deepest pit of insanity that is
called font editing) to get
right. But I think I finally figured it out: adding the desired 
fonts as fallbacks in
[~/.config/fontconfig/fonts.conf](https://github.com/yanick/environment/blob/master/fonts/fontconfig/fonts.conf)
seems to do it for me (and
here "me" implies using konsole and running Ubuntu. Caveat Emptor for any other
terminal emulator and OS/distribution).

## Next level: the usual suspects

Next line up: general information. The time, username, host name, and 
current path (with the git part in a different color if applicable). Not show
in the screenshot: a little red frowny face will let me know if the previous
command failed, and a cogwheel would let me know if there are any jobs running
in the background.

## Final floor: time-tracking

I'm terrible at time-tracking. Worst than that, I'm bad at staying focused on
a single task, as any given task is prone to trigger an interesting case of
yak shaving, which itself leads to another hairy yak, which itself... well,
before I know it, there's a new module is on CPAN, a blog entry has been
eructed, and there is nothing left but a handful of minutes of a previously
pristine day.

But there is hope! These days I'm trying to loosely follow the 
[Mikado Method](https://mikadomethod.wordpress.com/) when developing stuff,
and I discovered [Taskwarrior](http://taskwarrior.org/),
which is so far the task manager tool that jives the most with my brain. 
Even better, Taskwarrior is in the process of getting a younger sibling,
[Timewarrior](https://git.tasktools.org/projects/TM/repos/timew/browse), which might answer even more of my time tracking needs.

But Timewarrior is still in pre-alpha, so for the time being, Taskwarrior it is.
Taskwarrior allows plugins and customization  via hooks *à la* git. So,
(surprise, I know) I ended up writing [a small framework](http://techblog.babyl.ca/entry/taskwarrior)
for those. For the purpose of the prompt, I have a plugin that records the currently
active task in a `TW_CURRENT` environment variable, with the [prompt fish script](https://github.com/yanick/environment/blob/master/fish/functions/__task.prompt.fish)
uses to get the task's information and groom it. 

By the by, you need to do some json manipulation on the fly? Try out
[jq](https://stedolan.github.io/jq/). It's pretty awesome.

## Lessons to take away

* The prompt is your dashboard. Don't be shy to make it have all the gauges, indicators and blinking lights you need to see what's going on.
* Lots of information don't have to be (nay, shouldn't be!) crowded. Unicode symbols, icons, multiple lines, all is fair game to make it readable. And remember: your prompt is for *you*. If it makes sense to you, that's all that matter.
* Modern computers are quick. Like, reeeally quick. Prompt generation can get pretty complex before you begin to see things sludging down. If you think something takes too long for a prompt, try it just to see. You might end up begin pleasantly surprised.
* Use the tools that make sense, and glue them together unabashedly. It's the cli way.

Finally, I purposefully refrained to put too much code in the previous chapters, 
as the goal was more to trigger inspiration. Or mayhaps serve as a cautionary
tale, I'm not entierely sure.  But
if you want to use my setup as a base for your, all the links are there. 
Ditto for all the tools used to make the prompt do its thing. 

Enjoy!




