sub BUILD($self,@) {
  $self->rpc->subscribe( file_to_package_name => sub($event) {
    my $filename;

    $self->shall_get_filename
         ->then(sub($f){ $filename = $f })
         ->then(sub{ $self->api->vim_get_current_line })
         ->then(sub($line){ 
            $line =~ s/__PACKAGE__/
                file_to_package_name($filename)
            /e;
            $self->api->vim_set_current_line($line);
         })
         ->finally(sub{ $event->resp('ok') });
    }
}

sub shall_get_filename ($self) {
  $self->api->vim_call_function( 
    fname => 'expand',
    args  => [ '%:p' ] 
  );
}

