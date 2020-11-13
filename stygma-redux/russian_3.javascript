let default_state = { 
  loaded_chamber = null,
  alive      = true
};

function reducer( state = default_state , action ) {

  switch( action.type ) {

    case 'PULL_TRIGGER': 
      if ( loaded_chamber === null ) {
        // no bullet
        return state;
      }
      else if ( loaded_chamber === 0 ) {
        return {
          loaded_chamber: null,
          alive:          false 
        };
      }
      else {
        return {
          ...state,
           loaded_chamber: state.loaded_chamber-1 
         };
      }

    case 'LOAD_GUN': return { 
      ...state,
       loaded_chamber: action.chamber 
    };

    default: return state;
  }

}
