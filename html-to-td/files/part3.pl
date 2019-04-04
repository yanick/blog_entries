style '#text' => (
    process => sub { $_[1]->data =~ /\S/ },
    pre     => "outs '",
    post    => "';",
    filter  => sub { s/'/\\'/g; s/^\s+|\s+$//gm; $_ },
);
