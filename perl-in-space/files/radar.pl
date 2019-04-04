ajax  '/radar' => sub {
    return to_json ( {
        ships => [
            {
                id => $ship->id,
                location => {
                    x => $ship->x,
                    y => $ship->y,
                },
                heading => $ship->heading,
            },
        ],
    } );
};

