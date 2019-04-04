sub distributions {
    my $self = shift;

    my $page = get $self->author_cpan_url;

    my $dists = pQuery($page)->find('table:eq(1) tr');

    my @dists;

    $dists->each(
        sub {
            return unless shift;    # first one is headers

            my $row  = pQuery($_);
            my $name = $row->find('td:eq(0) a')->text();

            $name =~ s/-v?([\d._]*)$//;    # remove version

            my $version = $1;

            my $url = "http://search.cpan.org/dist/$name";

            $name =~ s/-/::/g;

            my $desc = $row->find('td:eq(1)')->text();
            my $date = DateTime::Format::Flexible->parse_datetime(
                $row->find('td:eq(3)')->text );

            push @dists,
              { name    => $name,
                url     => $url,
                desc    => $desc,
                date    => $date,
                version => $version,
              };
        } );

    return @dists;
}
