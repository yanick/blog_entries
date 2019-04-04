function summary_nbr_items_reducer( state, action ) {

    switch( action.type ) {
        case 'CLEAR_CART':  return 0;
        case 'ADD_TO_CART': return state + 1,
        default:            return state;
    }

}

function summary_tax_reducer( state, action ) {
    return action.type === 'TAX' ? action.payload.percent : state;
}

function summary_total_reducer( state, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':  return 0;
        case 'ADD_TO_CART': return state + action.payload.price;
        default:            return state;
    }
}

function summary_reducer( state, action ) {
    return {
        total:     summary_total_reducer( state.total, action ),
        tax:       summary_tax_reducer( state.tax, action ),
        nbr_items: summary_nbr_items_reducer( state.nbr_items, action ),
    };
}
