---
title: Working with Jolly Santa's Outstanding Notes
url: merry-xmas
format: markdown
created: Dec 23 2014
tags:
    - Perl
---

> *Note:* here's an article that couldn't make it to the Perl Advent calendar.
> Can't really let it go to waste, now, can I? Merry Xmas, and here's to 
> happiness and warmth for y'all!

Santa Claus's workshops, like any other organization working under lot of
pressure and chronically undermanned (in this case, quite literally,
as no elf stands taller than four feet), are
a little bit of a hot, cocoa-scented mess. The 
workshops's many systems could
be said to be so
many special snowflakes, and they bandy information between them with 
quite an impressive array of protocols and
serialization format. Fortunately for everybody, a crack team of 
develfopers lead by Gluggagaegir make sure that the bedlam remains under
relative control.

Their challenge of today is to deal with Santa's very special 
short list, available as a JSON document:

```
{ "good": [ { "rjbs": { "wish": [ "Mark III Ogre", 
"Green Fairy's Vintage Nectar" ] } } , { "miyagawa": { 
"wish": [ "peculiar purple pouch" ] } } ], "bad": [ {
"sawyer": { "reason": 
"wishing things to die is not nice" } } ] }
```

Typical. Formatting is inexistant, the structure is less than optimal, but
at least it's well-formed. That's however all Glugg and his cohorts need
to be able to leverage [App::jt](cpan:App::jt) to tame and manipulate the document,
straight from the command line.

For example, the first thing they usually do is to pretty-print 
the JSON so that they can look at it without going blind.

```
$ jt < shortlist.json
[
{
    "wishlist" : [
        "Mark III Ogre",
        "Green Fairy's Vintage Nectar"
    ],
    "name" : "rjbs",
    "verdict" : "nice"
},
{
    "verdict" : "nice",
    "wishlist" : [
        "peculiar purple pouch"
    ],
    "name" : "miyagawa"
},
{
    "reason" : "wishing things to die is not nice",
    "wishlist" : [
        "hug blanket"
    ],
    "name" : "sawyer",
    "verdict" : "naughty"
}
]
```

They also can quickly filter entries, and output the data in 
an easy to manage csv format to send to the other departments.

```
$ cat shortlist.json                     | \
    jt --grep '$_{verdict} eq "naughty"' | \
    jt --field name,reason --csv
name,reason
sawyer,"wishing things to die is not nice"
```

If push comes to shove, they can even munge the data on the fly. For example, 
this year the North Pole's budget is tight, so it's strictly one gift per
person:

```
$ cat shortlist.json | jt --grep '$_{verdict} eq "nice"' | jt --map '$_{wishlist} = $_{wishlist}[0] '
[
{
    "wishlist" : "Mark III Ogre",
    "verdict" : "nice",
    "name" : "rjbs"
},
{
    "wishlist" : "peculiar purple pouch",
    "name" : "miyagawa",
    "verdict" : "nice"
}
]
```

JSONPath, it goes without saying, is a non-feature.

```
$ cat shortlist.json | jt --json-path '$..name'
[
    "rjbs",
    "miyagawa",
    "sawyer"
]

```

And since it's all Perl underneath, a clever develfoper even found ways to
bend the tool into doing things it wasn't expected to do. Like only printing a
cumulative statement:

```
$ cat shortlist.json | \
    jt --silent --map '$::tally{$_{verdict}}++; $::once++ or eval q!END { say join " ", %::tally}!'
naughty 1 nice 2
```
