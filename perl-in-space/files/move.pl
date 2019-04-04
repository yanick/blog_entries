ajax '/move' => sub {
    my @log = $ship->set_course( params->{course} );

    push @log, $ship->move;

    return to_json({
        log => \@log,
        id => $ship->id,
        trajectory => $ship->trajectory,
        heading => 180 * $ship->heading / pi,
    });
};
