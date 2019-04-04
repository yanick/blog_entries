---
url: nocoug-2012
format: markdown
created: 3 June 2012
original: The Pythian Blog - http://www.pythian.com/news/33537/nocoug-contest-the-perl-dark-horse-entry/
tags:
    - Perl
    - NoCOUG
    - contest
    - golf
---

# NoCOUG contest: the Perl dark horse entry

So [NoCOUG](http://www.nocoug.org/) announced its [third international SQL &
NoSQL challenge][challenge] (look at page 25 of that pdf) earlier this week. Yay!

As I did last year, I tried my hand at forging a Perl solution for the challenge. Just for, y’know, peer-pressuring a little my colleagues into entering the fray.

As it happens, this week is a little.. intense, $work-wise, so I wasn’t able to polish my solution into pure howling madness. But I daresay the work-in-progress that I have is still worth a few cackles. Although you shouldn’t take my word for it. Here, I’ll let you be the judge of it:
	
    #syntax: perl
    die@$_ for
    sort{@$a-@$b}map{$i=$_;[(Albus,Burdock,Carlotta,Daisy,Elfrida,
    Falco)[grep$i&2**$_,0..5]]}grep{$x=$_;$x|=$f{$_}x($_==$_&$x)for
    (%f=(1,6,4,9,16,7,32,12,12,50,3,8))x6;63==$x}1..63

And I just saw on the NoCOUG page that there is an additional rule document with some additional attendance rules.

Hmm…

Looks like my job is not done, here…

[challenge]: http://bitly.com/JvJS46
