---
created: 2013-09-22
tags:
    - Hiveminder
---

# Hacking Hiveminder

The race for getting things done. It's not so much about (God preserves us) reaching 
the finish
line, but more about learning how to fall into a comfortable, efficient stride. 
Y'know,
instead of the slighty less comfortable, incredibly less efficient
impersonification of the tazmanian devil most of us end up doing on 
a day to day basis.

It goes without saying, I've read the [Getting Things Done][GTD] book a few years ago.
It has a lots of good ideas, and I've been trying ever since to incorporate
most of them in my weekly routine. And, of course, I've searched for the right 
tool to manage my tasks.

As task management is a rather personal thing, finding
the *perfect* tool is next to impossible. But there are a few offerings out there
that come close. [Hiveminder][hm] is one of them. On the plus side, it 

* deals with task dependencies,
* can hide tasks for lenghts of time,
* can be used via IMAP, IM, Twitter, the command line, etc.
    
On the minus side,

* its web interface has been neglected a little bit the last 
    few years, and is a little pokey, speed-wise,
* the ordering of the tasks on the web interface also doesn't
    jive that well with the way my brain works.

Fortunately, the service has been well designed, and the 
official web interface is only one front-end of the underlying
engine.  To create a new view tailored to one's wishes, all
that is needed is [Net::Hiveminder](cpan:release/Net-Hiveminder), 
and a wee bit of time.

## Writing a new web interface? Are you nuts?

Yes, I'm nuts. Yes, I want, eventually, to do just that. 
But, for the moment, I don't have the time
and  decided to take 
a different approach: I'd use good ol' Vim as the interface. 
To make things nicer, on my system I'm keeping my tasklist as a [vimwiki](https://github.com/vimwiki/vimwiki) file but, as we'll soon see, 
it's not
vital. It just brings a few nice extras, like being to 
hit *Ctl-space* on a task to mark it as done.

## Step 1: don't pester the mothership all the time

