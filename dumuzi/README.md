---
title: System Monitoring on the Cheap with TAP and Smolder
url: system-monitoring-on-the-cheap
format: markdown
created: 28 Oct 2010
tags:
    - system monitoring
    - Smolder
    - TAP
    - Zabbiz
    - Nagios
---



Like any self-respecting geek, I have a small network at home.
It's fairly well-behaved and stable, so I never really felt the burning
urge of install a monitoring system.  However, as I've been bitten by the
full partition surprise at 9:30am on a Saturday morning a few times lately,
I've... come to reconsider that position a little bit.

Of course, the right solution would be to install a real monitoring
system like, say, [Nagios](http://www.nagios.org/) or [Zabbix](http://www.zabbix.com/).
Trying to reinvent the wheel, and in this case a fairly beefy wheel, would be
thoroughly
silly. But it'd also be fun and educative.  So I decided to do it anyway.

It must be said that my simple setup helps.  I don't need by-the-minute
monitoring and notification. I don't need escalation procedures (the only escalation 
procedure we have here is my lovely dragon climbing the
stair to tell me the wireless network is down). I don't need history graphs. 
I don't need tungstene-coated
SLA-enforcing mechanisms. I just need a battery of checks to run every day and
something to notify me if something fails.

## Part I - the Checks

First thing, we need something that is going to verify stuff, and is going to give us
a report on whether the checks succeeded or failed.  Sounds familiar, doesn't
it? So, why not leverage the good ol' Perl testing ecosystem to do the deed?

One shortcoming of regular tests, though, is that a TAP test can only pass or fail,
there's no room for gradation of b0rkedness.  Well, *officially* there's no
room.  For my little system I'm bending the conventions a little bit and using
TODO tests as a warning level.

For convenience, I'm creating a test function that I'll use to report
the status of the checks:

<galuga_code code="Perl">Dumuzi.pm</galuga_code>

(If you are curious, the name
[Dumuzi](http://www.pantheon.org/articles/d/dumuzi.html) comes from the Babylonian theme of my
local network.)

With that, I can now write some test files.  Say, one for the partition of the
local machine:

<galuga_code code="Perl">partition-usage.t</galuga_code>

and one that verifies that all my websites are alive:

<galuga_code code="Perl">websites.t</galuga_code>

Assuming that our files are arranged in a pseudo-distribution
fashion (utility module under `lib` and tests under `t`)
we can now run all our tests with `prove`:

<pre code="bash">
$ prove -v -m  -l t
t/partition-usage.t .. 
1..5
ok 1 - partition /dev/sdb10
# {
#   'free' => '2730692',
#   'mountpoint' => '/home/yanick/Pictures/OOS',
#   'total' => '4922124',
#   'usage' => '1941400',
#   'usageper' => 42
# }
not ok 2 - partition /dev/sdb9

#   Failed test 'partition /dev/sdb9'
#   at t/partition-usage.t line 31.
# {
#   'free' => '692284',
#   'mountpoint' => '/home/yanick',
#   'total' => '9843184',
#   'usage' => '8650884',
#   'usageper' => 93
# }
ok 3 - partition none
# {
#   'free' => '739308',
#   'mountpoint' => '/lib/init/rw',
#   'total' => '739308',
#   'usage' => '0',
#   'usageper' => 0
# }
ok 4 - partition /dev/sda1
# {
#   'free' => '25729788',
#   'mountpoint' => '/',
#   'total' => '36827144',
#   'usage' => '9226592',
#   'usageper' => 27
# }
not ok 5 - partition /dev/sdb11

#   Failed test 'partition /dev/sdb11'
#   at t/partition-usage.t line 31.
# {
#   'free' => '747364',
#   'mountpoint' => '/home/yanick/Pictures',
#   'total' => '4922124',
#   'usage' => '3924728',
#   'usageper' => 85
# }
ok 6 - partition /dev/sdb14
# {
#   'free' => '7466888',
#   'mountpoint' => '/home/yanick/music',
#   'total' => '10915320',
#   'usage' => '2893960',
#   'usageper' => 28
# }
# Looks like you planned 5 tests but ran 6.
# Looks like you failed 2 tests of 6 run.
Dubious, test returned 2 (wstat 512, 0x200)
Failed 2/5 subtests 
t/websites.t ......... 
1..10
ok 1 - GET http://michel-lacombe.dyndns.org
ok 2 - title of http://michel-lacombe.dyndns.org
ok 3 - GET http://kontext.ca
ok 4 - title of http://kontext.ca
ok 5 - GET http://babyl.dyndns.org/techblog
ok 6 - title of http://babyl.dyndns.org/techblog
ok 7 - GET http://academiedeschasseursdeprimes.ca
ok 8 - title of http://academiedeschasseursdeprimes.ca
ok 9 - GET http://babyl.dyndns.org
ok 10 - title of http://babyl.dyndns.org
ok

Test Summary Report
-------------------
t/partition-usage.t (Wstat: 512 Tests: 6 Failed: 3)
  Failed tests:  2, 5-6
  Non-zero exit status: 2
  Parse errors: Bad plan.  You planned 5 tests but ran 6.
Files=2, Tests=16,  3 wallclock secs ( 0.03 usr  0.01 sys +  0.36 cusr  0.06 csys =  0.46 CPU)
Result: FAIL
</pre>

## Part II - Gathering and Broadcasting the Results

For that part, I'm using [Smolder](cpan). I create a project for each machine on which I
want to run tests, and use the following script in a cronjob:

<pre code="bash">
cd /home/dumuzi
prove -l -m -v --archive test_run.tar.gz
smolder_smoke_signal --server enkidu:8085 --file test_run.tar.gz --project `hostname`
</pre>

Et voilà. I can now be notified of the checks via email, RSS feed or from
Smolder's web interface.

<div align="center"><img src="__ENTRY_DIR__/dumuzi.png" /></div>
