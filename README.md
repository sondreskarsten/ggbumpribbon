
# ggbumpribbon

<!-- badges: start -->
[![R-CMD-check](https://github.com/sondreskarsten/ggbumpribbon/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/sondreskarsten/ggbumpribbon/actions/workflows/R-CMD-check.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Sigmoid-curved filled ribbons for rank comparison charts in ggplot2.

<a href="https://raw.githubusercontent.com/sondreskarsten/ggbumpribbon/main/man/figures/README-reputation.png"><img src="man/figures/README-reputation.png" width="55%" /></a>

<details>
<summary>Code to reproduce</summary>

```r
library(ggplot2)
library(ggbumpribbon)
library(ggflags)
library(countrycode)

ranks <- data.frame(stringsAsFactors = FALSE,
  country   = c("Switzerland","Norway","Sweden","Canada","Denmark","New Zealand","Finland",
                "Australia","Ireland","Netherlands","Austria","Japan","Spain","Italy","Belgium",
                "Portugal","Greece","UK","Singapore","France","Germany","Czechia","Thailand",
                "Poland","South Korea","Malaysia","Indonesia","Peru","Brazil","U.S.","Ukraine",
                "Philippines","Morocco","Chile","Hungary","Argentina","Vietnam","Egypt","UAE",
                "South Africa","Mexico","Romania","India","Turkey","Qatar","Algeria","Ethiopia",
                "Colombia","Kazakhstan","Nigeria","Bangladesh","Israel","Saudi Arabia","Pakistan",
                "China","Iran","Iraq","Russia"),
  rank_from = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,
                29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,51,47,49,50,52,53,54,55,56,
                57,58,59,60),
  rank_to   = c(1,3,4,2,6,7,5,11,10,9,12,8,14,13,17,15,16,18,19,21,20,25,24,23,31,29,34,27,
                28,48,26,33,30,35,32,38,37,36,40,42,39,41,45,43,44,46,51,50,49,52,54,55,53,56,
                57,59,58,60)
)

# countries only in one year get grey labels, no ribbon
exit_only  <- data.frame(country = c("Cuba","Venezuela"),  rank_from = c(46,48), stringsAsFactors = FALSE)
enter_only <- data.frame(country = c("Taiwan","Kuwait"),   rank_to   = c(22,47), stringsAsFactors = FALSE)

ov <- c("U.S."="us","UK"="gb","South Korea"="kr","Czechia"="cz","Taiwan"="tw","UAE"="ae")
iso <- function(x) ifelse(x %in% names(ov), ov[x],
  tolower(countrycode(x, "country.name", "iso2c", warn = FALSE)))

ranks$iso2      <- iso(ranks$country)
exit_only$iso2  <- iso(exit_only$country)
enter_only$iso2 <- iso(enter_only$country)

ranks_long <- data.frame(
  x       = rep(1:2, each = nrow(ranks)),
  y       = c(ranks$rank_from, ranks$rank_to),
  group   = rep(ranks$country, 2),
  country = rep(ranks$country, 2),
  iso2    = rep(ranks$iso2, 2)
)

lbl_l <- ranks_long[ranks_long$x == 1, ]
lbl_r <- ranks_long[ranks_long$x == 2, ]

ggplot(ranks_long, aes(x, y, group = group, fill = after_stat(avg_y))) +
  geom_bump_ribbon(alpha = 0.85, width = 0.8) +
  scale_fill_gradientn(
    colours = c("#2ecc71","#a8e063","#f7dc6f","#f0932b","#eb4d4b","#c0392b"),
    guide = "none"
  ) +
  scale_y_reverse(expand = expansion(mult = c(0.015, 0.015))) +
  scale_x_continuous(limits = c(0.15, 2.85)) +
  # left labels
  geom_text(data = lbl_l, aes(x = 0.94, y = y, label = y),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 2.2) +
  geom_flag(data = lbl_l, aes(x = 0.88, y = y, country = iso2),
            inherit.aes = FALSE, size = 3) +
  geom_text(data = lbl_l, aes(x = 0.82, y = y, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 2.2) +
  # right labels
  geom_text(data = lbl_r, aes(x = 2.06, y = y, label = y),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 2.2) +
  geom_flag(data = lbl_r, aes(x = 2.12, y = y, country = iso2),
            inherit.aes = FALSE, size = 3) +
  geom_text(data = lbl_r, aes(x = 2.18, y = y, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 2.2) +
  # exit only (grey, left)
  geom_text(data = exit_only, aes(x = 0.94, y = rank_from, label = rank_from),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 2.2) +
  geom_flag(data = exit_only, aes(x = 0.88, y = rank_from, country = iso2),
            inherit.aes = FALSE, size = 3) +
  geom_text(data = exit_only, aes(x = 0.82, y = rank_from, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 2.2) +
  # enter only (grey, right)
  geom_text(data = enter_only, aes(x = 2.06, y = rank_to, label = rank_to),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 2.2) +
  geom_flag(data = enter_only, aes(x = 2.12, y = rank_to, country = iso2),
            inherit.aes = FALSE, size = 3) +
  geom_text(data = enter_only, aes(x = 2.18, y = rank_to, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 2.2) +
  annotate("text", x = 1, y = -1.5, label = "2024 Rank",
           colour = "white", size = 4.5, fontface = "bold") +
  annotate("text", x = 2, y = -1.5, label = "2025 Rank",
           colour = "white", size = 4.5, fontface = "bold") +
  labs(
    title    = "COUNTRIES WITH THE BEST REPUTATIONS IN 2025",
    subtitle = "Reputation Lab ranked the reputations of 60 leading economies\nin 2025, shedding light on their international standing.",
    caption  = "Source: Reputation Lab | Made with ggbumpribbon"
  ) +
  theme_bump()
```

Flags require [ggflags](https://github.com/jimjam-slam/ggflags):
`install.packages("ggflags", repos = c("https://jimjam-slam.r-universe.dev", "https://cloud.r-project.org"))`

</details>

### `geom_bump_line()` — Top 20 Economies 1980 vs 2025

<a href="https://raw.githubusercontent.com/sondreskarsten/ggbumpribbon/main/man/figures/README-gdp.png"><img src="man/figures/README-gdp.png" width="55%" /></a>

<details>
<summary>Code to reproduce</summary>

```r
library(ggplot2)
library(ggbumpribbon)
library(ggflags)
library(countrycode)

# countries in both top-20 lists get lines
both <- data.frame(stringsAsFactors = FALSE,
  country   = c("U.S.","Japan","Germany","France","UK","Italy","China","Canada",
                "Mexico","Spain","Netherlands","India","Saudi Arabia","Australia","Brazil"),
  rank_from = c(1,2,3,4,5,6,7,8,9,11,12,13,14,15,16),
  rank_to   = c(1,4,3,7,6,8,2,10,13,12,18,5,19,15,11)
)

exit_only <- data.frame(stringsAsFactors = FALSE,
  country   = c("Argentina","Sweden","Belgium","Switzerland","Iran"),
  rank_from = c(10, 17, 18, 19, 20))

enter_only <- data.frame(stringsAsFactors = FALSE,
  country   = c("Russia","S. Korea","Türkiye","Indonesia","Poland"),
  rank_to   = c(9, 14, 16, 17, 20))

ov <- c("U.S."="us","UK"="gb","S. Korea"="kr","Türkiye"="tr","UAE"="ae")
iso <- function(x) ifelse(x %in% names(ov), ov[x],
  tolower(countrycode(x, "country.name", "iso2c", warn = FALSE)))

both$iso2       <- iso(both$country)
exit_only$iso2  <- iso(exit_only$country)
enter_only$iso2 <- iso(enter_only$country)

# 4 x-values per group → 3-bend "exit–channel–enter" pattern
both_long <- data.frame(
  x       = rep(c(1, 1.35, 1.65, 2), each = nrow(both)),
  y       = c(both$rank_from, both$rank_from, both$rank_to, both$rank_to),
  group   = rep(both$country, 4),
  country = rep(both$country, 4),
  iso2    = rep(both$iso2, 4)
)

lbl_l <- both_long[both_long$x == 1, ]
lbl_r <- both_long[both_long$x == 2, ]

ggplot(both_long, aes(x, y, group = group, colour = after_stat(avg_y))) +
  geom_bump_line(linewidth = 0.8, smooth = 10) +
  scale_colour_viridis_c(option = "C", direction = -1, guide = "none") +
  scale_y_reverse(expand = expansion(mult = c(0.03, 0.03))) +
  scale_x_continuous(limits = c(0.15, 2.85)) +
  # left labels
  geom_text(data = lbl_l, aes(x = 0.94, y = y, label = y),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 2.8) +
  geom_flag(data = lbl_l, aes(x = 0.88, y = y, country = iso2),
            inherit.aes = FALSE, size = 3.5) +
  geom_text(data = lbl_l, aes(x = 0.82, y = y, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "white", size = 2.8) +
  # right labels
  geom_text(data = lbl_r, aes(x = 2.06, y = y, label = y),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 2.8) +
  geom_flag(data = lbl_r, aes(x = 2.12, y = y, country = iso2),
            inherit.aes = FALSE, size = 3.5) +
  geom_text(data = lbl_r, aes(x = 2.18, y = y, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "white", size = 2.8) +
  # exit only (grey left)
  geom_text(data = exit_only, aes(x = 0.94, y = rank_from, label = rank_from),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 2.8) +
  geom_flag(data = exit_only, aes(x = 0.88, y = rank_from, country = iso2),
            inherit.aes = FALSE, size = 3.5) +
  geom_text(data = exit_only, aes(x = 0.82, y = rank_from, label = country),
            inherit.aes = FALSE, hjust = 1, colour = "grey55", size = 2.8) +
  # enter only (grey right)
  geom_text(data = enter_only, aes(x = 2.06, y = rank_to, label = rank_to),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 2.8) +
  geom_flag(data = enter_only, aes(x = 2.12, y = rank_to, country = iso2),
            inherit.aes = FALSE, size = 3.5) +
  geom_text(data = enter_only, aes(x = 2.18, y = rank_to, label = country),
            inherit.aes = FALSE, hjust = 0, colour = "grey55", size = 2.8) +
  annotate("text", x = 1, y = -0.5, label = "1980",
           colour = "white", size = 5, fontface = "bold") +
  annotate("text", x = 2, y = -0.5, label = "2025",
           colour = "white", size = 5, fontface = "bold") +
  labs(
    title    = "TOP 20 ECONOMIES",
    subtitle = "GDP by country — 1980 vs 2025",
    caption  = "Source: IMF, World Economic Outlook | Made with ggbumpribbon"
  ) +
  theme_bump(bg = "#0d1b3e")
```

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

| Variable | Description |
|----------|-------------|
| `avg_y` | Mean of all y values in the group — useful for rank-based fill via `after_stat(avg_y)` |
| `ymin` | Lower ribbon boundary |
| `ymax` | Upper ribbon boundary |

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

## Dependencies

**Hard:** ggplot2 (>= 3.5.0), rlang, scales — rlang and scales are already ggplot2 dependencies.

## License

MIT
