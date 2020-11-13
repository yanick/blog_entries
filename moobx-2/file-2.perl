use Test::More tests => 5;

use 5.20.0;

use MoobX;

use List::AllUtils qw/ first /;

observable my @foo;
@foo = 1..10;

my $value = observer { first { $_ > 2 } @foo };

is $value => 3;

$foo[1] = 5;

is $value => 5;

observable( my $bar = 3 );

autorun {
    diag join ' ', $foo[0], $bar;
    pass if $foo[0] < $bar;
};

# one pass as it get initialized for the first time

$bar -= 5;  # no pass, -2 < 1

$foo[0] = -100;  # pass

$bar = 0; # pass again
