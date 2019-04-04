#!/usr/bin/perl 

    use Dancer;

    use 5.10.0;

    my( @naughty, @nice, %gift, $child );

    any '/child/*/**' => sub {
        ( $child ) = splat;
        pass;
    };

    prefix '/child/*';

    get '/naughty' => sub { push @naughty, $child; 'tsk tsk'     };
    get '/nice'    => sub { push @nice, $child;    'nicely done' };

    put '/gift/*' =>  sub { $gift{$child} = (splat)[1]; 'noted' };

    get '/gift' => sub { $child ~~ @naughty ? 'coal' : $gift{$child} };

dance;
