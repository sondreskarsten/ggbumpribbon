# Dark theme for bump charts

A minimal dark theme based on
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with a dark background and light text, suited to rank comparison
infographics.

## Usage

``` r
theme_bump(bg = "#1a1a2e", title_color = "#e74c3c", base_size = 10)
```

## Arguments

- bg:

  Background fill colour. Default `"#1a1a2e"`.

- title_color:

  Title text colour. Default `"#e74c3c"`.

- base_size:

  Base font size. Default `10`.

## Value

A ggplot2 [theme](https://ggplot2.tidyverse.org/reference/theme.html)
object.

## See also

[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html),
[`geom_bump_ribbon()`](https://sondreskarsten.github.io/ggbumpribbon/reference/geom_bump_ribbon.md)

Other bump scales:
[`scale_fill_rank()`](https://sondreskarsten.github.io/ggbumpribbon/reference/scale_fill_rank.md)

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(colour = "white") +
  labs(title = "Motor Trend Cars") +
  theme_bump()
```
