subscribe tw_show => rpcrequest
    sub( $self, $event ) {
        my $buffer_id;

        $self->rpc->api->vim_get_current_buffer
        ->then(sub{ $buffer_id = ord $_[0]->data })
        ->then(sub{
            my @tasks = $self->task->export( '+READY', $event->all_params );

            my @things =
                map { $self->task_line($_) }
                sort { $b->{urgency}  - $a->{urgency} }
                @tasks;

            s/\n/ /g for @things;

            return @things;
        })
        ->then( sub{
            $self->rpc->api->nvim_buf_set_lines( $buffer_id, 0, 1E6, 0, [ @_ ] );
        })
},
        sub { $_[0]->rpc->api->vim_input( '1G' ); },
        sub { $_[0]->rpc->api->vim_command( ':TableModeRealign' ); };

sub task_line($self,$task) {
    $task->{urgency} = sprintf "%03d", $task->{urgency};
    $task->{tags} &&= join ' ', $task->{tags}->@*;

    no warnings 'uninitialized';
    if ( length $task->{project} > 15 ) {
        $task->{project} = ( substr $task->{description}, 0, 12 ) . '...';
    }

    $task->{$_} = relative_time($task->{$_}) for qw/ due /;
    $task->{$_} = relative_time($task->{$_},-1) for qw/ modified /;

    no warnings;
    return join '|', undef,
            $task->@{qw/ urgency priority due description project tags modified uuid /},
            undef;
}

sub relative_time($date,$mult=1) {
    state $now = DateTime->now;

    return unless $date;

    # fine, I'll calculate it like a savage

    $date = DateTime::Format::ISO8601->parse_datetime($date)->epoch;

    my $delta = int( $mult * ( $date - time ) / 60 / 60 / 24 );

    return int($delta/365) . 'y' if abs($delta) > 365;
    return int($delta/30) . 'm' if abs($delta) > 30;
    return int($delta/7) . 'w' if abs($delta) > 7;
    return $delta . 'd';
}
