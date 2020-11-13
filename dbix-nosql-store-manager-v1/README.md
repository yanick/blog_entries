---
created: 2018-01-05
tags:
    - perl
    - dbix-nosql
---

# New and Improved: DBIx-NoSQL-Store-Manager

A few years ago, I wanted some quick, no fuss way
to serialize and persist data encapsulated as Moose objects --
a MooSQL database, if you will. In my research, I discovered 
[](cpan:DBIx::NoSQL) and bolted my own
[](cpan:DBIx::NoSQL::Store::Manager) on top of it.

A few seconds ago, a new release of that latter module has been punted
to CPAN. This update adds relationships between those objects. Now, I'm 
very conscious that I'm slowly creeping toward [](cpan:KiokuDB), but I think
(well, whimsically hope) that I managed to balance dwim comfort and dark sorcery.

This being said, let's an example speak for itself. 

## The store itself

<Hackthrough>

<Hackstep src="__ENTRY__/Blog.perl">

First up, the main `Blog` store class. That part is wonderfully boring.

</Hackstep>

</Hackthrough>

## The blog entry

<Hackthrough>

<Hackstep src="__ENTRY__/Blog/Model/Entry_1.perl">

Next we create the class that represents blog entries.

</Hackstep>

<Hackstep src="__ENTRY__/Blog/Model/Entry_2.perl" lines="4-8">

A blog entry has a url (which is also its unique identifier).

</Hackstep>

<Hackstep src="__ENTRY__/Blog/Model/Entry_3.perl" lines="8-13">

And an author, which will also be an object saved in the database.

</Hackstep>

<Hackstep src="__ENTRY__/Blog/Model/Entry_4.perl" lines="6-21">

And can be assigned tags, also saved in the database.

We use two attributes because I want the saved tags to be in fact blog
entry/tag pairs (so that's it's easy, say, to get all blog entries that have
the tag `perl`), but don't want the end-user to have to worry about it.  

</Hackstep>

<Hackstep src="__ENTRY__/Blog/Model/Entry_5.perl" lines="6-8">

Oh yeah, and content. Let's not forget some content...

</Hackstep>

</Hackthrough>

## The authors

<Hackthrough>

<Hackstep src="__ENTRY__/Blog/Model/Author.perl">

We also need an `Author` class. Let's make it minimalistic: a name and an
optional bio.

</Hackstep>

</Hackthrough>

## The tags

<Hackthrough>


<Hackstep src="__ENTRY__/Blog/Model/Tag.perl">

Same deal with the tags.

We want to be able to have the same tag
associated with different blog entries, so we set the store key to be
based on both the tag and the blog's id, and we index on those two values.

</Hackstep>

</Hackthrough>

## Using it

<Hackthrough>


<Hackstep src="__ENTRY__/ex1.perl">

Setting the store is dead easy. Yes, even if the database
didn't previously exist.

Love you, sqlite. Always did, always will.

</Hackstep>

<Hackstep src="__ENTRY__/ex2.perl">

You can create objects and put in the store....

</Hackstep>

<Hackstep src="__ENTRY__/ex3.perl">

... or do it all in one fell swoop.

</Hackstep>

<Hackstep src="__ENTRY__/ex4.perl">

Once created, it can be used as an attribute for another 
object.

</Hackstep>

<Hackstep src="__ENTRY__/ex5.perl">

Or if the object already exist in the db, just use its key.

</Hackstep>

<Hackstep src="__ENTRY__/ex6.perl">

The object doesn't exist yet? Pass in a hashref. It will be taken as the arguments of
the attribute's object constructor.

</Hackstep>

<Hackstep src="__ENTRY__/ex7.perl">

Works with arrays of objects too.

</Hackstep>

<Hackstep src="__ENTRY__/ex8.perl">

What does the search functionality looks like? Like this.

Right now the objects returned by the search aren't tied 
to the store, but [it will be fixed soon](https://github.com/yanick/DBIx-NoSQL-Store-Manager/issues/7).

</Hackstep>

</Hackthrough> 

Enjoy!





