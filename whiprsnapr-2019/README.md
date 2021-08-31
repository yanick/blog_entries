---
created: 2020-01-06
tags:
  - whiprsnapr
  - react
  - chart.js
  - untappd
---

# Taking a stroll up Ballmer's Peak

<div style="float: right; margin-left: 1em; width: 300px">
<img src="__ENTRY__/hero.jpg" width="300" style="border-radius: 10px"/>
<div style="font-size: var(--font-scale-3)">
<i>the perfect evening counter-balance to that nice, hot mug of<i> shut the f* up <i>you poured yourself earlier in the morning</i>
</div>
</div>

There's this awesome micro-brewery called
[Whiprsnapr](https://whiprsnaprbrewingco.com/) operating in my neck of the
woods. In 2019, they had this `Unfiltrd` project where they brewed one
special edition beer every week. It was magnificent.

As the year waned and the heap of cans waxed, I thought it'd be fun to
have a dashboard showing me my `Unfiltrd` scorecard; which weekly beers I
prefered, which ones I missed, that kind of stuff.

So I cracked myself a fresh can of inspiration, and dove in.

## Brewing the data

In our modern age epicurian pleasures are not complete without a side help of
social sharing. And indeed, the beer world has [Untappd](https://untappd.com).

Has luck would have it, *Untappd* offers not one but two API to access its
alcoholized knowledge base. One of them, [Uptappd for
business](https://untappd.com/business), is graphql-based and would have been
perfect for my needs but, alas, business I ain't.  The second, a more
classical [REST interface](https://untappd.com/api/), is however open
to anybody who asks nicely. 

Tantalizingly enough, the brewery endpoint of that REST interface can provide part of its beer list, but
doesn't provide any obviously documented pagination method. Huge bummer.
So I had to resort to a more generic search for the brewery name, at the
risk of getting a few false positives along the main catch:

```js
// get_whiprsnpr_beers.js

const axios = require('axios');
const { writeJson } = require('fs-extra');

const base_url = "https://api.untappd.com";
const access_token = "DEADBEEF";

fetch_all_beers().then(
  beers => writeJson( 'beers.json', beers )
);

async function fetch_all_beers() {
  const beers = [];

  let offset = 0;

  while(true) {
    const res = await axios.get( `${base_url}/v4/search/beer`, {
      params: {
        access_token,
        q: 'whiprsnapr',
        offset:  25 * (offset),
      }
    });

    offset++;

    const more_beers = res.data.response.beers.items;
    beers.push( ...more_beers );
    if( more_beers.length == 0 ) return beers;
  }
}
```

That returns 156 different beers. Nice! Ah, but the search doesn't return all
the data associated with a beer. So I have to return for a second,
beer-by-beer pass.

```perl
# get_beers_data.pl

use 5.30.0;

use File::Serialize;
use DDP;
use DateTime::Format::Flexible;
use LWP::Simple;

my @beers = map { $_->{beer} } grep {
    $_->{brewery}{brewery_id} == 55938
} @{ deserialize_file 'beers.json' }@beers;

$_->{created_at} = 
  DateTime::Format::Flexible->parse_datetime( $_->{created_at} )
    for @beers;

# only interested in 2019
@beers = grep { $_->{created_at}->year == 2019 } @beers;


for ( @beers ) {
  sleep 3;
  say $_->{beer_name};
  my $id = $_->{bid};
  mirror(
    "https://api.untappd.com/v4/beer/info/$id"
      ."?access_token=DEADBEEF&compact=true", 
    "beers/$id.json"
  );
}
```

There, the data of 55 different beers have been retrieved. A typical one looks
like:

```js
"beer": {
    "bid": 3030726,
    "beer_name": "Bells Corners Beast",
    "beer_label": "https://untappd.akamaized.net/site/assets/images/temp/badge-beer-default.png",
    "beer_label_hd": "",
    "beer_abv": 6.66,
    "beer_ibu": 66,
    "beer_description": "SMaSH IPA using Canada's first born and bred hop - Sasquatch.  3lbs hops/barrel!",
    "beer_style": "IPA - American",
    "is_in_production": 1,
    "beer_slug": "whiprsnapr-brewing-co-bells-corners-beast",
    "is_homebrew": 0,
    "created_at": "Fri, 11 Jan 2019 01:44:48 +0000",
    "rating_count": 22,
    "rating_score": 3.86364,
    "stats": {
    "total_count": 29,
    "monthly_count": 0,
    "total_user_count": 22,
    "user_count": 0
    },
}
```

Informative, but not pretty. Let's address that.

## Pouring the stats

As I'm currently cutting my teeth on all that is React, why not 
display our suddy data as a semi-mobile-friendly app? Overkill? probably.
But educationally so.

I won't bore you with the whole application. Suffice to say that it's
pretty barebone React using [Material UI](https://material-ui.com) 
as its component library (it has decent documentation, is fairly sane, and provides a decent amount of
components), and uses [Chart.js](https://www.chartjs.org/) for all the graphy
stuff.

The result so far? A wee little [app](http://beer.babyl.ca) that has two
screens. The first displays all the Whiprsnapr beers of 2019 (according to
what was retrieved from Untappd. A quick perusal makes me suspect a few beers
slipped through the net). If I was to complete the Untappd integration, it'd
be fairly easy to tailor-suit the list according to the visitor's Untappd
profile.

<div style="text-align: center; margin-bottom: 2em;">
<img src="__ENTRY__/app.png" width="80%" />
</div>


The second page is a gleeful dump of graphs. Like, if there was any doubt the
crew like their IPAs and stouts, it's now scientifically proven:

<div style="text-align: center; margin-bottom: 2em;">
<img src="__ENTRY__/styles.png" width="80%" />
</div>

Which beers won the popularity contest? Wonder no more:

<div style="text-align: center; margin-bottom: 2em;">
<img src="__ENTRY__/ratings.png" width="80%" />
</div>

Okay. Rating is one thing, but do people actually put their mouth where their
beer belly is?

<div style="text-align: center; margin-bottom: 2em;">
<img src="__ENTRY__/rates-checkins.png" width="80%" />
</div>

(that ratings vs check-ins  graph is in need of a little grooming. The beers scoring a zero (unthinkable!) are probably some that didn't get any rating. And the two
beers that have an insane amount of checkins are the Risqué, not a weekly
edition but a regular that appeared during the year, and the Jollypop! that looks like it's aggregating the 4 variations that were made on  successive weeks.)

And just for giggles: how about a plot of abv versus ibu?

<div style="text-align: center; margin-bottom: 2em;">
<img src="__ENTRY__/abv.png" width="80%" />
</div>


## For the road

I could play much more with that app. Untappd integration, more graphs, having
the existing graphs reveal more information (like, the abv vs ibu graph is nice, but it
could speak even more if the points were color-coded by beer style), etc. 
But for a first pass, it'll do.

Mind you, I'm itching for some R fun, so there might be a second pass soon...

