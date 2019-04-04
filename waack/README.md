---
url: waack
created: 2014-06-14
tags:
    - Perl
    - Dancer
---

# Instant REST API For Any Databases

Not so long ago, I was playing with 
ElasticSearch, which has the interesting characteristic of
having a REST API as
its primary interface. Sure, it's a little more stilted and awkward than
any native interface but, on the other hand, it's a nice universal type
of API. Any language that can make a http request can talk to it and, hey,
bad comes to worse, even 'curl' will do. It would be kinda cool if other databases
had such a web service.

And then I began to think...

Don't we have [DBIx::Class::Schema::Loader](cpan:DBIx-Class-Schema-Loader),
which can connect to a database and auto-generate its DBIx::Class schema?

``` perl
package MyDB;

use parent 'DBIx::Class::Schema::Loader'; 

...;

# later on

my $schema = MyDB->connect( 'dbi:SQLite:foo.db' ); # boom, we have our schema

```

And once we have a [DBIx::Class](cpan:DBIx-Class) representation of a schema,
can't we introspect it and pretty much get everything there is to know about
it?

``` perl
use Data::Printer;

# get all the table names
my @tables = $schema->sources;

# and all the columns of all the tables
for my $table ( $schema->sources ) {
    say "Table $table";
    p $schema->source($table)->columns_info;
}

```

That is, that's if we want to do it manually, considering that there's already 
[SQL::Translator](cpan:SQL-Translator) that can do most of the job for us.

``` perl
use SQL::Translator;

print SQL::Translator->new (
    parser      => 'SQL::Translator::Parser::DBIx::Class',
    parser_args => {
        dbic_schema => $schema,
    },
    producer    => 'JSON',
)->translate;
```

Of course, since we are talking web service, we will want to pass everything
back and forth using JSON, including database entries.
Well, that's hardly a problem if we use
[DBIx::Class::Helper::Row::ToJSON](cpan:DBIx-Class-Helper-Row-ToJSON).

So it seems we have the database side covered. For the web framework? You'll probably not be surprised to see me go with 
[Dancer](cpan:release/Dancer).  Not only can we leverage the serializers and 
plugins like 
[Dancer::Plugin::DBIC](cpan:Dancer-Plugin-DBIC), but setting routes are 
ridiculously easy.

``` perl
get '/_tables' => sub {
    return [ schema->sources ];
};
```

Even niftier: remember that Dancer routes are defined at runtime, so 
we can introspect that schema as much as we want and come up with any route we
can dream of.

```perl
my @primary_key = schema->source($table)->primary_columns;
my $row_url = join '/', undef, $table, ( '*' ) x @primary_key;
 # GET /<table>/<pk1>/<pk2>
get $row_url => sub {
    my @ids = splat;
    return $schema->resultset($table)->find({
        zip @primary_key, @ids
    });
};
 # GET /<table>
get "/$table" => sub {
    my @things = $schema->resultset($table)->search({ params() })->all;
    return \@things;
};
 # create new entry
post "/$table" => sub {
    $schema->resultset($table)->create({ params() });
};
```

Added bonus: 
the way Dancer's `params()` conglomerate parameters defined in the
query string and in the serialized body of the request plays in our favor:
simple queries can be passed directly via the url, and more complicated
ones can be defined as JSON structures.

So, you put all of this together, and you obtain
[waack](gh:yanick/waack). All it needs is a dsn pointing to the right
database (and credentials, if needed). To illustrate, let's try with 
my Digikam SQLite database.

``` bash
$ waack dbi:SQLite:digikam4.db
>> Dancer 1.3124 server 28914 listening on http://0.0.0.0:3000
>> Dancer::Plugin::DBIC (0.2100)
== Entering the development dance floor ...
```

And now, let's fire up [App::Presto](cpan:release/App-Presto) as our
REST client.


```
$ presto http://enkidu:3000

http://enkidu:3000> type application/json
```

First, we can retrieve all the table names.

```
http://enkidu:3000> GET /_tables
[
   "TagsTree",
   "ImageMetadata",
   "Tag",
   "Setting",
   "ImageRelation",
   "ImageTag",
   "ImageProperty",
   "ImageInformation",
   "ImageHaarMatrix",
   "ImageCopyright",
   "VideoMetadata",
   "ImageHistory",
   "DownloadHistory",
   "Search",
   "ImageTagProperty",
   "Image",
   "Album",
   "ImagePosition",
   "TagProperty",
   "AlbumRoot",
   "ImageComment"
]
```

