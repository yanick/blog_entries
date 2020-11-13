---
url: going-postal
format: markdown
created: 2011-09-05
tags:
    - Dancer
    - Perl
    - Business::CanadaPost
    - Canada Post
    - Dancer::Plugin::Cache::CHI
---

# Going Postal (with Dancer)

The [Dancer][dancer] plugin mechanism primary aims to provide
a way to encapsulate pieces of functionality that can
be re-used by different applications. But, it's so light-weight and
handy, that's it's easy to also use it to encapsulate parts of the 
application itself. In that way, it's very reminescent of the concept of
role.

For example, and that's not the best example as the functionality
is probably going to end up on CPAN before long, I'm working on 
a cart for the [Académie des Chasseurs de Primes][acp] site. One of 
the things the cart system has to compute is the postal cost. Since I'm based
in Canada, writing that part of the code is easy:

```perl
sub postal_fee {
    return "much too much";
}
```

... Well, okay. While the return value *is* correct, it could be a little more
precise.  Fortunately, Canada Post provides a [web service to calculate
posting rates](http://sellonline.canadapost.ca). Even better,
there is already [Business::CanadaPost](cpan) on CPAN to interface with
it. Yay!

Hmm... Wait a second. The module hasn't been updated since 2005, and the web
service changed address in the meantime, [b0rking it][borked]. Booo...

Hold your horses... Ah! [The fix][github] is fairly trivial, and once patched, the module seems to
work like a beaut. Woohoo!
    
[dancer]: http://perldancer.org
[acp]: http://academiedeschasseursdeprimes.ca
[borked]: https://rt.cpan.org/Ticket/Display.html?id=70722
[github]: https://github.com/yanick/Business-CanadaPost/commit/2d83a8916a2d480c804e9eed6336ec9af6c58b5f

So, anyway, knowing that I have the tools to get my postage fees, I can
abstract the logic in the application itself to something like

```perl
sub postal_fee {
    my %args = @_;

    my $key = join '-', @args{qw/
        country city width length height weight
    /};

    return cache->compute( $key => sub {
        postage->destination(
            map { $_ => $args{$_} } qw/ country city /
        );

        postage->add_item(
            map { $_ => $args{$_} } 
                qw/ height width length weight /
        );

        return postage->cheapest_shipping_rate;
    } );
}
```

Everything that has to do with the postage is dealt with in the 
`postage` object.  Because Canada Post's web service is a little
slow (and because it doesn't make sense to hit it more than I need too),
I'm also caching retrieved postage fees using `cache->compute` (provided by
[Dancer::Plugin::Cache::CHI](cpan)). 

Now that the high-level logic has been set in the application,
we can implement the details within the plugin. First thing I do 
is to define the Dancer-specific parts of it:

```perl
    package Dancer::Plugin::Postage::CanadaPost;

    use 5.10.0;

    use strict;
    use warnings;

    use Dancer ':syntax';
    use Dancer::Plugin;

    use Business::CanadaPost;

    use List::Util qw/ min /;

    my $singleton;

    ### Dancer stuff

    register postage => sub {
        return $singleton ||= __PACKAGE__->new;
    };

    hook 'after' => sub {
        $singleton = undef;
    };

    register_plugin;
```

Not a lot there. I define the keyword `postage`, which will return the
singleton object for the class (which is auto-created upon its first
call). And, as I don't want previous destinations or items to linger and
mess up future calculations, I also add a hook that
systematically deletes the singleton after every request.

As a side-note, I could have created more helper keywords instead
of using '`postage->destination()`', '`postage->add_item`' and the
like. And I might, in the future, but for now I slightly prefer the
`*$object*->*$action*` type of syntax. I'm OO that way.

After this, what is left to do is to implement the remaining
functionality as a good old straight-forward OO wrapper for
the underlying `Business::CanadaPost` work-horse:

```perl
    ### regular object stuff

    sub new {
        my $class = shift;
        my $self = {};

        my $conf = plugin_setting();

        $self->{cp} = Business::CanadaPost->new(
            merchantid     => $conf->{merchant_id} || 'CPC_DEMO_XML',
            frompostalcode => $conf->{origin}{postal_code},
            testing        => $conf->{testing} // 1,
        );

        return bless $self, $class;
    }

    sub destination {
        my $self = shift;
        my %arg = @_;

        $self->{cp}->setcountry( $arg{country} )         if $arg{country};
        $self->{cp}->settopostalzip( $arg{postal_code} ) if $arg{postal_code};
        $self->{cp}->settocity( $arg{city} )             if $arg{city};

        return $self;
    }

    sub add_item {
        my $self = shift;

        $self->{cp}->additem(@_);

        return $self;
    }

    sub shipping_options {
        my $self = shift;

        my $cp = $self->{cp};

        unless ( $self->{retrieved} ) {
            $cp->getrequest or die $cp->geterror;
            $self->{retrieved} = 1;
        }

        return map { 
            { 
                name => $cp->getshipname($_),
                rate => $cp->getshiprate($_),
            }
        } 1..$cp->getoptioncount;
    }

    sub cheapest_shipping_rate {
        my $self = shift;

        return min map { $_->{rate} } $self->shipping_options;
    }

    1;
```


And I'm done. My application has its `postage`
object. It's only only created if the request needs it, which is good
for performance. Even better, the fees are cached so that the web service has
less chances to be a bottle-neck. That's all I need for the time being, and I
can move to my next task for that cart: PayPal integration.

... But that, my friend, is the topic of another blog entry.

