# Contributing to ggbumpribbon

## Bug reports

Open an issue at <https://github.com/sondreskarsten/ggbumpribbon/issues> with
a minimal reproducible example using built-in datasets (mtcars, iris, etc.).

## Pull requests

1. Fork and create a feature branch from `main`.
2. Follow existing code style (base R in ggproto internals, no dplyr in `R/`).
3. Add tests for new functionality in `tests/testthat/`.
4. Run `devtools::check()` — target 0 errors, 0 warnings, 0 notes.
5. Run `devtools::document()` if you change any roxygen2 comments.
6. Update `NEWS.md` with a bullet under the development version heading.

## Code organisation

| File | Contents |
|------|----------|
| `R/sigmoid.R` | Internal `sigmoid_path()` — pure math, no ggplot2 |
| `R/geom-bump-ribbon.R` | `StatBumpRibbon` ggproto + `geom_bump_ribbon()` layer |
| `R/scale-fill-rank.R` | `scale_fill_rank()` convenience wrapper |
| `R/theme-bump.R` | `theme_bump()` dark theme |
| `R/ggbumpribbon-package.R` | Package docs + `@importFrom` directives |

## Design principles

- **Stat-only architecture.** All computation happens in `StatBumpRibbon$compute_group()`.
  Rendering is delegated to `GeomRibbon`. Do not add grid graphics code unless
  absolutely necessary.
- **Minimal dependencies.** ggplot2, rlang, scales only. No dplyr, purrr, or tidyr
  in `Imports`.
- **Base R inside ggproto.** Use `data.frame()`, `do.call(rbind, ...)`, and `for`
  loops — not tibbles or `pmap_dfr()`.
