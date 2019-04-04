function summary_reducer( state, action ) {
    return {
        total:     summary_total_reducer( state.total, action ),
        tax:       summary_tax_reducer( state.tax, action ),
        nbr_items: summary_nbr_items_reducer( state.nbr_items, action ),
    };
}
