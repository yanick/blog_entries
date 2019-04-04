---
url: dbd-oracle-v1.43_00
format: markdown
created: 1 Apr 2012
tags:
    - perl
    - DBD::Oracle
---

# DBD::Oracle v1.43_00 On CPAN -- Now With 100% Less DBIS

A new trial version of DBD::Oracle is on
[CPAN](https://metacpan.org/release/PYTHIAN/DBD-Oracle-1.43_00/). The meat of
this release is the awesome work Martin Evans did in the murky core of the
beast. He
[explains it better](http://www.martin-evans.me.uk/node/133), but basically
his magic results in a much faster `DBD::Oracle` on thread-enabled perls.

This being said, the changes he did are significant (2.3K lines changed
according to Git), and we would be *very* grateful of anybody finding the time to
try and install that trial version before it goes live (which, unless
something wrong is found, should be in 2 weeks).

## Version 1.43_00 Changelog

### Enhancements

* Removed all DBIS usage fixing and speeding up threaded
   Perls (Martin J. Evans).

### Bug Fixes

- Applied patch from Rafael Kitover (Caelum) to column_info to handle
DEFAULT columns greater in length than the DBI default of 80. The
DEFAULT column is a long and it is a PITA to have to set
LongReadLen which you can only do on a connection handle in
DBD::Oracle. The default maximum size is now 1Mb; above that you
will still have to set LongReadLen (Martin J. Evans)

- Fixed 70meta and rt74753-utf8-encoded to not die if you cannot
connect to Oracle or you cannot install from CPAN if you have not
set up a valid Oracle connection.

- Fixed 75163. Bfile lobs were not being opened before fetching if
ora_auto_lobs was disabled (Martin J. Evans).
    Note: this has a minor impact on non bfile lobs when ora_auto_lobs
is not in force as an additional call to OCILobFileIsOpen will be
made.

- Minor fix to avoid use of uninitialised variable in 31lob.t (Martin J. Evans)

### Documentation

* clarification of when StrictlyTyped/DiscardString can be used and
LongReadLen (Martin J. Evans)

* Documented the 3rd type of placeholder and rewrote the existing pod for placeholders (Martin J. Evans).

