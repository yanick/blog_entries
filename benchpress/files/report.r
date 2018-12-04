---
title: Text::Xslate benchmarks
output: html_document
---

```{r, include=FALSE}
library('jsonlite')
library('tidyverse')
library('knitr')
library('ggplot2')
```

```{r,include=FALSE}

data <- stream_in(file("benchmarks.json"), flatten=TRUE)

data <- data %>% mutate( fullname = paste( suite, name, sep='::' ) )

data$xslate_version <- ifelse( !is.na(data$xslate_version),
    data$xslate_version,
    data$'Text::Xslate'
)

report <- data %>% select( fullname, results.runtime.mean, xslate_version ) %>%
    drop_na() %>%
    rename(runtime=results.runtime.mean)  %>% arrange(xslate_version) %>%
    mutate( percent_diff = 100 * ( lag(runtime) - runtime ) / lag(runtime)  )
```

```{r,echo=FALSE}

ggplot(report, aes(x=xslate_version, y=runtime)) + geom_boxplot() + facet_grid(~fullname)
```

```{r,results='asis',echo=FALSE}

report <- report[ c( "fullname", "xslate_version", "runtime" ) ]
for ( benchmark in unique(report$fullname) ) {
    subrep <- report %>% filter( fullname == benchmark ) %>%
        select( -c( fullname ) ) %>%
        mutate( percent_diff = 100 * ( lag(runtime) - runtime ) / lag(runtime)  )
    print( knitr::kable( subrep, caption = benchmark  ) )
}
```
