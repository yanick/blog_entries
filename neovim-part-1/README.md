---
created: 2015-09-01
---

# Journey to Neovim: MessagePack Encoder

I swear. One day, one day they'll finally come for me, and they will bring me to
the padded room that has been earmarked as my future home. And from this padded cell,
I'll receive visits from a young hacker, and we shall talk of how she can still
hear the yaks crying at night...

Anyway... So, you see, there is that project, [neovim][neovim],
which is a rewrite of vim meant to make its codebase lose some of its aeon-spanning
cruft, so that it'd be less archaic and 
more maintainable. And it's shaping up quite nicely, to the point that
it's becoming more and more possible to switch to it and have one's old
vim configuration just work. Very cool.

One of the big changes that neovim has is how it deals with
plugins and embedded languages. Whereas good ol' vim allows to compile
and embed Perl/Ruby/Python/TCL within vim itself, neovim takes a different approach:
it allows for external programs to connect to the neovim instance and interact
with it via a [RPC API](http://neovim.io/doc/user/msgpack_rpc.html).

Of course, that piqued my interest. Even moreso considering that I'd like
very much to have a neovim alternative to my sweet little mutant [](cpan:Vim-X).  
So off to discovering that RPC I went. 

First discovery: instead of going with JSON as the format for the RPC messaging protocol,
they decided to go with [MessagePack](http://msgpack.org/), which is a binary format
meant to be small and fast to encode/decode. 

Second discovery: the CPAN modules dealing with MessagePack are... kind of not exactly
working in a satisfactory manner. So... yeah, I sighed, veered, took 
the detour, and off to writing an encoder and decoder I went.

## This Week, the Easy Part: Encoding
 
The MessagePack format is pretty easy to grok. Each data type is defined by a 
header, made of one or more bytes, and then followed by its encoded content. 

For example, positive integers of 7 bits or less are encoded as their own value, 
and arrays of 15 values or less have a header made of `0x90` plus the array size. So an array
made of the three integers 5, 7 and 11 would be encoded as

```
0x93 0x05 0x07 0x0b
```

That also means the encoding logic is recursive and pretty straightforward. 
Encoding that small array, for example, would be done as:

```perl
sub encode_fixed_array {
    my @array = @_;

    return join '', chr( 0x90 + @array ), map { encode_value($_) } @array;
}
```

All has to be done is to write that `encode_value()` function, which will look
at what type of variable we're having, and encode it in consequence. Something like

```perl
sub encode_value {
    my thing = shift;

    if ( ref $thing eq 'ARRAY' ) {
        if ( @$thing <= 15 ) {
            return encode_fixed_array(@$thing);
        }
        else {
            ...;
        }
    }
    elsif( ... ) {
    }
    elsif( looks_like_a_number($thing) and $thing >=0 and $thing <= 2**8-1 ) {
        return encode_positive_fixint($thing);
    }

}
```

Easy-peasy. But long-winded. Is there a way to maybe make the conversion happen without
that elsinfinite cascade of conditions?

## Encoding via Coercion. Encoercion? 

The idea behind type coercion is to make a variable of type foo to become of type bar. When 
we encode a data structure into a MessagePack, we turn the structure into a binary string. 
That awfully sounds like  the same thing said differently, isn't?

Let's see if we can use that to our advantage.


First thing to do is to define a `MessagePack` type. While an encoded MessagePack is nothing but a binary string, we need something else to represent it. Let's use a class:

```perl
use experimental 'signatures', 'postderef';

package MessagePack {
    use overload '""' => sub($self) { $$self };

    sub new( $class, $value ) { 
        my $self = \$value;
        bless $self, $class;
    }
}

```

After that, we need to create a type for every, well, type of structure we wish to encode:

```perl
use Types::Standard qw/ Str ArrayRef Int Any InstanceOf /;
use Type::Tiny;

my $PositiveFixInt = Type::Tiny->new(
    parent     => Int,
    name       => 'PositiveFixint',
    constraint => sub { $_ >= 0 and $_ < 2*8-1 },
);

my $FixArray = Type::Tiny->new(
    parent      => ArrayRef,
    name        => 'FixArray',
    constraints => sub { @$_ < 31 },
);

```

And then tie those types with the coercion functions they should use
to turn into MessagePacks:

```perl
my $MessagePack = Type::Tiny->new(
    parent => InstanceOf['MessagePack'],
    name => 'MessagePack',
)->plus_coercions(
    $PositiveFixInt  => \&encode_positive_fixint,
    $FixArray        => \&encode_fixarray,
);
```

Of course, there is no free lunch; we still have to implement 
the different encoding bits, but at least now they are all in
nice, small, distinct functions:

```perl
sub _pack($value) { MessagePack->new( $value ) }

sub encode_positive_fixint($value) {
    _pack( chr $value );
}

sub encode_fixarray($array) {
    _pack(
        join '', chr( 0x90 + @$array ), 
                 map { $MessagePack->assert_coerce($_) } @$array
    )
}

```

And, if we forget for a moment all the other 
encoding subs we have to implement, we're actually done:

```perl
say join " ", map   { sprintf "%x", ord } 
              split '', $MessagePack->coerce( [ 1, 2, 3 ] );

# prints '93 1 2 3'
```



[neovim]: http://neovim.io

