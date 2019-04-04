---
title: Making Oozie Logs A Little Easier On The Eyes
url: oozie-logs
format: markdown
created: 2014-02-12
tags:
    - Perl
    - Oozie

---

Today we're having a quick one.

Earlier during  the day, I had to peruse an Oozie log for the first time.
And it looked like:

```
2014-02-11 20:13:14,211  INFO ActionStartXCommand:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@:start:] Start action [0004636-140111040403753-oozie-W@:start:] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
2014-02-11 20:13:14,212  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@:start:] [***0004636-140111040403753-oozie-W@:start:***]Action status=DONE
2014-02-11 20:13:14,212  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@:start:] [***0004636-140111040403753-oozie-W@:start:***]Action updated in DB!
2014-02-11 20:13:14,271  INFO ActionStartXCommand:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] Start action [0004636-140111040403753-oozie-W@a-first-action] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
2014-02-11 20:13:15,079  WARN HiveActionExecutor:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] credentials is null for the action
2014-02-11 20:13:18,306  INFO HiveActionExecutor:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] checking action, external ID [job_201401070500_217582] status [RUNNING]
2014-02-11 20:13:18,408  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] [***0004636-140111040403753-oozie-W@a-first-action***]Action status=RUNNING
2014-02-11 20:13:18,409  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] [***0004636-140111040403753-oozie-W@a-first-action***]Action updated in DB!
2014-02-11 20:13:34,367  INFO CallbackServlet:539 - USER[-] GROUP[-] TOKEN[-] APP[-] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] callback for action [0004636-140111040403753-oozie-W@a-first-action]
2014-02-11 20:13:34,424  INFO HiveActionExecutor:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] action completed, external ID [job_201401070500_217582]
2014-02-11 20:13:34,443  INFO HiveActionExecutor:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@a-first-action] action produced output
2014-02-11 20:13:34,653  INFO ActionStartXCommand:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] Start action [0004636-140111040403753-oozie-W@some-action] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
2014-02-11 20:13:35,418  WARN HiveActionExecutor:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] credentials is null for the action
2014-02-11 20:13:38,628  INFO HiveActionExecutor:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] checking action, external ID [job_201401070500_217583] status [RUNNING]
2014-02-11 20:13:38,731  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] [***0004636-140111040403753-oozie-W@some-action***]Action status=RUNNING
2014-02-11 20:13:38,731  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] [***0004636-140111040403753-oozie-W@some-action***]Action updated in DB!
2014-02-11 20:13:57,659  INFO CallbackServlet:539 - USER[-] GROUP[-] TOKEN[-] APP[-] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] callback for action [0004636-140111040403753-oozie-W@some-action]
2014-02-11 20:13:57,712  INFO HiveActionExecutor:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] action completed, external ID [job_201401070500_217583]
2014-02-11 20:13:57,729  WARN HiveActionExecutor:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] Launcher ERROR, reason: Main class [org.apache.oozie.action.hadoop.HiveMain], exit code [10044]
2014-02-11 20:13:57,895  INFO ActionEndXCommand:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@some-action] ERROR is considered as FAILED for SLA
2014-02-11 20:13:57,964  INFO ActionStartXCommand:539 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@fail] Start action [0004636-140111040403753-oozie-W@fail] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
2014-02-11 20:13:57,965  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@fail] [***0004636-140111040403753-oozie-W@fail***]Action status=DONE
2014-02-11 20:13:57,965  WARN ActionStartXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[0004636-140111040403753-oozie-W@fail] [***0004636-140111040403753-oozie-W@fail***]Action updated in DB!
2014-02-11 20:13:58,036  WARN CoordActionUpdateXCommand:542 - USER[running_user] GROUP[-] TOKEN[] APP[some-big-job-workflow] JOB[0004636-140111040403753-oozie-W] ACTION[-] E1100: Command precondition does not hold before execution, [, coord action is null], Error Code: E1100
Finished: FAILURE
```

*wut*?

Okay, Java peeps have a predilection for verbose logs, but surely there is a
way to make the whole thing a little more readable for poor, poor human
eyes...

So I hacked the following:

```perl
use 5.10.0;

use strict;

my @lines = map { parse_line($_) } <>;

# the job id is big, and doesn't give us much, remove
for my $useless ( map { $_->{JOB} } @lines ) {
    for ( @lines ) {
        $_->{msg} =~ s/\Q$useless//g;
        $_->{ACTION} =~ s/^\Q$useless//;
    }
}

my %previous;
for my $l ( @lines ) {
    # we'll only print metadata that changed
    my @changes = grep { $l->{$_} ne $previous{$_} } 
                       qw/ USER GROUP TOKEN APP JOB ACTION /;

    say join ' ', map { $_ . "[" . $l->{$_} . "] " } @changes if @changes;

    say "\t", $l->{time}, " ", $l->{msg};
    %previous = %$l;
}

sub parse_line {
    my $line = shift;

    # try to parse the line as a typical log line
    my( $time, $info ) = /^\d{4}-\d{2}-\d{2}\s*  # the date. Don't care
                           (\d+:\d\d:\d\d)       # the time, More interesting
                           ,\d+\s*.*?-           # log level and stuff. Meh
                           (.*)                  # the message itself
                         /x
        or return ();

    my %data = ( time => $time );

    # capture some repeated metadata
    for my $k ( qw/ USER GROUP TOKEN APP JOB ACTION / ) {
        $data{$k} = $1 if $info =~ s/$k\[(.*?)\]\s*//;
    }

    # useless and long, scrap it
    $info =~ s/\[\*{3}.*?\*{3}\]//;

    $data{msg} = $info;

    return \%data;
}
```

And there we go, a log that is a mite easier on the eyes...

```bash
$ perl filter oozie_mess.log
USER[running_user]  GROUP[-]  APP[some-big-job-workflow]  JOB[0004636-140111040403753-oozie-W]  ACTION[@:start:] 
	20:13:14  Start action [@:start:] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
	20:13:14  Action status=DONE
	20:13:14  Action updated in DB!
ACTION[@a-first-action] 
	20:13:14  Start action [@a-first-action] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
	20:13:15  credentials is null for the action
	20:13:18  checking action, external ID [job_201401070500_217582] status [RUNNING]
	20:13:18  Action status=RUNNING
	20:13:18  Action updated in DB!
USER[-]  TOKEN[-]  APP[-] 
	20:13:34  callback for action [@a-first-action]
USER[running_user]  TOKEN[]  APP[some-big-job-workflow] 
	20:13:34  action completed, external ID [job_201401070500_217582]
	20:13:34  action produced output
ACTION[@some-action] 
	20:13:34  Start action [@some-action] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
	20:13:35  credentials is null for the action
	20:13:38  checking action, external ID [job_201401070500_217583] status [RUNNING]
	20:13:38  Action status=RUNNING
	20:13:38  Action updated in DB!
USER[-]  TOKEN[-]  APP[-] 
	20:13:57  callback for action [@some-action]
USER[running_user]  TOKEN[]  APP[some-big-job-workflow] 
	20:13:57  action completed, external ID [job_201401070500_217583]
	20:13:57  Launcher ERROR, reason: Main class [org.apache.oozie.action.hadoop.HiveMain], exit code [10044]
	20:13:57  ERROR is considered as FAILED for SLA
ACTION[@fail] 
	20:13:57  Start action [@fail] with user-retry state : userRetryCount [0], userRetryMax [0], userRetryInterval [10]
	20:13:57  Action status=DONE
	20:13:57  Action updated in DB!
ACTION[-] 
	20:13:58  E1100: Command precondition does not hold before execution, [, coord action is null], Error Code: E1100
```
