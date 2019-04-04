---
title: Webpage Timezone Hopping
url: time-hopping
format: markdown
created: 20 Oct 2012
tags:
    - Javascript
---

Timezones can be darn confusing. Personally, daylight saving is enough to
throw me into bi-annual bouts of confusion. So when I deal with information on
a web site posted by someone in a different timezone, talking about events
happening in yet another timezone, it usually doesn't take very long before my
head begins to swim. Of course, the typical way to get around those timezonish
shenanigans is to display all times relative to UTC... which usally means
that a fourth timezone is thrown in the mix. Madness.

So I thought, wouldn't be nice to be able to switch the times back and forth
on a webpage, such that you don't have to juggle the time differences in your
head, but rather just see the full thing first from your timezone perspective,
then from the other guy's?

## On Your Mark(up)

First thing that we want to do is to mark the times and dates on the page so
that we'll be able to manipulate them.

    #syntax: xml
    <p>We shall meet at <span class="datetime" timezone="Etc/UTC">2012/10/20 12:34</span> at the
    docks. We strike at <span class="datetime">2012/10/20 14:56</span>.</p>

And because the information is already there, let's add a css rule to display
it:

    #syntax: xml
    <style>
        span.datetime:after {
            content: " (" attr(timezone) ")";
        } 
    </style>

## Get(), Set()

Now comes the hard part. We want to move times from one timezone to another.
And it'd be cool to automatically recognize in which timezone the current user
is, to provide a sensible default to our display. Trying to rewrite that from
scratch would be silly, instead, let's use
[timezone-js](https://github.com/mde/timezone-js) for the timezone
manipulations and
[jstimezonedetect](https://bitbucket.org/pellepim/jstimezonedetect)
for the detection. On, by the by, for the following code to work, I had to
slightly tweak `timezone-js`. My version of the code is [here](__ENTRY_DIR__/timezone-js/src/date.js).


With those two libraries as our base, we have left to do is to provide the
glue:

    #syntax: javascript
    function changeTimes() {
        var new_tz = $('select#timezone').val();

        $('.datetime').each(function(){
            var t = $(this);
            var tz = t.attr('timezone') || 'Etc/UTC';
            var dt = new timezoneJS.Date(t.text(), tz);
            dt.setTimezone(new_tz);
            t.attr('timezone',new_tz);
            t.text(dt.toString());
        });
    }

    $(function(){
        timezoneJS.timezone.zoneFileBasePath = '/time/tz';
        timezoneJS.timezone.init();

        $('select#timezone').val(jstz.determine().name()).change( changeTimes );

        changeTimes();
    });

and provide the choice to the user.

    #syntax: html
    <form>
        <select id="timezone" >
            <option selected="selected">Etc/UTC</option>
            <option>America/Montreal</option>
            <option>America/New_York</option>
            <option>Asia/Tokyo</option>
        </select>
    </form>

## Go!

Et voilà. A bare-bone example can be played with
[here](http://babyl.ca/misc/timelord). It's not the prettiest thing yet, but
it's perfectly functional.

