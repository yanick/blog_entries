&lt;template>
  &lt;div>
    &lt;Component v-bind="component" 
        v-for="component in all_components" />
  &lt;/div>
&lt;/template>

&lt;script>
import Component from './Doc/Component.vue';
import _ from 'lodash';
import add_component from './utils';

let Month = require('./Month.vue').default;

let components = add_component({},Month);

export default {
    components: { Component },
    data: () => ({ all_components: components })
};
&lt;/script>
