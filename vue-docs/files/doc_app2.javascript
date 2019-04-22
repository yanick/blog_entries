<template>
  <div>
    <Component v-bind="component" 
        v-for="component in all_components" />
  </div>
</template>

<script>
import Component from './Doc/Component.vue';
import _ from 'lodash';
import add_component from './utils';

let Month = require('./Month.vue').default;

let components = add_component({},Month);

export default {
    components: { Component },
    data: () => ({ all_components: components })
};
</script>
