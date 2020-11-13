---
url: dancer-goes-megasplat
created: 2013-01-15
tags:
    - Perl
    - Dancer
---

# Dancer Goes Megasplat

> So the Holidays are gone... But, as usual, leftovers remain. For most
> people, now that we
> have reached the middle of January, they probably have dwindled to managable
> size, like a chunk of ice that was once a majestic iceberg. A few more
> lunches, and they should be nothing but a (delicious) memory.
> In the spirit of those microwaved echoes of joyous times, here's a 
> Dancer entry that was submitted to the [Perl Advent Calendar](http://perladvent.org/), 
> but didn't find its way to publication.

No, Santa Claus' sleigh just didn't have the mother of all reindeer-benders.
This entry is rather on the little-known but very useful feature of
[Dancer](cpan)
known as the megasplat.

So, what's the megasplat? Well, `Dancer`, being heavily influenced by Ruby's
*Sinatra*, adopted its *splat* placeholder, which allows to capture elements
of a route:

```perl
use Dancer;

get '/wishlist/*' => sub {
    my( $child ) = splat;

    return NortPole::DB->get_wishlist( $child );
};
```

That route will match */wishlist/timmy*, and */wishlist/sandy*, and
the wishlist of every other child in the world.  But what if we want to match
several path elements? That's where we go mega:

```perl
use Dancer;

get '/giddy_up/**' => sub {
    my( $reindeers ) = splat;

    my @exclamations = ( 
        'Now', 'On', 'To the top of the porch', 'To the top of the wall' 
    );

    return join '', map { 
        sprintf "%s, %s!\n",
                $exclamations[rand @exclamations], $_ 
    } @$reindeers;
};

dance;
```

With that, we can hit */giddy_up/Prancer/Dancer/Vixen/Cupid* and get back:

```
Now, Prancer!
To the top of the porch, Dancer!
To the top of the wall, Vixen!
On, Cupid!
```

Beside that, the megasplat can also be used to mimick *Catalyst*'s chaining
behavior:  

```perl
use 5.10.0;

use Dancer;

my( @naughty, @nice, %gift, $child );

any '/child/*/**' => sub {
    ($child) = splat;
    pass;
};

prefix = '/child/*';

get '/naughty' => sub { push @naugthy, $child; 'tsk tsk'     };
get '/nice'    => sub { push @nice, $child;    'nicely done' };

put '/gift/*' =>  sub { $gift{$child} = (splat)[1] };

get '/gift' => sub { $child ~~ $naughty ? 'coal' : $gift{$child} };

dance;
```

Which will give Santa a nice little basic web service for his *Nice &
Naughty* book keeping:

```bash
$ curl http://api.toydb.np/child/rjbs/nice
nicely done
$ curl http://api.toydb.np/child/yanick/naughty
tsk tsk
$ curl -X PUT http://api.toydb.np/child/rjbs/gift/pony
noted
$ curl -X PUT http://api.toydb.np/child/yanick/gift/pony
noted
$ curl http://api.toydb.np/child/yanick/gift
coal
$ curl http://api.toydb.np/child/rjbs/gift
pony
```
