package Neovim::RPC::Plugin::FileToPackageName;

use 5.20.0;
use warnings;

use Neovim::RPC::Plugin;

use experimental 'signatures';

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
      ->then(sub{ $event->resp('ok') });
}


sub shall_get_filename ($self) {
  $self->api->vim_call_function( fname => 'expand', args => [ '%:p' ] );
}

1;
