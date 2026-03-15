# Changelog

## ggbumpribbon 0.2.0

### Breaking changes

- Row counts for multi-segment groups changed. The old per-segment
  sigmoid architecture produced `n * (k-1) - (k-2)` rows for `k` knots.
  The sigmoid method now produces `n * (k-1) - (k-2)` rows (identical),
  and the hermite method produces `n * (k-1) + 1` rows. Code that
  depended on exact row counts may need updating.

### Bug fixes

- **Fixed segment-join discontinuity in multi-period ribbons**
  ([\#1](https://github.com/sondreskarsten/ggbumpribbon/issues/1)). When
  a group had 3+ time points, the v0.1.0 architecture computed each
  sigmoid segment independently and concatenated them, producing two
  artefacts at every interior knot:

  1.  **Positional gap (C0 discontinuity):** The logistic sigmoid σ(t)
      on t ∈ \[−s, s\] never reaches exactly 0 or 1, so adjacent
      segments did not share the same y-value at their join. For
      `smooth = 8` the gap was ~0.00057 data units per join — sub-pixel
      in most cases but present.

  2.  **Derivative kink (C1 discontinuity):** Each segment’s slope at
      its endpoint is σ′(±s) · Δy / Δx, which depends on the segment’s
      y-range. At a direction reversal (e.g. rank goes 1→5→2), the
      outgoing slope of segment k and the incoming slope of segment k+1
      differ, producing a visible corner. This was the artefact reported
      in the screenshot.

  Both are now fixed. See `method` parameter below.

- Duplicate x-values within a group are now silently deduplicated
  (keeping the first occurrence) instead of producing degenerate
  zero-width sigmoid segments.

- **`smooth <= 0` no longer crashes** the sigmoid method. Previously,
  `smooth = 0` caused a division-by-zero (σ(0) − σ(−0) = 0) producing
  NaN output. Now `smooth <= 0` falls back to linear interpolation via
  [`stats::approxfun()`](https://rdrr.io/r/stats/approxfun.html),
  following base R’s pattern where degenerate parameters yield the
  limiting case rather than an error.

- **`width < 0` no longer produces invisible ribbons.** Negative width
  is now treated as positive (`abs(width)`), consistent with how
  ggplot2’s own geoms handle negative size parameters. Previously,
  negative width inverted `ymin`/`ymax`, causing `GeomRibbon` to render
  nothing silently.

- **`n < 2` now errors with an informative message** via
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
  following the ggplot2 convention for parameter validation in
  `compute_group`. Previously, `n = 0` crashed with an opaque
  `"arguments imply differing number of rows"` error, and `n = 1`
  produced a single-point degenerate output.

- **[`scale_fill_rank()`](https://sondreskarsten.github.io/ggbumpribbon/reference/scale_fill_rank.md)
  now defaults to `limits = NULL`** (auto-range from data) instead of
  `limits = c(1, 60)`. The previous default meant that any dataset with
  fewer than ~30 groups would show nearly monochromatic fills, because
  all `avg_y` values mapped to the green end of the gradient. Users who
  need explicit limits can still pass `limits = c(1, 60)` or any other
  range.

### New features

- New `method` parameter for
  [`geom_bump_ribbon()`](https://sondreskarsten.github.io/ggbumpribbon/reference/geom_bump_ribbon.md)
  with two options:

  - **`"sigmoid"`** (default): preserves the logistic S-curve visual
    character. Each segment is a clamped sigmoid (rescaled so endpoints
    map to exact knot values), with a Hermite-basis derivative
    correction that drives the slope to zero at every interior knot.
    This eliminates both the positional gap and the derivative kink
    while keeping the sigmoid shape and honouring the `smooth`
    parameter.

  - **`"hermite"`**: uses
    [`stats::splinefunH()`](https://rdrr.io/r/stats/splinefun.html) with
    zero slopes at all knots. A single spline is evaluated across all
    knots in one pass, with C1 continuity guaranteed by construction.
    The `smooth` parameter is ignored. Visually similar (the cubic
    smoothstep 3t² − 2t³ closely approximates the logistic function) but
    not identical.

- The `smooth` parameter now works correctly with the `"sigmoid"` method
  across all values including previously broken edge cases (`smooth = 0`
  produced constant output, negative values reversed the curve).

### Internal changes

- New internal functions `smooth_path()`, `smooth_path_sigmoid()`, and
  `smooth_path_hermite()` in `R/sigmoid.R`. The original
  `sigmoid_path()` is retained for backward compatibility but is no
  longer called by `StatBumpRibbon`.

- Removed unused `importFrom(rlang, .data)` from NAMESPACE.

- Added `cli` to Imports for
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  parameter validation, following the ggplot2 convention. Zero marginal
  dependency cost since `cli` is already a transitive dependency of
  ggplot2.

- Test suite expanded from 22 to 50 tests, covering both methods,
  segment-join accuracy, duplicate-x handling, smooth parameter effect,
  input validation (n, width, smooth), and scale_fill_rank auto-range.

## ggbumpribbon 0.1.0

- Initial release.
- [`geom_bump_ribbon()`](https://sondreskarsten.github.io/ggbumpribbon/reference/geom_bump_ribbon.md)
  — sigmoid-curved filled ribbons between rank positions.
- [`geom_bump_line()`](https://sondreskarsten.github.io/ggbumpribbon/reference/geom_bump_line.md)
  — sigmoid-curved lines between rank positions.
- `StatBumpRibbon` / `StatBumpLine` — custom Stats computing logistic
  sigmoid paths.
- [`scale_fill_rank()`](https://sondreskarsten.github.io/ggbumpribbon/reference/scale_fill_rank.md)
  — convenience green-yellow-red gradient scale.
- [`theme_bump()`](https://sondreskarsten.github.io/ggbumpribbon/reference/theme_bump.md)
  — dark theme for rank comparison infographics.
- Multi-segment support (3+ time points chain automatically).
- 3-bend “exit–channel–enter” pattern via 4 x-values per group.
- `after_stat(avg_y)` for rank-based gradient fills/colours.
- `avg_y` inverse-transforms through `scales$y$trans$inverse()` so
  [`scale_y_reverse()`](https://ggplot2.tidyverse.org/reference/scale_continuous.html)
  works transparently with fill/colour mapping.
