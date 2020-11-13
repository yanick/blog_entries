import { combineReducers } from 'redux';

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
