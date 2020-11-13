<template>
  <div>
    <h2><a :name="__file">{{ __file }}</a></h2>

    <div v-if="props">
      <h3>props</h3>
      <ul><li v-for="prop in propNames">{{prop }}</li></ul>
    </div>

    <div v-if="components">
      <h3>components</h3>
      <ul><li v-for="(comp,name) in components">
          <a :href="'#' + comp.__file">{{ name }}</a>
      </li></ul>
    </div>
  </div>
</template>

<script>
export default {
  props: [ '__file', 'props', 'components' ],
  computed: {
    propNames: function() {
      return this.props instanceof Array ) ? this.props 
             : Object.keys(this.props);
    },
  }
}
</script>
