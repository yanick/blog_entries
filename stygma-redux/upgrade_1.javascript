function reducer( state, action ) {
    switch( action.type ) {
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
