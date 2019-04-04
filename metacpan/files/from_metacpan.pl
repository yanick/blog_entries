sub distributions {
    my $self = shift;

    my $page =
      get sprintf 'http://api.metacpan.org/dist/_search?q=author:"%s"',
      $self->author_id;

    my $json = from_json($page);

    return map { {
            name    => $_->{name},
            version => $_->{version},
            url     => 'http://search.cpan.org/dist/' . $_->{name},
            date    => DateTime::Format::Flexible->parse_datetime(
                $_->{release_date}
            ), } }
           map { $_->{_source} } 
               @{ $json->{hits}{hits} };

}
