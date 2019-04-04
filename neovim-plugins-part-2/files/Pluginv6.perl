sub BUILD {
  my $self = shift;

  $self->rpc->subscribe( file_to_package_name => sub {
    my $event = shift;

    my $filename;

    $self
      ->shall_get_filename
      ->then(sub{ $filename => shift })
      ->then(sub{ $self->api->vim_get_current_line })
      ->then(sub{ 
        $self->api->vim_set_current_line(
          shift =~ s/__PACKAGE__/file_to_package_name($filename)/er
        )
      })
      ->finally(sub{ $event->resp('ok') });
}
