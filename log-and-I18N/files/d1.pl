use Log::Dispatchouli;
use Ship;

my $log = Log::Dispatchouli->new({
        ident     => 'game',
        to_stdout => 1,
        to_self   => 1,
});

my $ship = Ship->new(
    fleet  => 'StarFleet',
    name   => 'USS Rakudo',
    logger => $log,
);

$ship->engage_thrusters( 12 );
