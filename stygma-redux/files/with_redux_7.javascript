import { combineReducers } from 'redux';

function nbr_items( state=0, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':  return 0;
        case 'ADD_TO_CART': return state + 1,
        default:            return state;
    }
}

function tax( state=0, action ) {
    return action.type === 'TAX' ? action.payload.percent : state;
}

function total( state=0, action ) {
    switch( action.type ) {
        case 'CLEAR_CART':  return 0;
        case 'ADD_TO_CART': return state + action.payload.price;
        default:            return state;
    }
}

const summary = combineReducers({ total, tax, nbr_items });

function items( state=[], action ) {
    switch( action.type ) {
        case 'CLEAR_CART':  return [];
        case 'ADD_TO_CART': return [ ...state, action.payload ]
        default:            return state;
    }
}

const reducer = combineReducers({ 
    summary,
    items,
});
