const start_game = store => next => action => {
    if( action.type !== 'START_GAME' ) {
        return next(action);
    }

    store.dispatch({
        type:           'LOAD_GUN',
        loaded_chamber: Math.floor( 6 * Math.random() )
    });

    return;
}
