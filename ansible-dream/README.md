---
created: 2020-04-15
tags:
    - ansible
---

# An Ansible dream

This is a blog entry that I've been wanting to blurt out for a long while,
now. Mostly to share the method behind the madness.

So yeah, the gist of this blog entry is: these days when I'm installing command-line tools or tweaking my
configurations, I'm trying to do it via Ansible playbooks. 

"Why?" I hear youses cry. "It's a one time affair. Why can't you, y'know, do
it and be done with it?"

## Do it once, do it twice, do it-- aw, screw it and automate the bloody thing already won't you?

Ah! There is a fallacy there, dear strawman interlocutor. This "one time
affair" actually happens more than once. Sure, I have a main computer, but I
also have my laptop where I typically need the same setup. And then there's my
server downstairs. And my dear $spouse's computer. And then there's my main
computer all over again next time I reinstall the OS. 

Not to forget that since I'm a
consultant, I'm often thrown on remote servers where I might want to bring
some of the comforts of home. And talking of work stuff,
there are some configurations that I might want to share with colleagues.
Like, that extra-weird VPN service that took arcane magical symbols and the
blood of three lambs to get running? It'd be nice to make that rigmarole easy
on the next guy.

So yeah, "one time" happens more often than we think.

## Give future you some love

"Okay," I hear you say, "so you configure things a few times now and then. No
big deal. If you do it once, you'll remember what you did next time, right?"

That's what you'd think, dear strawman, that's what you'd think. And so do I.
Thing is, re-installations and reconfigurations are usually interspersed just
enough that you remember that you did... things, but not the detailed nature
of those things. How often did I pause and I think "oh yeah, there was a
tricky thing to do here that made me swear a lot... what was it?". Or worse "I
should reinstall that tool that is super-helpful to do that thing. What...
what was its name again? I was a pun of some sort... I think?"

Point is: trusting your memory is the best way to knee your future self in the
gonads. Don't knee your future self in the gonads. Send them lover letters
instead and document the *beep* of everything you do.  

In this case, as you may surmise, it'll end up with Ansible playbooks, but as
a minimum, set up a personal wiki and vomit information down. If you only
do that, in all honesty you'll already reap 90% of the advantages 
that going full-hog Ansible would bring.

For example, fonts installation. Where do I put the fonts? What's the command
to refresh the system font cache? What was this weird tweak I had to do
for FiraCode to work with Kitty? Here, future me, here is what you need to
know:

```

fonts belong to /usr/local/share/fonts

FiraCode is at
https://github.com/tonsky/FiraCode/releases/download/1.206/FiraCode_1.206.zip

The weird trick is at ~/.fonts/fontconfig/conf.f/8-firacodespacing.conf and is

    <?xml version="1.0"?>
    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    <fontconfig>
    <match target="scan">
        <test name="family">
        <string>Fira Code</string>
        </test>
        <edit name="spacing">
        <int>100</int>
        </edit>
    </match>
    </fontconfig>

and don't forget to do 

  fc-cache -f -v

```

## Going the extra mile (and then reporting back via hi-tech magic space antenna)

As I said, keeping notes is 90% of the battle. Turning those notes 
into something automated is merely the space cadet bonus track. 

There are several ways to automate those tasks. Puppet, SaltMine, Chef, 
there is even a Perl offering, ReX. So why Ansible? Because of a few things:

1. it can work without local clients. So I don't have to install a ridiculous
amount of things to have it tweak my vim config on a customer's 
server in Virginia.

2. it had a "dry run" mode. A deal breaker for my fairly ad hoc process. I 
really, really want to see what is going to happen before I unleash one of
my configuration munger on my workhorse. I can be foolhardy, but I draw the 
line at batshit yolo insane.

3. the main format is YAML. It's weird coming from this hacker's mouth, but 
the fact that we're not writing straight code
means that we are forced to keep things relatively simple and straightforward.
Plus, YAML reads easily (well, for me). And unlike some misbegotten other
formats, it allows for *comments*. Yes, I'm looking at you, JSON. Shame! 

4. an extension of the previous point, really, but that YAML format makes the transition
between free-form notes and automated recipes.

### Fonts, first Ansible pass

Returning to the previous font example, this would be what it looks like on a
first Ansibling phase:

```yaml
#fonts belong to /usr/local/share/fonts
#
#FiraCode is at
#https://github.com/tonsky/FiraCode/releases/download/1.206/FiraCode_1.206.zip
#
#The weird trick is at ~/.fonts/fontconfig/conf.f/8-firacodespacing.conf and is
#
#    <?xml version="1.0"?>
#    <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
#    <fontconfig>
#    <match target="scan">
#        <test name="family">
#        <string>Fira Code</string>
#        </test>
#        <edit name="spacing">
#        <int>100</int>
#        </edit>
#    </match>
#    </fontconfig>
#
#and don't forget to do 
#
#  fc-cache -f -v
```

Yes, the whole file is one big comment. No I'm not trolling you. Well, not
entirely. The point is that it's trivial to turn the notes into something
that, granted, won't do anything, but at least run happily. I usually start
with that massive, glorious no-op and then convert the steps into
Ansible commands one by one. And if, for any reason, one step is too hard
or too onerous to turn into running code, well, I can always just leave
it as a comment and let future me read it and repeat it manually. Nobody said
we have to automate it all. It'd be nice, but it's also nice to know it's not 
all or nothing, and it doesn't need to be all now.


### Fonts, second (this time functional) Ansible pass

What does the font Ansible playbook looks like once I converted
those steps to actual commands? Glad you asked; it looks like this:

```yaml
- name: make font directory 
  become: yes
  file:
    path: /usr/local/share/fonts
    state: directory

- name: make fira directory 
  become: yes
  file:
    path: /usr/local/share/fonts/fira
    state: directory 

- name: downloads Firacode
  become: yes
  unarchive:
    src: https://github.com/tonsky/FiraCode/releases/download/1.206/FiraCode_1.206.zip
    dest: /usr/local/share/fonts/fira
    remote_src: yes
    creates: /usr/local/share/fonts/fira/specimen.html 

- name: make sure FiraCode is seen as monospace
  copy:
    dest: "{{ansible_user_dir}}/.fonts/fontconfig/conf.f/8-firacodespacing.conf"
    src: ../files/8-firacodespacing.conf
    backup: yes

- name: update fc cache 
  become: yes
  command: fc-cache -f -v
```

Even if one doesn't know Ansible, this is a format that is fairly readable,
and not too verbose.
In this specific example, I'd be so bold as to say that, beyond `become: yes`
meaning "do the action as the sudo user", everything should be guessable. 

## Foreshadowing of future transmissions

Now, to be honest, I don't yet do everything via Ansible, because it's still
more work than being lazy and inconsiderate to Future Me. But I am constantly,
if slowly, getting better at it. 

I am also building myself some helpful
tools. Like a custom action to check if a specific program on the local system
needs to be upgraded or not. But that, and other such technicalities will have
to wait for another day. Till then, enjoy!



