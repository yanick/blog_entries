---
title: Gui Oozie Goodness
url: gui-oozie
created: 2013-11-10
tags:
    - Perl
    - Oozie
---

Recently, I've been playing with the workflow managers of the 
Hadoop world. Namely, [Azkaban][azkaban] and [Oozie][oozie].

While Azkaban offers a cute graph-oriented display of your 
running workflows, it is a little bit limited in the workflow logic
department. No conditional branching? No error state? Meh. Lame.

Oozie, on the other
hand, has more logic horsepower, but it comes with a certain complexity tax.
And the graphical view provided by [Hue][hue] is not as visual as the one we
have in Azkaban. 

But while Oozie doesn't come with the shiny, it does come with a [REST
API][oozie-api]. So,
potentially, we *have* the technology... How
hard could it be to create a visual interface to its workflow, the way we
like'em? Well. Let's see.

## Step 1: Get That Workflow

First thing we need to do is to get to the `workflow.xml` master file (which
we'll assume is already on hdfs), and generate our graph edges off it. 
As I already tackled the munging of the workflow file in 
a [previous entry](blog:oozing-caribou), I can gleefully steal the
transformation logic from there. All that remains, really, is the fetching of
the file from hdfs.

``` perl
#!/usr/bin/env perl

use Net::Hadoop::WebHDFS;
use Path::Tiny;
use Web::Query;
use Data::Printer;

my $hadoop_host = '192.168.0.203';
my $workspace_root = '/user/hue/oozie/workspaces/managed';

p workflow_to_graph( get_graph_from_hdfs( shift ) );

sub get_graph_from_hdfs {
    my $workflow = shift;

    return Net::Hadoop::WebHDFS->new( 'host' => $hadoop_host )
        ->read( path( $workspace_root, $workflow, 'workflow.xml' ) )
        || die "'workflow.xml' not found";
}

sub workflow_to_graph {
    my $q = Web::Query->new_from_html( shift );

    my %graph;

    $q->find( 'start' )->each(sub{
        push @{ $graph{START} }, $_[1]->attr('to');
    });

    $q->find( 'end' )->each(sub{
        $graph{$_[1]->attr('name')} = [];
    });

    $q->find('action')->each(sub{
        for my $next (qw/ ok error /) {
            my $next_node = $_[1]->find($next)->attr('to') or next;
            push @{ $graph{$_[1]->attr('name')} }, $next_node;
        }
    });

    $q->find('fork')->each(sub{
        my $name = $_[1]->attr('name');
        $_[1]->find('path')->each(sub{
            push @{$graph{$name}}, $_[1]->attr('start');
        });
    });

    $q->find('join')->each(sub{
            push @{$graph{$_[1]->attr('name')}}, $_[1]->attr('to');
    });

    $q->find('decision')->each(sub{
        my $name = $_[1]->attr('name');
        $_[1]->find('case,default')->each(sub{
            my $next_node = $_[1]->attr('to') or next;
            push @{ $graph{$_[1]->attr('name')} }, $next_node;
        });

    });

    # just make sure all nodes are present as keys
    $graph{$_} ||= [] for map { @$_ } values %graph;

    return \%graph;
}
```

And with that we get

``` bash
$ perl get_graph.pl sleepfork
 {
    end        [],
    fork-34    [
        [0] "Sleep-1",
        [1] "Sleep-5"
    ],
    fork-38    [
        [0] "Sleep-3",
        [1] "Sleep-4"
    ],
    join-35    [
        [0] "end"
    ],
    join-39    [
        [0] "join-35"
    ],
    kill       [],
    Sleep-1    [
        [0] "Sleep-10",
        [1] "kill"
    ],
    Sleep-3    [
        [0] "join-39",
        [1] "kill"
    ],
    Sleep-4    [
        [0] "join-39",
        [1] "kill"
    ],
    Sleep-5    [
        [0] "fork-38",
        [1] "kill"
    ],
    Sleep-10   [
        [0] "join-35",
        [1] "kill"
    ],
    START      [
        [0] "fork-34"
    ]
}
```

So far, so good.

## Step 2: From Data Structure To The Graph

Now the fun stuff: turning the raw data structure into a purty graph.

For this, I decided to leverage the [dagre-d3][dd3] javascript library,
which has a sane API and produce nice-looking graphs. Since we already have 
the data structure at hand, all we have to do is to create a CSS stylesheet,
drop a `<svg>` placeholder in our HTML page (both not shown here, because
very boring -- see the final GitHub repo below for the full monty), and generate our 
graph.

```javascript

$.get( '/workflow/<% $workflow %>/graph' ).done(function(graph){

    var nodes = new Object();
    var g = new dagreD3.Digraph();

    for ( source in graph ) {
        if ( nodes[source] == null ) {
            g.addNode( source,    { label: source });
        }
        nodes[source] = 1;
        for ( var i = 0; i < graph[source].length; i++ ) {
            var dest = graph[source][i];
            if ( nodes[dest]  == null ) {
                g.addNode( dest, { label: dest });
                nodes[dest] = 1;
            }
            g.addEdge( null, source, dest );
        }
    }

    var renderer = new dagreD3.Renderer();

    // give an 'id' to all nodes
    var oldDrawNode = renderer.drawNode();
    renderer.drawNode(function(graph, u, svg) {
        oldDrawNode(graph, u, svg);
        svg.attr("id", "node-" + u);
    });

    renderer.run(g, d3.select("svg g"));

});

```

And with that, we can see!

<div align="center">
<img src="__ENTRY_DIR__/workflow.png" alt="workflow as a graph" />
</div>

## Step 3: Launch And Monitor

So we have a static view of a workflow. Let's give it life.
First thing, we need to launch the job. There is currently 
no `Hadoop::Oozie::REST`-like module on CPAN (a terrible hole I [intend to
fill][oozie-quest] at some point), but that's okay,
[REST::Client](cpan:REST::Client) will
do in a pinch:

``` perl
use REST::Client;

my $client = REST::Client->new;

my $host = config->{hadoop_host};
my $path = config->{workspace_root} . '/' . $workflow . '/';

$client->setHost( 'http://'. $host . ':11000' );
$client->addHeader( 'Content-Type' => 'application/xml;charset=UTF-8' );

$client->POST( '/oozie/v1/jobs?action=start', &lt;<"END"
&lt;?xml version="1.0" encoding="UTF-8"?>
&lt;configuration>
    &lt;property>
        &lt;name>user.name</name>
        &lt;value>hue</value>
    &lt;/property>
    &lt;property>
        &lt;name>oozie.wf.application.path</name>
        &lt;value>hdfs://$path</value>
    &lt;/property>
&lt;/configuration>
END
    );

print $client->responseContent;
```

Monitoring it isn't going to be much harder. 
All we need to do is to query the mothership for updates,

``` perl
my $client = REST::Client->new;
$client->setHost( 'http://'.config->{hadoop_host} . ':11000' );

$client->GET( '/oozie/v1/job/' . param('id') . '?show=info' );
print $client->responseContent;
```

and then use those updates to refresh the graph with colors that illustrate
the different states of the nodes,

``` javascript
var state_color = {
    "OK":       "green",
    "PREP":     "blue",
    "FAILED":   "red",
    "KILLED":   "pink",
    "DONE":     "lightgreen"
};

function update() {
    $.get( '/job/' + job_id ).done(function(data){
        data = JSON.parse(data);
        for ( var i = 0; i < data.actions.length; i++ ) {
            var action = data.actions[i];
            console.log( action["name"] + " : " + action["status"] );
            if ( action["name"] == ':start:' )  {
                action["name"] = 'START';
            }
            $('#node-' + action["name"])
                .attr('fill', state_color[action["status"]]);
        }

        // update every 2 seconds
        setTimeout( 'update()', 2000 );
    });
}
```

And that's pretty much it. We can now pull all those parts into a [small Dancer
application](gh:yanick/moozster), and we have a very minimal workflow launcher and visualizer:


<div align="center">
<img src="__ENTRY_DIR__/running.png" alt="running workflow" />
</div>


[oozie-quest]: http://questhub.io/realm/perl/quest/527fc55e9f567ad27a0000cf
[dd3]: https://github.com/cpettitt/dagre-d3
[azkaban]: http://data.linkedin.com/opensource/azkaban
[oozie]: http://oozie.apache.org/
[hue]: https://github.com/cloudera/hue
[oozie-api]: http://oozie.apache.org/docs/3.1.3-incubating/WebServicesAPI.html

