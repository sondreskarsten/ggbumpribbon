# ggbumpribbon 0.1.0

* Initial release.
* `geom_bump_ribbon()` — sigmoid-curved filled ribbons between rank positions.
* `geom_bump_line()` — sigmoid-curved lines between rank positions.
* `StatBumpRibbon` / `StatBumpLine` — custom Stats computing logistic sigmoid paths.
* `scale_fill_rank()` — convenience green-yellow-red gradient scale.
* `theme_bump()` — dark theme for rank comparison infographics.
* Multi-segment support (3+ time points chain automatically).
* 3-bend "exit–channel–enter" pattern via 4 x-values per group.
* `after_stat(avg_y)` for rank-based gradient fills/colours.
* `avg_y` inverse-transforms through `scales$y$trans$inverse()` so
  `scale_y_reverse()` works transparently with fill/colour mapping.
