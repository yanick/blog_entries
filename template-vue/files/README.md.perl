---
package Example::Item;

=begin template
    &lt;li v-if="label ne 'me_too'">{{ label }}&lt;/li>
=cut

use Moose;
with 'Template::Vue';

has label => ( is => 'ro' );

1;
