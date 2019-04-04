package Example::Main;

=begin template
&lt;div>
    &lt;h1>{{ title }}&lt;/h1>
    &lt;ul>
        &lt;Item 
            v-for="item in items" 
            v-if="item ne 'skip_me'" 
            :label="item"  
        />
    &lt;/ul>
&lt;/div>
=cut

use Moose;
with 'Template::Vue';

has '+components' => default => sub {[ 'Example::Item' ]};

has [qw/ title items /] => ( is => 'ro' );

1;
