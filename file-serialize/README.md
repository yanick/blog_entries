---
title: Sometimes, It's the Little Things
url: file-serialize
format: markdown
created: 18 Feb 2015
tags:
    - Perl
---

Sometimes, a technological revolution produces a quantum leap in productivity.

Sometimes, it's a more modest gain. It's the proverbial drop of oil that makes the door
swing a little easier, but mostly rid us of that horrible, horrible screechy
noise its hinges make.

Serialization of Perl structures to files, I do it all the time for a number
of different applications. When I play
with configuration files, use [YAML](cpan:release/YAML)

```perl
use YAML;

my $data = YAML::LoadFile('config.yml');
```

When I wear my web hat, I use [JSON](cpan:release/JSON).

```perl
use Path::Tiny;
use JSON::MaybeXS qw/ to_json /;

path('stuff.json')->spew( to_json $data ); 
```

When I feel funky, I use [TOML](cpan:release/TOML).

```perl
use Path::Tiny;
use TOML;

my $data = from_toml path('config.toml')->slurp;
```

It's all fairly short to type, all mostly painless.

Except...

Except that I have to remember which modules are the 
darlings of the moment. For JSON, are we using `JSON`,
or `JSON::XS`? Ah, no, [JSON::MaybeXS](cpan:release/JSON-MaybeXS)
is the one we use these days. 

Except that they almost accept the same configurations options (pretty-print,
canonical order), but since it's *almost*,  I always have to check the POD 
anyway.

Except that if I began to use JSON, and decide later on that I would
rather use YAML, I have to go back and tweak the code.

So yeah, it's short, it's not that painful. But it's boring and repetitive. 
And I ain't got the time for that.

Hence [File::Serialize](cpan:release/File-Serialize). The module exports 
two functions: `serialize_file` and `deserialize_file`. Want to serialize
something to a file?

```perl
use File::Serialize;

serialize_file 'foo.json' => $data;

```

Want to deserialize?

```perl
my $data = deserialize_file 'foo.yml';
```

Want to set up default behaviors?

```perl
use File::Serialize {
    pretty    => 1,
    canonical => 1,
};

serialize_file 'foo.json' => $data;  # will be pretty and canon

serialize_file 'foo.yaml' => $data;  # won't, 'cause honey-yaml don't care
```

Behind the curtain, nothing immensely fancy. Just guessing the serializing
format from the file extension, using the right serializing modules, and
the mapping of the usual parameters. Nothing fancy. Nothing revolutionary. 
Nothing quantum leapy at all.

But, by Joves, that's one less screech I have to grind my teeth at.
