import _ from 'lodash';

let Month = require('./Month.vue').default;

function add_component ( comps, component ) {
    if ( !component ) return comps;

    comps[ component.__file ] = component;
    if ( component.hasOwnProperty('components') ) {
        _.values(component.components).map( c => add_component( comps, c ) );
    }
    return comps;
}

let components = add_component({},Month);
