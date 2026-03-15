# Rank-based gradient fill scale

A convenience wrapper around
[`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html)
with defaults suited to rank comparison charts (green = best, red =
worst).

## Usage

``` r
scale_fill_rank(
  colors = c("#2ecc71", "#a8e063", "#f7dc6f", "#f0932b", "#eb4d4b", "#c0392b"),
  limits = NULL,
  ...
)
```

## Arguments

- colors:

  Character vector of gradient colours. Default is a six-colour
  green-yellow-red ramp.

- limits:

  Numeric vector of length 2 giving the scale limits, or `NULL`
  (default) to compute limits from the data range.

- ...:

  Passed to
  [`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html).

## Value

A ggplot2 scale object.

## See also

[`ggplot2::scale_fill_gradientn()`](https://ggplot2.tidyverse.org/reference/scale_gradient.html),
[`geom_bump_ribbon()`](https://sondreskarsten.github.io/ggbumpribbon/reference/geom_bump_ribbon.md)

Other bump scales:
[`theme_bump()`](https://sondreskarsten.github.io/ggbumpribbon/reference/theme_bump.md)

## Examples

``` r
library(ggplot2)
df <- data.frame(
  x     = rep(1:2, each = 5),
  y     = c(1,2,3,4,5, 3,1,5,2,4),
  group = rep(LETTERS[1:5], 2)
)
ggplot(df, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon() +
  scale_fill_rank() +
  scale_y_reverse()
```
