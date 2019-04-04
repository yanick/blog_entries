use HelloWorld;

my $template = HelloWorld->new(
    user_name => 'Yanick'
);

print $template->render( 'page' );
