---
title: Chained Actions with Dancer
url: chained-dancer
format: markdown
created: 29 Mar 2011
tags:
    - Perl
    - Dancer
    - Catalyst
---

Sometimes, I can be slow on the uptake.

A few days ago, had you asked me one big plus of [Catalyst][1] over
[Dancer][2], 
I would have said "chained actions". Chained actions allow to split the logic
underlaying an uri into smaller components associated with its segments. 
A very neat, *DRY*-friendly ways of doing things. 

[1]: http://www.catalystframework.org
[2]: http://perldancer.org

For example, say that I have
a course subscription web service with the uris
'/user/*name*/courses',
'/user/*name*/course/*course_id*/subscribe' and
'/user/*name*/course/*course_id*/is_subscribed'. With Catalyst,
its controller's actions could look like:

    #syntax: perl
    
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

But then, I discovered Dancer's 'pass' directive. And I saw the
light.  With Dancer, the chained behavior described above could be done 
with:

    #syntax: perl
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

Granted, it's not as clean as it could be; while writing this example
I discovered that '`prefix`' doesn't play very well with regex-based
routes (darn!), and we're missing a megasplat character to be able to do

    #syntax: perl
    get '/user/**' => sub {
            # for '/user/bob/course/bar' 
            # @splatters = qw/ bob course bar /
        my @splatters = splat;  
    };

but that isn't anything that a patch or two won't solve. The point is that
not only we can have chained actions, but we are not limited to linear chains.
Our action endpoint can have as many overlapping intermediary routes as we want. 
For example, we can
have more than one instance of the same route for different pieces of logic:

    
    #syntax: perl
    get qr!/user/[^/]+/course/([^/]+)! => sub {
        var course => (splat)[0];
        pass;
    };

    get qr!/user/[^/]+/course/[^/]+! => sub {
        # somebody's interested? better get organized
        $teacher{ $vars->{course} } ||= $profs[ rand @profs ];

        pass;
    };

And, of course, since the power of regular expressions is at
our fingertips, we can also have any type of laterally-injected
piece of funkiness we can dream off:

    #syntax: perl
    get qr!/user/([^/]+)/course/\1/! => sub {
        var homonym_discount => 1;
        pass;
    };


As I said up top, this is probably old news for lots of people, 
but for me it's a big piece of the puzzle falling into place.
One that fills me with mirth. And maybe more than just a tad of 
nefarious glee. Me has a new toy to abuse. *Wheeeee!* 
