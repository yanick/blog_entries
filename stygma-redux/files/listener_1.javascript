let store = createStore(
  reducer,
  applyMiddleware( start_game )
);
