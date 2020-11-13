# somewhere in the 'workflow' template

oozie_fork 'update_tables' => map {
    'update_' . $_
} $self->tables_to_update;

# sub-template creating the 'update_*table*' action node
show( 'table_update', table_name => $_ ) for $self->tables_to_update;

oozie_join 'all_updates_done' => 'some-next-node';

