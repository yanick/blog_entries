package Pod::Manual::DistZilla;

use Moose;

extends 'Pod::Manual';

use Module::Pluggable search_path => ['Dist::Zilla::Plugin'];

my $manual = __PACKAGE__->master;

$manual->title('Dist::Zilla');

$manual->ignore( ['VERSION'] );

$manual->move_one_to_appendix( ['COPYRIGHT AND LICENSE'] );

$manual->add_module( [ qw/
    Dist::Zilla
    Dist::Zilla::Tutorial 
/, ]);

$manual->ignore( [] );

$manual->move_one_to_appendix( [] );

$manual->add_module( [ $manual->plugins ] );

$manual;
