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
