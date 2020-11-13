function expandPackage( line, filename ) {
    let packageName = filename
        .replace( /^(.*\/)?lib\//, '' )
        .replace( /^\//, '' )
        .replace( /\//g, '::' )
        .replace( /\.p[ml]$/, '' );

    return line.replace( '__PACKAGE__', packageName );
}

const setPackageName = plugin => async () => {
    let [ filename, line ] = await Promise.all([
        plugin.nvim.callFunction( 'expand', [ '%:p' ] ),
        plugin.nvim.getLine(),
    ]);

    await plugin.nvim.setLine( expandPackage(line,filename) );
};

module.exports = plugin => {
    plugin.registerCommand( 'SetPackageName', setPackageName(plugin) );
};
