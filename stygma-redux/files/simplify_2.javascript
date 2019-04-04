function reducer( state, action ) {
    return {
        summary: summary_reducer( state.summary, action ),
        items:   items_reducer(   state.items,   action ),
    };
}
