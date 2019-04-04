let was_alive_at_last_news = true;

store.subscribe( () => {
  if ( !was_alive_at_last_news ) return;

  if ( store.getState().alive ) return;

  audio_system.broadcast(
    "Cleaning requested at aisle 5..." 
  );

  was_alive_at_last_news = false;
})
