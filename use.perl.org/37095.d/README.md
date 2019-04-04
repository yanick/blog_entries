---
title: Mohlohpoly game
format: html
created: 4 Aug 2008
original: use.perl.org - http://use.perl.org/~Yanick/journal/37095
tags:
    - Perl
    - game
    - Ohloh
---

<p>While working on
<a href="http://search.cpan.org/~yanick/WWW-Ohloh-API/" rel="nofollow">WWW::Ohloh::API</a>,
I caught myself wondering
how one could use <a href="http://www.ohloh.com/" rel="nofollow">Ohloh</a>
for some kind of game.  A few bus trips later with no
book to keep my mind out of trouble, I came up with the variant
of Monopoly given below.  I'm recording it here to get it out
of my system.  Maybe one day, when I'll have time (ah!),
I'll implement it.  It'd be worth it just for the fun of
collecting famous hackers like Pokémons.<nobr> <wbr></wbr></nobr>:-)</p><p>

Rules

</p><ul>
		<li>Every player start with a given amount of "money" (or moohlah).	</li><li>Developers can be bought for a price inversely proportional to their
Ohloh rank. A developer can only
be
owned by a single player at any given time.	</li><li>A player can sell one of his developers at market price at any time.
The player can also sell a developer directly to another player for
any agreed price between them.  Or he can auction the developer in
an open auction to the rest of the players.	</li><li>Any time a developer receives a kudo, the player owning him or her
gets a dividend proportional to the rank of the kudo giver.	</li><li>If a player possesses all developers of a project, they "own"
that project.	</li><li>Each turn, each player gets to "use" a random project picked from
the set of all projects owned by a player, and must
pay a fee proportional to the review score and number of users
of that project.  If the player doesn't have enough moohlah to
pay up, one his or her developer is picked at random and sold
at market value until the player becomes solvent again.  If
the player ends up without moohlah or hackers, he or she goes
under.</li></ul>
