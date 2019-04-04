---
title: PerlWar 0.02 is out
format: html
created: 22 Oct 2006
original: use.perl.org - http://use.perl.org/~Yanick/journal/31385
tags:
    - Perl
    - Games::Perlwar
---

	<p>
    note: this message was originaly sent to the PerlWar mailing
    list (http://babyl.dyndns.org/mailman/listinfo/perlwar)
  </p><p>
    Almost on the anniversary day of the initial release of
    PerlWar, I'm happy to announce that I (finally) stamped
    and released PerlWar 0.02 (now in transit toward your nearest
    CPAN mirror).
  </p><p>
    Although the innards of the game engine have been massively
    rewritten, the look'n'feel of the game itself has
    remain mostly the same. The new elements a player might
    care about are:
  </p><ul>
    <li>
      Agents have access to three new variables: $O, the player
      owning the agent, @o, the list of players agents pretend
      to belong to, and $o, the modifiable facade of the current
      agent.
    </li><li>
      The Blitzkrieg variant (in which players only submit an
      agent on the first turn) is now implemented.
    </li><li>
      The roster of a game can be predefined (as it was the case
      before), or it can be declared 'ad-hoc', in which
      case any player registered to a master file can automatically
      join a not-started-yet game by simply submitting an agent.
    </li></ul><p>
    To kick the tires, I've created a new ad-hoc, Blitzkrieg
    game at http://babyl.dyndns.org/pw/alpha/. The game will
    be run this Friday (Oct 27th) at roughly 8:00pm EST. Everybody
    who wish to participate is welcome. For whoever was in the
    last game, I've migrated the names and password to the
    new player master list. If you weren't there or have
    forgotten your password (which would be small wonder, considering
    that it's been over a year), just poke me and I'll
    do all the appropriate magic.
  </p>