Most of the interfaces to Hiveminder immediately update the web service
when any change is done to any task. Although the system *is* fast, it still
results in a few wasted milliseconds by change. And considering that I'm the
only person working on my tasks, I don't need that level of synchronism. 
Rather, I'd like to take a snapshot of all todos, update them locally, 
and then, when I'm done, bulk-update the mothership with all changes -- like
what [todo.pl](https://metacpan.org/module/TSIBLEY/App-Todo-1.1/bin/todo.pl)
does with its `editdump`. 

So, first thing first: I need a first script to take a local snapshot of
the active todos. 

```perl
#!/usr/bin/env perl 

use strict;
use warnings;

use Net::Hiveminder;
use YAML qw/ DumpFile /;

my $hive = Net::Hiveminder->new( use_config => 1 );

my %tasks = map { $_->{record_locator} => $_ } $hive->todo_tasks;

DumpFile( '/home/yanick/.todo.yaml', \%tasks );
```

That wasn't too hard, was it?

## Step 2: turn that yaml into some vim-ready markdown

So we have the tasks. Now, let's write a second script to turn them into a human-readable
list.

``` perl
#!/usr/bin/env perl 

use 5.16.0;

use strict;
use warnings;
no warnings qw/ uninitialized /;

use Net::Hiveminder;
use DateTime::Functions qw/ now /;
use YAML qw/ LoadFile /;

my %tasks = %{ YAML::LoadFile( '/home/yanick/.todo.yaml' ) };

# if no due date is specified, assume that it's needed 
# this week for highest priority, in two weeks for high,
# one month for normal, 2 months for low priority and
# 4 months for the lowest
my @sort_due_date = (
    map  { "" . now()->add( weeks => $_ ) } 0, 16, 8, 4, 2, 1
);

for ( values %tasks ) {
    $_->{sorting_date} = $_->{due} || $sort_due_date[ $_->{priority} ];
}

my @sorted_tasks = reverse sort {
    $b->{sorting_date} cmp $a->{sorting_date}
        or $a->{priority} <=> $b->{priority}
        or $a->{created} cmp $b->{created}
} values %tasks;

print_task($_) for @sorted_tasks;

sub print_task {
    my $t = shift;

    $_->{summary} =~ s/(?<=.{57}).{4,}/.../;
    printf "* [ ] %-60s P%d %s%s\n", $_->{summary}, $_->{priority}, "&", $_->{record_locator};
    print '  tags: ', join( ' ', $_->{tags} =~ /"(.+?)"/g ), "\n" if $_->{tags};
    for my $field ( qw/ due / ) {
        next unless defined $_->{$field};
        print '  ', $field, ': ', $_->{$field}, "\n";
    }
    print "\n";
}
```

Again, nothing too fancy. But finally I can have my tasks sorted by my own 
little heuristic algorithm: first sort by due date (with tasks without due date
being given defaults based on their priority), then by priority, then by 
reverse order of creation (the logic being that if a task has been around for a 
long time and yet not acted upon, then it's not *that* important). And the output
doesn't too look bad:

``` bash
$ ./hm_print.pl


* [ ] Change logo on fearful sym                                   P5 &3Z774
  tags: @computer blog

* [ ] Mastering perl - chapter 6                                   P4 &3ZI6Y
  tags: @computer perl

* [ ] Mastering perl - chapter 5                                   P4 &3ZI6X
  tags: @computer perl

* [ ] Review Mastering Perl                                        P4 &3Z97Q
  tags: @computer perl

* [ ] Just print the todos in the priorities I want                P4 &3Z96J

* [ ] Set up Firefox sync point on Gilgamesh                       P4 &3Z4LI

...

```

## Step 3: Update the mothership with changes

Of course, after we change our local file, we want to
detect those changes and push them back to the 
web service. As a first step, I only parse the priority
and doneness of the tasks:

``` perl
#!/usr/bin/env perl 

use 5.16.0;

use strict;
use warnings;

use YAML qw/LoadFile/;
use Net::Hiveminder;

my $hive_tasks = LoadFile( '/home/yanick/.todo.yaml' );

my $in = join '', <>;

my $local_tasks = parse_tasks( $in );

my $hive = Net::Hiveminder->new( use_config => 1 );

for my $task ( values %$local_tasks ) {
    my $id = $task->{record_locator};

    # only capture the fields that have changed
    my @updates =  grep { $task->{$_} ne $hive_tasks->{$id}{$_} } keys $task
        or next;

    $hive->update_task( $id => 
        map { $_ => $task->{$_} } @updates
    );

}

sub parse_tasks {
    my @tasks = split qr/\n\s*\*\s+(?=\[.\])/, shift;

    my %tasks;

    for my $t ( @tasks ) {
        my %t;
        if( $t =~ /^\s*\*\s+\[(.)\].*P(\d)\s+&([0-9A-Z]+)/m ) {
            @t{'record_locator','priority','complete'} 
                = ( $3, $2, ( $1 eq 'X' ? 1 : 0 ));
        }
        next unless $t{record_locator};
        $tasks{ $t{record_locator} } = \%t;
    }

    return \%tasks;
}
```

## Step 4: Put it all together under Vim

Bearing in mind that things can get much nicer, for now
we just want to get something working. So let's gather our three
scripts under a single umbrella (named `hm_vim.sh`):

``` bash
#!/usr/bin/env bash

/home/yanick/work/todo/hm_update.pl
/home/yanick/work/todo/hm_reset.pl
/home/yanick/work/todo/hm_print.pl
```

and to summon our small beast, we set up a simple Vim macro:

```
:map <Leader>u :0,$!/home/yanick/work/todo/hm_vim.sh<CR>
```

And there we go: a minimalistic Vim interface to
Hiveminder is born!

## Step 5: Push code to GitHub

You know the drill: the code is [on GitHub](gh:yanick/hiveminder-tools) and yours
to follow, peruse, fork, steal, adapt, whatev you want. Enjoy! 


[GTD]: http://www.davidco.com/
[hm]: http://hiveminder.com
