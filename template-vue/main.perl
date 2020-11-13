package Example::Main;

=begin template
<div>
    <h1>{{ title }}</h1>
    <ul>
        <Item
            v-for="item in items"
            v-if="item ne 'skip_me'"
            :label="item"
        />
    </ul>
</div>
=cut

use Moose;
with 'Template::Vue';

has '+components' => default => sub {[ 'Example::Item' ]};

has [qw/ title items /] => ( is => 'ro' );

1;
