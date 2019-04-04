&lt;template>
  &lt;div>
    &lt;h2>&lt;a :name="__file">{{ __file }}&lt;/a>&lt;/h2>

    &lt;div v-if="props">
      &lt;h3>props&lt;/h3>
      &lt;ul>&lt;li v-for="prop in propNames">{{prop }}&lt;/li>&lt;/ul>
    &lt;/div>

    &lt;div v-if="components">
      &lt;h3>components&lt;/h3>
      &lt;ul>&lt;li v-for="(comp,name) in components">
          &lt;a :href="'#' + comp.__file">{{ name }}&lt;/a>
      &lt;/li>&lt;/ul>
    &lt;/div>
  &lt;/div>
&lt;/template>

&lt;script>
export default {
  props: [ '__file', 'props', 'components' ],
  computed: {
    propNames: function() {
      return this.props instanceof Array ) ? this.props 
             : Object.keys(this.props);
    },
  }
}
&lt;/script>
