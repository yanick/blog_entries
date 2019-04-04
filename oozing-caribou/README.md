---
title: Oozing Caribou
url: oozing-caribou
created: 13 Oct 2013
tags:
    - Perl
    - Hive
---

## Meet Oozie's Workflows

[Oozie](http://oozie.apache.org/) is a 
workflow scheduler for [Hadoop](http://hadoop.apache.org). But that's not terribly
important right now. What is important is that it defines its workflows using 
an XML dialect. And as all XML things go, the result is... shall we say, less than
easy on the eyes and the typing fingers. As piece of evidence, I bring you that simple
example workflow part of the Oozie distribution:

```xml
&lt;workflow-app name=&quot;demo-wf&quot;&gt;

    &lt;start to=&quot;cleanup-node&quot;/&gt;

    &lt;action name=&quot;cleanup-node&quot;&gt;
        &lt;fs&gt;
            &lt;delete path=&quot;${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo&quot;/&gt;
        &lt;/fs&gt;
        &lt;ok to=&quot;fork-node&quot;/&gt;
        &lt;error to=&quot;fail&quot;/&gt;
    &lt;/action&gt;

    &lt;fork name=&quot;fork-node&quot;&gt;
        &lt;path start=&quot;pig-node&quot;/&gt;
        &lt;path start=&quot;streaming-node&quot;/&gt;
    &lt;/fork&gt;

    &lt;action name=&quot;pig-node&quot;&gt;
        &lt;pig&gt;
            &lt;job-tracker&gt;${jobTracker}&lt;/job-tracker&gt;
            &lt;name-node&gt;${nameNode}&lt;/name-node&gt;
            &lt;prepare&gt;
                &lt;delete path=&quot;${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node&quot;/&gt;
            &lt;/prepare&gt;
            &lt;configuration&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.job.queue.name&lt;/name&gt;
                    &lt;value&gt;${queueName}&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.map.output.compress&lt;/name&gt;
                    &lt;value&gt;false&lt;/value&gt;
                &lt;/property&gt;
            &lt;/configuration&gt;
            &lt;script&gt;id.pig&lt;/script&gt;
            &lt;param&gt;INPUT=/user/${wf:user()}/${examplesRoot}/input-data/text&lt;/param&gt;
            &lt;param&gt;OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node&lt;/param&gt;
        &lt;/pig&gt;
        &lt;ok to=&quot;join-node&quot;/&gt;
        &lt;error to=&quot;fail&quot;/&gt;
    &lt;/action&gt;

    &lt;action name=&quot;streaming-node&quot;&gt;
        &lt;map-reduce&gt;
            &lt;job-tracker&gt;${jobTracker}&lt;/job-tracker&gt;
            &lt;name-node&gt;${nameNode}&lt;/name-node&gt;
            &lt;prepare&gt;
                &lt;delete path=&quot;${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node&quot;/&gt;
            &lt;/prepare&gt;
            &lt;streaming&gt;
                &lt;mapper&gt;/bin/cat&lt;/mapper&gt;
                &lt;reducer&gt;/usr/bin/wc&lt;/reducer&gt;
            &lt;/streaming&gt;
            &lt;configuration&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.job.queue.name&lt;/name&gt;
                    &lt;value&gt;${queueName}&lt;/value&gt;
                &lt;/property&gt;

                &lt;property&gt;
                    &lt;name&gt;mapred.input.dir&lt;/name&gt;
                    &lt;value&gt;/user/${wf:user()}/${examplesRoot}/input-data/text&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.output.dir&lt;/name&gt;
                    &lt;value&gt;/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node&lt;/value&gt;
                &lt;/property&gt;
            &lt;/configuration&gt;
        &lt;/map-reduce&gt;
        &lt;ok to=&quot;join-node&quot;/&gt;
        &lt;error to=&quot;fail&quot;/&gt;
    &lt;/action&gt;

    &lt;join name=&quot;join-node&quot; to=&quot;mr-node&quot;/&gt;
    
    
    &lt;action name=&quot;mr-node&quot;&gt;
        &lt;map-reduce&gt;
            &lt;job-tracker&gt;${jobTracker}&lt;/job-tracker&gt;
            &lt;name-node&gt;${nameNode}&lt;/name-node&gt;
            &lt;prepare&gt;
                &lt;delete path=&quot;${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node&quot;/&gt;
            &lt;/prepare&gt;
            &lt;configuration&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.job.queue.name&lt;/name&gt;
                    &lt;value&gt;${queueName}&lt;/value&gt;
                &lt;/property&gt;

                &lt;property&gt;
                    &lt;name&gt;mapred.mapper.class&lt;/name&gt;
                    &lt;value&gt;org.apache.oozie.example.DemoMapper&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.mapoutput.key.class&lt;/name&gt;
                    &lt;value&gt;org.apache.hadoop.io.Text&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.mapoutput.value.class&lt;/name&gt;
                    &lt;value&gt;org.apache.hadoop.io.IntWritable&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.reducer.class&lt;/name&gt;
                    &lt;value&gt;org.apache.oozie.example.DemoReducer&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.map.tasks&lt;/name&gt;
                    &lt;value&gt;1&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.input.dir&lt;/name&gt;
                    &lt;value&gt;/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node,/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node&lt;/value&gt;
                &lt;/property&gt;
                &lt;property&gt;
                    &lt;name&gt;mapred.output.dir&lt;/name&gt;
                    &lt;value&gt;/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node&lt;/value&gt;
                &lt;/property&gt;
            &lt;/configuration&gt;
        &lt;/map-reduce&gt;
        &lt;ok to=&quot;decision-node&quot;/&gt;
        &lt;error to=&quot;fail&quot;/&gt;
    &lt;/action&gt;

    &lt;decision name=&quot;decision-node&quot;&gt;
        &lt;switch&gt;
            &lt;case to=&quot;hdfs-node&quot;&gt;${fs:exists(concat(concat(concat(concat(concat(nameNode, '/user/'), wf:user()), '/'), examplesRoot), '/output-data/demo/mr-node')) == &quot;true&quot;}&lt;/case&gt;
            &lt;default to=&quot;end&quot;/&gt;
        &lt;/switch&gt;
    &lt;/decision&gt;

    &lt;action name=&quot;hdfs-node&quot;&gt;
        &lt;fs&gt;
            &lt;move source=&quot;${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node&quot;
                  target=&quot;/user/${wf:user()}/${examplesRoot}/output-data/demo/final-data&quot;/&gt;
        &lt;/fs&gt;
        &lt;ok to=&quot;end&quot;/&gt;
        &lt;error to=&quot;fail&quot;/&gt;
    &lt;/action&gt;

    &lt;kill name=&quot;fail&quot;&gt;
        &lt;message&gt;Demo workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]&lt;/message&gt;
    &lt;/kill&gt;

    &lt;end name=&quot;end&quot;/&gt;

&lt;/workflow-app&gt;
```

Not the worst tag soup ever, I'll give you. But still, that's hefty on the eyes.

## For the Love of the FSM, DSL That ML

At the core, the XML representation of the workflow is a fine thing. It's very easily
machine-parsable and well-defined. It's just to very friendly to us humans, and it's one 
case where I think DSLs do wonders to abstract most of the tediousness and verbosity 
of the job.

Enter [Template::Caribou](cpan:release/Template-Caribou), that toy templating system of mine.
While its primary raison d'etre is HTML templating, it has been designed such that it's 
friendly to any XML dialect. Indeed, with the help of a Hive tag library (currently available on
the 'hive' branch of the GitHub repo of Caribou), here is how the workflow above could look like.

First, we need a wrapping class:

```perl
#!/usr/bin/perl 

use strict;
use warnings;

package Workflow;

use Moose;
use Template::Caribou;

with 'Template::Caribou';
with 'Template::Caribou::Files' => {
    dirs => [ '.' ],
};

my $template = Workflow->new;

print $template->render('demo');
```

and there is `demo.bou`, in all its glory:


```perl
use Template::Caribou::Tags::Hive ':all';

workflow 'demo-wf', 
    start => 'cleanup-node',
    end => 'end',
    sub {

    action 'cleanup-node',
        ok => 'fork-node',
        error => 'fail',
        sub {
            fs {
                oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo';
            }
    };

    oozie_fork 'fork-node', qw/
        pig-node
        streaming-node
    /;


    action 'pig-node', 
        ok => 'join-node',
        error => 'fail',
        sub { pig 
            'job-tracker' => '${JobTracker}',
            'name-node' => '${nameNode}',
            prepare => sub {
                oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node';
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.map.output.compress' => 'false',
            },
            script => 'id.pig',
            params => [
            'INPUT=/user/${wf:user()}/${examplesRoot}/input-data/text',
            'OUTPUT=/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node'
            ],
    };


    action 'streaming-node',
        ok => 'join-node',
        error => 'fail', 
        sub {
        map_reduce 
            job_tracker => '${JobTracker}',
            name_node => '${nameNode}',
            prepare => sub {
                delete => '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
            streaming => {
                mapper => '/bin/cat',
                reducer => '/usr/bin/wc',
            },
            configuration => {
                'mapred.job.queue.name' => '${queueName}',
                'mapred.input.dir' => '/user/${wf:user()}/${examplesRoot}/input-data/text',
                'mapred.output.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node'
            },
        ;
    };

    oozie_join 'join-node' => 'mr-node';

    action 'mr-node', 
        ok => 'decision-node',
        error => 'fail',
        sub {
            map_reduce
                job_tracker => '${JobTracker}',
                name_node => '${nameNode}',
                prepare => sub {
                    oozie_delete '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node';
                },
                configuration => {
                    'mapred.job.queue.name' => '${queueName}',
                    'mapred.mapper.class' => 'org.apache.oozie.example.DemoMapper',
                    'mapred.mapoutput.key.class' => 'org.apache.hadoop.io.Text',
                    'mapred.mapoutput.value.class' => 'org.apache.hadoop.io.IntWritable',
                    'mapred.reducer.class' => 'org.apache.oozie.example.DemoReducer',
                    'mapred.map.tasks' => 1,
                    'mapred.input.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/pig-node,/user/${wf:user()}/${examplesRoot}/output-data/demo/streaming-node',
                    'mapred.output.dir' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node'
                },
        };

    decision 'decision-node', 'end', 
        'hdfs-node' => q[${fs:exists(concat(concat(concat(concat(concat(nameNode, '/user/'), wf:user()), '/'), examplesRoot), '/output-data/demo/mr-node')) == "true"}];

    action 'hdfs-node', 
        ok => 'end',
        error => 'fail',
        sub {
        fs {
            move '${nameNode}/user/${wf:user()}/${examplesRoot}/output-data/demo/mr-node' => '/user/${wf:user()}/${examplesRoot}/output-data/demo/final-data';
        };
    };

    oozie_kill 'fail' => <<'URGH';
Demo workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]
URGH

};
```

Reading the whole thing still doesn't feel like Christmas, but it's an 
improvement. And now that it's part of a templating system, we can 
split the different actions in their own template/file, and then use a little bit of
programmatic magic to slurp them all in the main workflow.

Also, while the example we're using is 
simple enough that no great feats of simplification can be done, it's easy 
to think of cases where a `for` loop will be our best friend. Like if
we might need to create lots of 
actions based on some parameter:

```perl

    # somewhere in the 'workflow' template

    oozie_fork 'update_tables' => map { 
        'update_' . $_
    } $self->tables_to_update;

    # sub-template creating the 'update_*table*' action node
    show( 'table_update', table_name => $_ ) for $self->tables_to_update;
    
    oozie_join 'all_updates_done' => 'some-next-node';

```

Of course for loops we could do also something similar with an XSLT transform. 
But... y'know... no. Just... no.

## Bonus Feature: Workflow Graph!

Unrelated to the stuff above, but just because I find it cute: want to make a quick
graph of the workflow? Here's a quick and dirty way to do it:

```perl
#!/usr/bin/env perl 

use strict;
use warnings;

use Web::Query;
use Graph::Easy;

my $q = Web::Query->new_from_html( join '', <> );
my $graph = Graph::Easy->new;

$q->find( 'start' )->each(sub{
    $graph->add_edge( 'START' => $_[1]->attr('to') );
});

$q->find( 'end' )->each(sub{
    $graph->add_node($_[1]->attr('name') );
});

$q->find('action')->each(sub{
    for my $next (qw/ ok error /) {
        my $next_node = $_[1]->find($next)->attr('to') or next;
        $graph->add_edge(
            $_[1]->attr('name') => $next_node 
        )->set_attribute( label => $next );
    }
});

$q->find('fork')->each(sub{
    my $name = $_[1]->attr('name');
    $_[1]->find('path')->each(sub{
        $graph->add_edge($name => $_[1]->attr('start'))
    });
});

$q->find('join')->each(sub{
    $graph->add_edge( map { $_[1]->attr($_) } qw/ name to / );
});

$q->find('decision')->each(sub{
    my $name = $_[1]->attr('name');
    $_[1]->find('case,default')->each(sub{
        $graph->add_edge( $name => $_[1]->attr('to') );
    });

});

print $graph->as_ascii;
```

Which gives us

```bash
$ perl graph.pl workflow.xml

                                               +----------------+  ok
  +------------------------------------------- | streaming-node | ------------------------------+
  |                                            +----------------+                               |
  |                                              ^                                              |
  |                                              |                                              |                                   +-----------------------------------------+
  |                                              |                                              v                                   |                                         v
  |  +-------+          +--------------+  ok   +----------------+          +----------+  ok   +-----------+     +---------+  ok   +---------------+     +-----------+  ok   +-----+
  |  | START | -------> | cleanup-node | ----> |   fork-node    | -------> | pig-node | ----> | join-node | --> | mr-node | ----> | decision-node | --> | hdfs-node | ----> | end |
  |  +-------+          +--------------+       +----------------+          +----------+       +-----------+     +---------+       +---------------+     +-----------+       +-----+
  |                       |                                                  |                                    |                                       |
  |                       | error                                            |                                    |                                       |
  |                       v                                                  |                                    |                                       |
  |            error    +---------------------------------------+  error     |                                    |                                       |
  +-------------------> |                                       | <----------+                                    |                                       |
                        |                                       |                                                 |                                       |
                        |                                       |  error                                          |                                       |
                        |                 fail                  | <-----------------------------------------------+                                       |
                        |                                       |                                                                                         |
                        |                                       |  error                                                                                  |
                        |                                       | <---------------------------------------------------------------------------------------+
                        +---------------------------------------+
```
