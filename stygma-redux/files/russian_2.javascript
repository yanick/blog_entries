let default_state = { 
  loaded_chamber = null,
  alive      = true
};

function reducer( state = default_state , action ) {

  switch( action.type ) {

    case 'LOAD_GUN': return { 
      ...state,
       loaded_chamber: action.chamber 
    };

    default: return state;
  }

}
