subscribe file_to_package_name => rpcrequest
    sub($self,@) {
        collect_props(
          filename => $self->shall_get_filename,
          line     => $self->api->vim_get_current_line,
        );
    },
    sub($self, $props) {
        $self->api->vim_set_current_line(
            $props->{line} =~ s/__PACKAGE__/
                file_to_package_name($props->{filename})
            /er
        );
    });
