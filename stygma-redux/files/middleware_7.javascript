let store = createStore(
  reducer,
  applyMiddleware( start_game, end_of_game )
);
