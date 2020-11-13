module.exports = plugin => {
    const _ = require('lodash');

    plugin.tw = _.once( () => {
        const Taskwarrior = require( './taskwarrior').default;
        return new Taskwarrior();
    });

    plugin.registerFunction( 'TaskShow', taskShow(plugin) );
};

const taskShow = plugin => async ( filter = [] ) => {

    console.log( "filter: ", filter );

    const fp = require('lodash/fp');

    let tasks = await plugin.tw().export( filter )
                |> fp.sortBy( 'data.urgency' )
                |> fp.reverse
                |> fp.map( taskLine );

    await replaceCurrentBuffer(plugin)(tasks);

    await Promise.all([
        plugin.nvim.input('1G'),
        plugin.nvim.command(':TableModeRealign'),
    ]);
};

const replaceCurrentBuffer = plugin => async ( lines ) => {
    const buffer = await plugin.nvim.buffer;

    await buffer.setLines(lines, {
        start: 0, end: -1, strictIndexing: true,
    });
};

function taskLine( {data} ) {
    const _ = require('lodash');

    data.urgency = parseInt(data.urgency);

    if( data.tags ) data.tags = data.tags.join(' ');

    if ( data.project && data.project.length > 15 ) {
        data.project = _.truncate( data.project, 15 );
    }

    const moment = require('moment');

    [ 'due', 'modified' ].filter( f => data[f] ).forEach( f => {
        data[f] = moment(data[f]).toNow();
    });

    return '|' + [
        'urgency', 'priority', 'due', 'description', 'project',
        'tags', 'modified', 'uuid'
    ].map( k => data[k] || ' ' ).join( '|' ).replace( /\n/g, ' ' );

}


