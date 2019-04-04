use 5.10.0;

use lib '.';


use A;
use C;

$DB::single = 1;

A->add('a');
C->add('b');

say A->all;
say C->all;



