const end_of_game = store => next => action => {

    next(action);

    return;

};
