---
title: MacGyvering a Remote Disk Usage Utility
url: remote-du
format: markdown
created: 2011-02-13
tags:
    - Perl
    - Git
    - rsync
    - File::RsyncP
    - backup
    - DNS-323
---

For my backups at home I have a [DNS-323][1] which, after
a minimal [twist of the arm][2] was applied, 
can be accessed via 'ssh' and 'rsync'.  Methodology-wise, 
I'm following the general idea described 
[in this forum][3].  Namely: for each of my machines I have one
backup directory per week of the year (`01`, `02`, `03`, etc) and
-- and this is the über-cool part of it -- 
`rsync`'s '`--link-dest`'  is used 
to hard-link files that didn't change since the previous backup run.
This means that I can have weekly snapshots of all my machines at
the fraction of the space a full backup would take. Very nice.

[1]: http://www.dlink.com/products/?pid=509
[2]: http://wiki.dns323.info/howto:ffp
[3]: http://forum.dsmg600.info/t2125-DNS-323-Rsync-Time-Machine!.html

But, just like gas in a vacuum, files have a nasty habit to fill up all
available disk space.  In my case, the 100% mark was hit last week. Obviously, 
I had to delete stuff.  But... which stuff?

Sure, I have access to `du` on the DNS-323 to find out. But 
du'ing 350G worth of disk space
is no fun. And there is the matter of the hard-links that further complicates 
things. Even though the backup directory 'enkidu/03' weights 5G, if 95% of its
content is hard-linked by other weeks, deleting it won't give me back much.
To properly get the job done, what I really want is a way to get a snapshot of 
the disk usage locally, and in 
a format that would allow me to navigate and examine it at will. 

## Slurp in the disk usage locally

So, first thing, we need to find a way
to get the information about the disk usage from the DNS-323 to my
workhorse.
A quick and dirty approach could be to use [Net::SSH::Perl](cpan)
to connect to the DNS-323 and `ls` our way through the directory structure, 
harvesting information as we go along. 

Well, I tried it. It's dirty all right, but it ain't exactly very quick. 
No, if we want to have the job done before next week, we need something 
more streamlined. Something optimised for the efficient slinging of 
file information across the network. ... Hum. Something like rsync's inner
mechanism, really.

Happily enough, there's already the module [File::RsyncP](cpan)
providing an interface to communicate with rsync servers. While it doesn't
provide a function to gather file listings without performing a sync, it's 
something that can be solved with a little bit of hacking:

<galuga_code code="Perl">du_gather.pl</galuga_code>

It's not a perfect solution: for some reason the rsync server doesn't return
the inode of the file if there's only one instance of it. But it's good
enough to be usable. And it's *fast*. The listing of a 20G backup takes 2 or 3
minutes at most, which is way better than the hours of slurping I was facing
before.

## Store and query the information

Second problem: the listing for each week weights in the vicinity of 7M.
Considering that I have backups for three machines, that's going to end up
taking 1G worth of data. That's a lot, and that's going to be a pain to sift
through. 

The obvious approach to deal with that would be to use a database. But, just like the 
previous obvious solution, it's dog-slow. That 7M listing file translates to
insertions for hundred of thousands of files, and my weak database-fu is
simply no match for that.

So, back to square one, looking for something that squishes oodles of text
real good. Something that will be good, and fast, at showing differences between 
listing instances.

...  Is it just me, or that awfully sounds like Git?

Indeed, using Git as a mutant kind of NoSQL backend makes things 
stupidly easy for us. I create a repository, '`dudb`', with a branch
for each of my machine, and a tag for each machine/week, and populate it
with this script:

<galuga_code code="Perl">du_gather_history.pl</galuga_code>

Again,
it's not a magical perfect solution. If I skipped a week one year (and I do that all
the time), I'll have to juggle things with 'git rebase -i'. Or, as I have
timestamps attached to my files, I could also automate the process. But,
again, for
the time being it's Good Enough<sup>tm</sup> for what I need.

## Extracting the information

And finally, to navigate this mass of information, we use yet another script:

<galuga_code code="Perl">dudb.pl</galuga_code>

With that, I can drill down on the disk usage of a specific machine/week:

    yanick@enkidu$ dudb.pl enkidu/05
    0.00%  12K     #files
    0.13%  14M     etc
    99.87%  9.7G    home
    ---
    total size: 9.7G

    yanick@enkidu$ dudb.pl enkidu/05 home/yanick
    [..]
    2.60%  258M    local_Mail
    5.54%  549M    #files
    9.79%  970M    music
    15.73%  1.6G    work
    50.73%  5.0G    Pictures
    ---
    total size: 9.7G

And also see what has changed since the previous backup:

    yanick@enkidu$ dudb.pl --delta=enkidu/05 enkidu/06 home/yanick
    0.00%  23      .pulse
    0.00%  102     .links2
    0.00%  3.5K    .gnome2
    0.00%  4.1K    .local
    0.00%  4.2K    .gconf
    0.01%  13K     .gconfd
    0.05%  92K     Mail
    4.31%  8.3M    #files
    6.61%  13M     .kde3.5
    10.14%  20M     work
    32.90%  63M     .mozilla
    45.98%  88M     .thunderbird
    ---
    total size: 191M

