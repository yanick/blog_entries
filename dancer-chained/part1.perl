 # /user/*                       (intermediary action)
sub user :Chained('/') :PathPart('/user') :CaptureArgs(1) {
    my ( $self, $c, $user ) = @_;

    $c->stash->{user} = $user;
}

 # /user/*/courses               (endpoint action)
sub courses :Chained('user') :PathPart('courses') {
    my ( $self, $c ) = @_;

    my $user = $c->stash->{user};
    $c->res->body( "$user's courses all have been cancelled" );
}

 # /user/*/course/*              (intermediary action)
sub course :Chained('user') :PathPart('course') :CaptureArgs(0) {
    my ( $self, $c, $course ) = @_;

    $c->stash->{course} = $course;
}

 # /user/*/course/*/subscribe    (endpoint action)
sub subscribe :Chained('course') {
    my ( $self, $c ) = @_;

    my $user   = $c->stash->{user};
    my $course = $c->stash->{course};
    $c->res->body( "$user subscribed to $course" );
}

 # /user/*/course/is_subscribed  (endpoint action)
sub is_subscribed :Chained('course') {
    my ( $self, $c ) = @_;

    my $user   = $c->stash->{user};
    my $course = $c->stash->{course};
    $c->res->body( "$user might have subscribed to $course "
                    . "but I can't find the papers" );
}
