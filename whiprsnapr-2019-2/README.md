---
created: 2020-01-20
tags:
    - R
    - whiprsnapr
---

# Whiprsnapr 2019, part II


If you are a normal person, all you need to know is that I was feeling cute
and wanted to practice my nascent [R](https://www.r-project.org/) skills. So I reprised and
extended the data analysis [I did last time](/entry/whiprsnapr-2019) on the [Whiprsnapr](https://whiprsnaprbrewingco.com/) beers.
The resulting report is [here](./report.html).

If you are a data nerd, read on.

## Quick thoughts on R

While I don't have anything earth-shattering to reveal, I thought that since we're already here, I'll take the occasion to briefly yammer about 
my experience with `R`.

`R` is one of those languages optimized at data analysis. Sounds
nice! But how does the language feels? Easy to learn? Fun to use?
And how does it compares with more general-usage languages
like Perl and JavaScript? 

### The language itself

R's syntax is... definitively peculiar. And coming from someone calling himself a
necrohacker, that's saying something.

Not that it's unexpected. R's roots are old and come from the Stygian depths of
academia. And its community went through
several
iterations of best practices and came up with libraries that
twist and overload the original languages in new ways
to accommodate them (hmmm... sounds oddly familiar, somehow...). It means that, for example,
depending what you're reading, one of the basic variable type will
be a `data.frame`, or a `tibble`.

It doesn't help that most of the books and blog entries out there are more likely to give recipes
on how to achieve things, rather than explain how the language is parsed. By
now I know how to write statements like

```r
beers 
  %>% filter( beer_ibu != 0 ) 
  %>% ggplot() 
    + geom_point(
        aes(y=beer_abv,x=beer_ibu,color=style),
        show.legend = FALSE ) 
    + facet_wrap(~style) 
    + labs(
      x="ibu",
      y="abv",
      title="abv vs ibu, by style" )
```

Even better, I kind of know what it means! `%>%` is a kind of curried
operator, the `+` is an overloaded operator to add bits to the original
`ggplot()` graph, and something prefixed with `~` is a formula. What exactly
*is* a formula in the context of R? The [language
specs](https://cran.r-project.org/doc/manuals/r-devel/R-lang.html) are a little vague
about it, but some
[tutorials](https://www.datacamp.com/community/tutorials/r-formula-tutorial)
provides helpful hints as to the nature of that strange animal.

Oh yeah, and there is also a lot of closures and localized variables business
going on. And the
naming of things can be less than explicit. I'm looking at you, package
named `DT`, for *data table*.

What I'm trying to say is that, eventually, the language will make sense. But 
until it does, a lot of Faith-based cut'n'pasting might need to be done.



### Data munging

Raw data is invariably a mess that needs to be tidied. R has all 
the regular filtering/munging tools that one might need for those clean-ups.
And to be fair they are not wildly superior than the ones that a "regular"
language would provide. Indeed, a few of the books I've read openly advocate
doing the first wave of cleaning with Python/Perl/whatev scripts so that once 
the data enters R space, only minor tweaks are required.

In any case, for giggles, here's part of the munging I did on
the raw Untappd data, first in R:

```r
beers <- fromJSON('beers.json', flatten=TRUE) 
    %>% as.tibble
    %>% mutate( 
        style  = factor(str_replace(beer_style, "\\s*-.*", "") ),
        rating = round(rating_score,1)),
        week   = created_at %>% as.Date(format="%a, %d %b %Y %H:%M:%S %z") %>% format("%U")),
        url    = paste( "<a href='","https://untappd.com/b/",beer_slug,"/",bid,"'>", beer_name, "</a>",sep="" )
    )
    %>% select(-starts_with('vintages'),-starts_with("brew"),-beer_active,-is_homebrew,-wish_list)
```

And here in roughly equivalent Perl:


```perl
my $beers = file_deserialize 'beers.json';

for ( @$beer) {
    $_->{style}  = $_->{beer_style} =~ s/\s*-.*//r;
    $_->{rating} = int $_->{rating_score};
    $_->{week}   = parse_date($_->{created_at})->year_week;
    $_->{url}    = sprintf "<a href='https://untappd.com/b/%s/%s'>a%s</a>", 
                           $_->{beer_slug}, $_->{bid}, $_->{beer_name};
    delete $_->%[qw/ vintage brewery beer_active is_homebrew wish_list /];
}
```

Not so different. From what I've experience so far, so simple mappings and
filterings, the R version looks nicer, but as soon as string manipulations
enter the picture, well it's time to say hello to my old friend.


### Statistical analysis

This is R forté. The language is loaded with ways to create ANOVA models,
regressions, and all that good statistical stuff out of data. But I alas didn't
play with it for this mini-project and thus can't speak of it. But yeah, I
totally assume that if that's one of the things for which R shine at its
brightest.


### Graphs

Like data munging, R has some nice shorthands. For only one graph,
the difference might  not be that impressive. For example this
[Chart.js](https://www.chartjs.org/) graph

```js
const data = {
    labels: fp.map( 'beer_name' )(beers),
    datasets: [ {
        label: 'rating', data: fp.map( 'rating_score', beers ),
    } ],
};

const chart = new Chart( { data })

```

is roughly the equivalent of

```r
beers %>% ggplot() + geom_point(aes(x=beer_name,y=rating))
```

But it becomes ludicrously awesome when we're going down hog-wild territory.
Like, how about splintering that rating graph per style, which each point on
the graph sized by the count of checkins, and its color varying with the
beer's ibu? And with a regression line thrown in. Because why not?

```r
beers %>% ggplot()
  + geom_point( 
    aes( x=beer_name, y=rating, color=ibu, size=stats.totat_count )) 
  + geom_facet(~style) 
  + geom_smooth(aes(x=beer_name,y=rating))
```


Now, try to do the same thing with `Chart.js`. I'll be waiting. It's not that it'd be hard, mind you, 
but it'd be brain-numbingly tedious and verbose.

### REPL'ing and report generation  

Now, this is were R **shreds**. 

The main thing with data exploration is that you want
the shortest feedback loop possible between "I wonder what a graph
of this against that, minus thus observations looks like" and "Hey peeps! Take
a gander at that funky relationship!". And the R environment -- either
you use the cli REPL, [RStudio](https://rstudio.com/) or even the [neovim
interface](https://github.com/jalvesaq/Nvim-R) -- provides
real-time *munge'n'graphing* in spades.

And to grease the reporting pipeline even slickier, R code can trivially 
be wrapped in Markdown to generate -- and trivially regenerate when the data
change -- eye-pleasing documents.


## In summary

R is quaint and niche. It might not do anything beyond what can be done with a
regular JavaScript/Perl/Python/etc program. But it'll do it in a much more
succinct, interactive way. If you want only to plot a quick graph, it's
not worth the learning overhead. But if you entertain taking a serious
stroll in data jungles, then it may be a tool worth adding to your collection.

