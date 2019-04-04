---
url: dbix-class-deploymenthandler-rocks
format: markdown
created: 2011-01-20
tags:
    - Perl
    - DBIx::Class::DeploymentHandler
    - SQL::Translator
---

# DBIx::Class::DeploymentHandler is Awesome

[DBIx::Class::DeploymentHandler](cpan) is a fairly young module. It's a
little raw at
the edges and a wee bit terse in term of documentation. It's also a complex thing and,
trust me, it'll takes more than a few minutes of playing with it to get your mind around
how it works. But once you begin to understand what it can do, *Whoa*, that's
one seriously powerful beast, that module is.  But don't take my word for it,
let me show you.

Say that I have a [DBIx::Class](cpan) representation of my database's
schema, with three versions already tucked in the repository. Then, I can
write a little script called `prep_db.pl`:

<galuga_code code="Perl">prep_db.pl</galuga_code>

And with it, do:

<pre code="bash">
$ git checkout v1 &amp;&amp; ./prep_db.pl 
processing version 1 of MyDB::Schema...
generating deployment script
generating graph
done

$ git checkout v2 &amp;&amp; ./prep_db.pl 
processing version 2 of MyDB::Schema...
generating deployment script
generating upgrade script
generating downgrade script
generating graph
done

$ git checkout v3 &amp;&amp; ./prep_db.pl 
processing version 3 of MyDB::Schema...
generating deployment script
generating upgrade script
generating downgrade script
generating graph
done
</pre>

Once this is, done, we'll have a new direction, `sql`, in our project:

<pre code="plain">
$ tree sql
sql
|-- diagram-v1.png
|-- diagram-v2.png
|-- diagram-v3.png
|-- MySQL
|   |-- deploy
|   |   |-- 1
|   |   |   |-- 001-auto.sql
|   |   |   `-- 001-auto-__VERSION.sql
|   |   |-- 2
|   |   |   |-- 001-auto.sql
|   |   |   `-- 001-auto-__VERSION.sql
|   |   `-- 3
|   |       |-- 001-auto.sql
|   |       `-- 001-auto-__VERSION.sql
|   |-- downgrade
|   |   |-- 2-1
|   |   |   `-- 001-auto.sql
|   |   `-- 3-2
|   |       `-- 001-auto.sql
|   `-- upgrade
|       |-- 1-2
|       |   `-- 001-auto.sql
|       `-- 2-3
|           `-- 001-auto.sql
|-- PostgreSQL
|   ... same as for MySQL
`-- SQLite
    ... ditto
</pre>

What does that mean? That means that our 60-something lines of Perl above
allowed us to automatically generate SQL scripts, for every version of our schema and 
for SQLite, MySQL and Postgres to 

* deploy the database at that version.

* upgrade the database from *$version-1* to *$version*.

* downgrade the database from *$version* to *$version-1*.

And if you paid attention, you'll see that I also threw in at the
end of that script a little stanza that uses [SQL::Translator](cpan)
to also generate diagrams of the schema's version that will look like this:

<div align="center"><img src="__ENTRY_DIR__/diagram-v2.png" /></div>

Let's reiterate, because I think the feat is amazing enough to warrant it: our
little program has made trivial the creation of deployment scripts for the
database, as well as upgrades and downgrades from and to any version. 

With pretty (or at least serviceable) pictures included.

For three different flavors of databases.

Add to that the fact that the deploy/upgrade/downgrade scripts can be
subsequently tweaked, or more scripts -- both SQL and Perl scripts --
can be thrown in the mix for, for example, populate the database
for its different incarnations, and it's not hard to see that this
module is a fantastic tool that has the potential to vastly reduce the 
headaches related to database deployment.


