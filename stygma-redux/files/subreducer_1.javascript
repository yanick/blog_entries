function summary_reducer( state, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':
            return { total: 0, nbr_items: 0 };

        case 'TAX':
            return { ...state, tax: action.payload.percent };

        case 'ADD_TO_CART':
            return {
                total: state.total + action.payload.price,
                nbr_items: state.nbr_items + 1,
            };
    }
}
