package DancerReport;

use 5.10.0;

use base qw/DBIx::Class::Schema::Loader/;

package main;

my $schema = DancerReport->connect('dbi:SQLite:plugins.db');

my $plugins = $schema->resultset('Plugin');
my $rs = $plugins->search({
    'me.timestamp' => {
        '=' => $plugins->search(
            { 'x.name' => { '=' => { -ident => 'me.name' } } },
            { alias => 'x' }
        )->get_column('timestamp')->max_rs->as_query,
    },
});

say sprintf "%40s %10s %10s %10s", qw/ distro version dancer_1 dancer_2 /;

while( my $p = $rs->next ) {
    next if $p->version !~ /^\d/;
    say sprintf "%40s %10s %10s %10s", 
        map( { $p->$_ } qw/ name version / ),
        map { $_ ? 'passed' : 'failed' } map { $p->$_ } 
            qw/ dancer1_pass dancer2_pass /;
}
