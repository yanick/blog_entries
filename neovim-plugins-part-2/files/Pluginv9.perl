subscribe file_to_package_name => rpcrequest
    sub($self,@) {
        $self->shall_get_filename
    },
    sub($self, $filename) {
        $self->api->vim_get_current_line
            ->then(sub($line) { ( $filename, $line ) })
    },
    sub($self,$filename,$line){ 
        $line =~ s/__PACKAGE__/
            file_to_package_name($filename)
        /e;
        $self->api->vim_set_current_line($line);
    });
