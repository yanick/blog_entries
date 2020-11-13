---
created: 2013-10-13
tags:
    - Perl
    - Hive
---

# Oozing Caribou

## Meet Oozie's Workflows

[Oozie](http://oozie.apache.org/) is a 
workflow scheduler for [Hadoop](http://hadoop.apache.org). But that's not terribly
important right now. What is important is that it defines its workflows using 
an XML dialect. And as all XML things go, the result is... shall we say, less than
easy on the eyes and the typing fingers. As piece of evidence, I bring you that simple
example workflow part of the Oozie distribution:

``file1.xml``

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


<SnippetFile src="file4.perl" />

and there is `demo.bou`, in all its glory:

<SnippetFile src="file2.perl" />

Reading the whole thing still doesn't feel like Christmas, but it's an 
improvement. And now that it's part of a templating system, we can 
split the different actions in their own template/file, and then use a little bit of
programmatic magic to slurp them all in the main workflow.

Also, while the example we're using is 
simple enough that no great feats of simplification can be done, it's easy 
to think of cases where a `for` loop will be our best friend. Like if
we might need to create lots of 
actions based on some parameter:

<SnippetFile src="file3.perl" />

Of course for loops we could do also something similar with an XSLT transform. 
But... y'know... no. Just... no.

## Bonus Feature: Workflow Graph!

Unrelated to the stuff above, but just because I find it cute: want to make a quick
graph of the workflow? Here's a quick and dirty way to do it:

<SnippetFile src="file5.perl" />

Which gives us

<SnippetFile src="graph.bash" />
