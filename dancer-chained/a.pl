use Dancer ':syntax';

    set logger => 'console';
    set 'log' => 'core';

    get qr!/user/([^/]+)! => sub {
        var user => (splat)[0];
        pass;
    };

    get '/user/*/courses' => sub {
        my $user = vars->{user};

        return "$user\'s courses all have been cancelled";
    };

    get qr!/user/[^/]+/course/([^/]+)! => sub {
        var course => (splat)[0];
        pass;
    };

    get '/user/*/course/*/subscribe' => sub {
        my $user   = vars->{user};
        my $course = vars->{course};

        return "$user subscribed to $course";
    };

    get '/user/*/course/*/is_subscribed' => sub {
        my $user   = vars->{user};
        my $course = vars->{course};

        return "$user might have subscribed to $course " 
             . "but I can't find the papers";
    };

    my $routes = Dancer::App->current->registry->routes;
    use XXX;
    XXX $routes;
    my %routes;
    while ( my ( $method, $route ) = each %$routes ) {
        push @{$routes{$route}}, $method;
    }

    for my $r ( sort keys %routes ) {
        print '[ ', join( ', ', sort @{$routes{$r}} ), ' ] ';
        print $r, "\n";
    }


dance;
