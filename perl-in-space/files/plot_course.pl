ajax '/plot_course' => sub {
    my @log = $ship->set_course( params->{course} );

    return to_json({
        log => \@log,
        trajectory => $ship->trajectory,
    });
};
