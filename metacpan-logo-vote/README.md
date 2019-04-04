---
title: Meta-CPAN Logo Contest Voting Helper
url: metacpa-logo-vote
format: markdown
created: 25 Mar 2012
tags:
    - Perl
    - Metacpan
    - javascript
    - jquery
---

Today I got an email reminder that the [Metacpan](https://metacpan.org) logos
are all in and that the [voting booths are open](https://vote.metacpan.org/entries), and will be so until 
Friday the 30th of March 2012, 23:00:00 UTC. 

As a dutiful CPANtizen, I immediatly went to see and... oh my lord are there
lots of entries. Fortunately, the voting scheme is based on ranking and not
absolute numbers, which makes things manageable. But even so, with the huge
number of contenders, it's a little hard to keep a preference order straight in
your head. So I decided to code myself a GreaseMonkey helper.
It is just a little thing that re-orders the entries based on the score you give
them. Nothing earth-shattering, but it sure helps. And while there are more tweakings
that could be done, I should probably stop shaving the yak and begin to vote
already (and so should you!).

As usual, the script is available on
[GitHub](https://github.com/yanick/greaseyanick/blob/master/metacpan_vote.user.js).
If you can think of any other improvements, by all means, fork, hack and
share!


    #syntax: javascript
    // ==UserScript==
    // @name           MetaCPAN vote
    // @namespace      http://babyl.dyndns.org/MetaCPANVote
    // @description    Re-order metacpan votes
    // @include        https://vote.metacpan.org/entries
    // @require        http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js
    // ==/UserScript==

    function sort_entries() {
        var $entries = $('.sort_entry');

        var entries = $entries.get().sort(function(a,b){
            var x = parseInt($(a).find('input.title-vote').val());
            var y = parseInt($(b).find('input.title-vote').val());

            if (isNaN(x)){ x = 999; }
            if (isNaN(y)){ y = 999; }

            return x < y ? 1 : x > y ? -1 : 0;
        });

        var $help = $('div.help');

        for( var i = 0; i < entries.length; i++ ){
            $help.after( entries[i] );
        }
    }

    // wrap those entries with their titles
    $(function(){
        $('.entry').not('.votepoll').each(function(){
            var $this = $(this);
            var $header = $this.prev();
            $header.wrap('<div class="sort_entry" />').parent().append($this);
        });
        $('.title-vote').blur(sort_entries);
    });


