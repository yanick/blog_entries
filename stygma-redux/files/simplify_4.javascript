function items_reducer( state, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':
            return [];

        case 'ADD_TO_CART':
            return [ ...state, action.payload ]

        default: return state;
    }
}
