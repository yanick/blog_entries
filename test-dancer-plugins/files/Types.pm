package DancerTest::Types;

use MooseX::Storage::Engine;
 
use MooseX::Types -declare => [qw/
    DateTimeClass
/];
 
use Moose::Util::TypeConstraints;
use DateTime;
use DateTime::Format::ISO8601;

class_type 'DateTimeClass' => { class => 'DateTime' };
 
MooseX::Storage::Engine->add_custom_type_handler(
    'DateTimeClass' => (
        expand   => sub {
            DateTime::Format::ISO8601->parse_datetime(shift)
        },
        collapse => sub { (shift)->iso8601 },
    ),
);
 
1;
