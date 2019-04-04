package Haka;

use 5.10.0;

use FindBin qw($Bin);
use XML::Writer;
use Path::Class;

our $ices_pid = start_ices();
END { kill 1, $ices_pid if $ices_pid; }  # leave no child behind 

# defaults
config->{icecast2}{hostname} //= 'localhost';
config->{icecast2}{procotol} //= 'http';
config->{icecast2}{port} //= 8000;

sub start_ices {
    my $ices_conf = "$Bin/../ices/ices.conf";

    open my $conf_fh, '>', $ices_conf;

    my $conf = XML::Writer->new( 
        OUTPUT => $conf_fh,
        NAMESPACES => 1,
        NEWLINES => 1 
    );

    $conf->startTag( [ 'http://www.icecast.org/projects/ices' =>
            'Configuration' ] );

    $conf->startTag( 'Playlist' );
    $conf->dataElement( 'Randomize' => 0 );
    $conf->dataElement( 'Type' => 'perl' );
    $conf->dataElement( 'Module' => 'ices' );
    $conf->dataElement( 'Crossfade' => 5 );
    $conf->endTag;

    $conf->startTag( 'Execution' );
    $conf->dataElement( 'Background' => 0 );
    $conf->dataElement( 'Verbose' => 0 );
    $conf->dataElement( 'BaseDirectory' => "$Bin/../ices" );
    $conf->endTag;

    my $config = config->{icecast2};

    $conf->startTag( 'Stream' );
    $conf->startTag( 'Server' );
    $conf->dataElement( 'Hostname' => $config->{hostname} || 'localhost' );
    $conf->dataElement( 'Port' => $config->{port} || 8000 );
    $conf->dataElement( 'Password' => $config->{password} );
    $conf->dataElement( 'Protocol' => $config->{procotol} || 'http' );
    $conf->endTag;

    $conf->dataElement( 'Mountpoint' => '/haka' );
    $conf->dataElement( 'Name' => 'Haka' );
    $conf->dataElement( 'Genre' => 'Indus-Techno-Trash' );
    $conf->dataElement( 'Description' => '' );
    $conf->dataElement( 'URL' => '' );
    $conf->dataElement( 'Public' => 0 );

    $conf->dataElement( 'Bitrate' => 128 );
    $conf->dataElement( 'Reencode' => 0 );
    $conf->dataElement( 'Samplerate' => 44_100 );
    $conf->dataElement( 'Channels' => 2 );

    $conf->endTag;
    $conf->endTag;

    $conf->end;

    close $conf_fh;

    if ( my $pid = fork ) {
        return $pid;
    }

    $ENV{COLLECTION} = "$Bin/../collection";
    $ENV{PLAYLIST} = "$Bin/../playlist";
    $ENV{PERL5LIB} = "$Bin/../lib";

    exec 'ices', '-c' => $ices_conf;
}

true;
