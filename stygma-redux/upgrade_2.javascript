function reducer( state, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':
            return {
                summary: { total: 0, nbr_items: 0 },
                items: [],
            };

        case 'ADD_TO_CART':
            return {
                summary: {
                    total: state.summary.total + action.payload.price,
                    nbr_items: state.summary.nbr_items + 1,
                },
                items: [ ...state.items, action.payload ]
            };

        default: return state;
    }
}