We can also get the whole schema. As Raw JSON.

```
http://enkidu:3000> GET /_schema
{
   "translator" : {
      "producer_args" : {},
      "show_warnings" : 0,
      "add_drop_table" : 0,
      "parser_args" : {
         "dbic_schema" : null
      },
      "filename" : null,
      "no_comments" : 0,
      "version" : "0.11018",
      "parser_type" : "SQL::Translator::Parser::DBIx::Class",
      "trace" : 0,
      "producer_type" : "SQL::Translator::Producer::JSON"
   },
   "schema" : {
      "tables" : {
         "ImageRelations" : {
            "options" : [],
            "indices" : [],
            "order" : "12",
            "name" : "ImageRelations",
            "constraints" : [
               {
                  "type" : "UNIQUE",
                  "deferrable" : 1,
                  "name" : "subject_object_type_unique",
                  "on_delete" : "",
                  "reference_fields" : [],
                  "fields" : [
                     "subject",
                     "object",
                     "type"
                  ],
                  "match_type" : "",
                  "reference_table" : "",
                  "options" : [],
                  "expression" : "",
                  "on_update" : ""
               }
            ],
...
```

Or as something more friendly to the human eye.

![html view of the schema](schema_html.png)

Too much? We can get the columns of a single table.

```
http://enkidu:3000> GET /Tag/_schema
{
   "iconkde" : {
      "is_nullable" : 1,
      "data_type" : "text",
      "is_serializable" : 1
   },
   "name" : {
      "is_serializable" : 1,
      "data_type" : "text",
      "is_nullable" : 0
   },
   "id" : {
      "is_nullable" : 0,
      "data_type" : "integer",
      "is_auto_increment" : 1,
      "is_serializable" : 1
   },
   "icon" : {
      "is_nullable" : 1,
      "data_type" : "integer",
      "is_serializable" : 1
   },
   "pid" : {
      "is_serializable" : 1,
      "is_nullable" : 1,
      "data_type" : "integer"
   }
}
```

Query that table, with a simple condition...

```
http://enkidu:3000> GET /Tag id=1
[
   {
      "name" : "orchid",
      "icon" : null,
      "id" : 1,
      "pid" : 0,
      "iconkde" : null
   }
]
```

... or with something a little more oomphie.

```
$ curl -XGET -H Content-Type:application/json --data '{"name":{"LIKE":"%bulbo%"}}' http://enkidu:3000/Tag
[
   {
      "pid" : 1,
      "name" : "Bulbophyllum 'Melting Point'",
      "icon" : null,
      "id" : 32,
      "iconkde" : "/home/yanick/Pictures/My Plants/IMG_0461.JPG"
   },
   {
      "id" : 56,
      "iconkde" : "tag",
      "icon" : null,
      "pid" : 39,
      "name" : "Bulbophyllum ebergardetii"
   },
   {
      "name" : "bulbophyllum",
      "pid" : 564,
      "iconkde" : null,
      "id" : 565,
      "icon" : 0
   }
]
```

Btw: I cheated for that last one. 
Presto doesn't send body with GET requests. And Dancer doesn't deserialize GET
bodies either. Patches will be written tonight.


Anyway, back with the show. We can also select specific rows by primary keys.

```
http://enkidu:3000> GET /Tag/1
{
   "id" : 1,
   "iconkde" : null,
   "pid" : 0,
   "icon" : null,
   "name" : "orchid"
}
```

Create new rows.

```
http://enkidu:3000> POST /Tag '{"name":"nepenthes","pid":0}'
{
   "pid" : 0,
   "name" : "nepenthes",
   "iconkde" : null,
   "icon" : null,
   "id" : 569
}
```
And do updates.

```
http://enkidu:3000> PUT /Tag/569 '{"icon":"img.png"}'
{
   "icon" : "img.png",
   "iconkde" : null,
   "pid" : 0,
   "name" : "nepenthes",
   "id" : 569
}
```

Not too shabby, isn't? Mostly considering that, if 
you look at the [source of
waack](https://github.com/yanick/waack/blob/master/waack), you'll see that 
**it barely clock over 100 lines of code**. Take a minute and let this sink
in. 

One hundred lines of code. For a universal database 
REST web
service.

If that's not standing on the
shoulders of giants, then I don't know what is.
