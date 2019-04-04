use Web::Query::LibXML;

sub process_directives( $self, $doc, @context ) {
  @context = ( $self ) unless @context;

  $doc = Web::Query::LibXML->new( $doc, { indent => '  ' })
    unless ref $doc;

  $doc->find('.')->and_back->filter( '[v-if]' )->each( sub{
    my($variable,$rest) = split / /, $_->attr('v-if'), 2; 
    $_->attr('v-if' => undef);

    $_->remove unless eval qq{
      Template::Mustache::resolve_context( '$variable', \\\@context )
      $rest
    };
  });

  return $doc->as_html;
}
