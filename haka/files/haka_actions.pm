get '/' => sub {
    state $url = config->{icecast2}{procotol} . '://' 
               . config->{icecast2}{hostname} 
               . ':' . config->{icecast2}{port} 
               . config->{icecast2}{station};

    redirect $url;
};

get '/collection/*' => sub {
    my $song = file( $Bin, '..', 'collection', splat );

    status $song->stat ? 200 : 404;
};

post '/playlist' => sub {
    add_to_playlist( param( 'song' ) );
};

post '/collection' => sub {
    my $song = upload( 'song' );

    my $dest = file( $Bin, '..', 'collection', $song->basename );

    $song->copy_to( $dest->absolute );

    add_to_playlist( $dest->absolute );

    'yay';
};

sub add_to_playlist {
    my $song = shift or return;

    # yes, you are permitted to scream
    my $p = dir( $Bin, '..', 'playlist' );

    print { $p->file( sprintf "%06d", 
        10 + max map { file($_)->basename } $p->children 
    )->openw } "$song";
}
