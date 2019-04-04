---
title: Meeting Availability Dialect
format: html
created: 10 Mar 2007
original: use.perl.org - http://use.perl.org/~Yanick/journal/32641
tags:
    - Perl
    - ottawa.pm
---

<p><b>Background</b></p><p>Organizing the March meeting of <a href="ottawa.pm.org" rel="nofollow">Ottawa.pm</a>, I came across the problem that setting a date is pretty much like playing Battleship. If a specific date is proposed, people tend respond with boolean answers (can/can't come on that day), which is perfect to assess the punctual value of the attendency function, but quite lousy to determine its monthly optimum.</p><p>So, taking the premise that there's no simple problem that can't be solved by an overcomplex solution, I thought about a way we could all signal our availabilities for a certain month in a simple, standard and easy to parse way (for I have evil plans to hack a script to help me do the scheduling). A few bus commutes later, MADness was born.</p><p><b>Meeting Availability Dialect</b></p><p>A MAD signature line has the following syntax:</p><p>
                <i>month</i> : <i>availability</i></p><p>The month is simply the name of the month. Availability is defined by a sequence of tokens that add or remove available days, depending if they are modified by a plus or minus sign.</p><p>E.g.:</p><p>
                April : WD + Sat - Wed - Day(13)</p><p>which means any work day, plus Satudays, but not Wednesdays or the 13th of the month.</p><p>The base token are:</p><p>Mon<br></br>Tue<br></br>Wed<br></br>Thu<br></br>Fri<br></br>Sat<br></br>Sun<br></br>AD - Any day<br></br>WE - Week-end (same as 'Sat + Sun')<br></br>WD - Week days (same as 'Mon + Tue + Wed + Thu + Fri')</p><p>For a specific date, use Day(X), where X is the date. For example, 'WD - Day(14)' means all week days, except on the 14th (one can surmise that was for February).</p><p>To target a specific week, append '(X)' to the token, where X is the week in question. Several weeks can be given, separated by commas or a range operator '..'. For example, 'Tue - Tue(2)' is equivalent to 'Tue(1,3..4)' and means the first, third or fourth Tuesday of the month.</p><p>Availability is resolved from left to right, which means that, for example,</p><p>
                April : AD - WE + Sun(1)</p><p>means any day, except week-ends, although the first Sunday is okay. Note that<br></br>this is equivalent to</p><p>
                April: WD + Sun(1)</p><p>MAD doesn't consider whitespaces as significant. The full availability, however, must be represented on a single line.</p>
