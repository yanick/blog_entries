const end_of_game = store => next => action => {

  next(action);

  if( !store.getState().alive ) {
    audio_system.broadcast(
      "Cleaning requested at aisle 5..."
    );
  }

  return;

};
