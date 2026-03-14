
# ggbumpribbon

<!-- badges: start -->
[![R-CMD-check](https://github.com/sondreskarsten/ggbumpribbon/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sondreskarsten/ggbumpribbon/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Sigmoid-curved filled ribbons for rank comparison charts in ggplot2.

<img src="man/figures/README-reputation.png" width="70%" />

<details>
<summary>Code to reproduce</summary>

```r
library(ggplot2)
library(ggbumpribbon)
library(ggflags)
library(countrycode)

# countries in both top-10 lists get ribbons
both <- data.frame(
  country   = c("Switzerland","Norway","Sweden","Canada","Denmark",
                "New Zealand","Finland","Ireland","Netherlands"),
  rank_from = c(1, 2, 3, 4, 5, 6, 7, 9, 10),
  rank_to   = c(1, 3, 4, 2, 6, 7, 5, 10, 9)
)

# countries that exit/enter top-10 get grey labels only
exit_only  <- data.frame(country = "Australia", rank_from = 8)
enter_only <- data.frame(country = "Japan",     rank_to   = 8)

ov <- c("U.S."="us","UK"="gb","South Korea"="kr","Czechia"="cz","Taiwan"="tw","UAE"="ae")
iso <- function(x) ifelse(x %in% names(ov), ov[x],
  tolower(countrycode(x, "country.name", "iso2c", warn = FALSE)))

both$iso2       <- iso(both$country)
exit_only$iso2  <- iso(exit_only$country)
enter_only$iso2 <- iso(enter_only$country)

both_long <- data.frame(
  x       = rep(1:2, each = nrow(both)),
  y       = c(both$rank_from, both$rank_to),
  group   = rep(both$country, 2),
  country = rep(both$country, 2),
  iso2    = rep(both$iso2, 2)
)

lbl_l <- both_long[both_long$x == 1, ]
lbl_r <- both_long[both_long$x == 2, ]

ggplot(both_long, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon(alpha = 0.85) +
  scale_fill_gradientn(
    colours = c("#c0392b","#eb4d4b","#f0932b","#f7dc6f","#a8e063","#2ecc71"),
    guide = "none"
  ) +
  scale_y_reverse(expand = expansion(mult = c(0.04, 0.04))) +
  scale_x_continuous(limits = c(0.15, 2.85)) +
  # left labels
  geom_text(data = lbl_l, aes(x = 0.94, y = y, label = y),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 3.5) +
  geom_flag(data = lbl_l, aes(x = 0.87, y = y, country = iso2),
            inherit.aes = FALSE, size = 4.5) +
  geom_text(data = lbl_l, aes(x = 0.80, y = y, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 3.5) +
  # right labels
  geom_text(data = lbl_r, aes(x = 2.06, y = y, label = y),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 3.5) +
  geom_flag(data = lbl_r, aes(x = 2.13, y = y, country = iso2),
            inherit.aes = FALSE, size = 4.5) +
  geom_text(data = lbl_r, aes(x = 2.20, y = y, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 3.5) +
  # exit: Australia (2024 only, grey)
  geom_text(data = exit_only, aes(x = 0.94, y = rank_from, label = rank_from),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 3.5) +
  geom_flag(data = exit_only, aes(x = 0.87, y = rank_from, country = iso2),
            inherit.aes = FALSE, size = 4.5) +
  geom_text(data = exit_only, aes(x = 0.80, y = rank_from, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 3.5) +
  # enter: Japan (2025 only, grey)
  geom_text(data = enter_only, aes(x = 2.06, y = rank_to, label = rank_to),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 3.5) +
  geom_flag(data = enter_only, aes(x = 2.13, y = rank_to, country = iso2),
            inherit.aes = FALSE, size = 4.5) +
  geom_text(data = enter_only, aes(x = 2.20, y = rank_to, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 3.5) +
  annotate("text", x = 1, y = -0.2, label = "2024 Rank",
           colour = "white", size = 5, fontface = "bold") +
  annotate("text", x = 2, y = -0.2, label = "2025 Rank",
           colour = "white", size = 5, fontface = "bold") +
  labs(
    title    = "Countries with the Best Reputations",
    subtitle = "Top 10 — Reputation Lab 2024 vs 2025",
    caption  = "Source: Reputation Lab | Made with ggbumpribbon"
  ) +
  theme_bump()
```

Flags require [ggflags](https://github.com/jimjam-slam/ggflags):
`install.packages("ggflags", repos = c("https://jimjam-slam.r-universe.dev", "https://cloud.r-project.org"))`

</details>

## The gap

| Package | What it does | What it lacks |
|---------|-------------|---------------|
| **ggbump** | Sigmoid *lines* via `geom_bump()` | No filled ribbons |
| **ggforce** | Bezier *ribbons* via `geom_diagonal_wide()` | Bezier, not sigmoid curve shape |
| **ggsankey** | Sankey-style ribbon bumps | *Stacked* positioning, not rank-positioned. GitHub-only |
| **ggbumpribbon** | **Sigmoid filled ribbons at exact rank positions** | — |

## Installation

```r
# install.packages("pak")
pak::pak("sondreskarsten/ggbumpribbon")
```

## Minimal example

```r
library(ggplot2)
library(ggbumpribbon)

df <- data.frame(
  x     = rep(1:2, each = 5),
  y     = c(1, 2, 3, 4, 5, 3, 1, 5, 2, 4),
  group = rep(LETTERS[1:5], 2)
)

ggplot(df, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon(alpha = 0.85) +
  scale_fill_viridis_c(guide = "none") +
  scale_y_reverse() +
  theme_void()
```

<img src="man/figures/README-basic.png" width="60%" />

## Multi-period

Ribbons chain automatically across 3+ time points:

```r
df3 <- data.frame(
  x     = rep(1:3, each = 4),
  y     = c(1,2,3,4, 3,1,4,2, 2,4,1,3),
  group = rep(LETTERS[1:4], 3)
)

ggplot(df3, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon(alpha = 0.7) +
  scale_fill_viridis_c() +
  scale_y_reverse()
```

<img src="man/figures/README-multi.png" width="60%" />

## mtcars

```r
mt <- mtcars[1:10, ]
mt$car <- rownames(mt)

mt_long <- data.frame(
  x     = rep(1:2, each = 10),
  y     = c(rank(-mt$mpg), rank(-mt$hp)),
  group = rep(mt$car, 2)
)

ggplot(mt_long, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon() +
  scale_fill_rank(limits = c(1, 10)) +
  scale_y_reverse() +
  theme_bump()
```

<img src="man/figures/README-mtcars.png" width="60%" />

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `smooth` | `8` | Steepness of the sigmoid curve. Higher = sharper S-shape |
| `width` | `0.8` | Ribbon full width in data units |
| `n` | `100` | Interpolation points per segment |
| `alpha` | `0.85` | Ribbon transparency |

## Computed variables

`StatBumpRibbon` computes these variables accessible via `after_stat()`:

| Variable | Description |
|----------|-------------|
| `avg_y` | Mean of all y values in the group — useful for rank-based fill gradients |
| `ymin` | Lower ribbon boundary |
| `ymax` | Upper ribbon boundary |

## Note on `scale_y_reverse()`

`scale_y_reverse()` negates y values before the Stat computes `avg_y`. When using `scale_fill_gradientn()`, reverse your colour vector so green maps to the most-negative (best) values:

```r
scale_fill_gradientn(
  colours = c("#c0392b", "#f0932b", "#f7dc6f", "#a8e063", "#2ecc71"),
  guide = "none"
)
```

## Convenience functions

| Function | Description |
|----------|-------------|
| `scale_fill_rank()` | Green-yellow-red gradient scale with `guide = "none"` default |
| `theme_bump()` | Dark background theme for rank comparison infographics |

## Architecture

```
User data (x, y, group)
  → StatBumpRibbon$compute_group()
    → sigmoid_path() for upper/lower edges
    → returns data.frame(x, y, ymin, ymax, avg_y)
  → GeomRibbon renders filled polygons
```

No grid graphics code. The package is a data transformation that delegates to ggplot2's rendering pipeline.

## Dependencies

**Hard:** ggplot2 (>= 3.5.0), rlang, scales

rlang and scales are already installed as ggplot2 dependencies — zero additional installation burden.

## License

MIT
