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
