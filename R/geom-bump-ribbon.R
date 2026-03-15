#' Smooth-curved filled ribbons for rank comparison
#'
#' `geom_bump_ribbon()` renders filled ribbons that follow smooth curves
#' between discrete rank positions. It is the filled-area counterpart to
#' ggbump's `geom_bump()` (<https://github.com/davidsjoberg/ggbump>).
#'
#' @section Aesthetics:
#' `geom_bump_ribbon()` understands the following aesthetics
#' (required aesthetics are in **bold**):
#'
#' - **`x`**
#' - **`y`**
#' - `alpha`
#' - `colour`
#' - `fill`
#' - `group`
#' - `linetype`
#' - `linewidth`
#'
#' @section Computed variables:
#' \describe{
#'   \item{`ymin`}{Lower ribbon boundary.}
#'   \item{`ymax`}{Upper ribbon boundary.}
#'   \item{`avg_y`}{Mean of all y values in the group; useful for
#'     rank-based fill via `after_stat(avg_y)`.}
#' }
#'
#' @section Interpolation methods:
#'
#' When a group has 3 or more time points, adjacent segments must be
#' joined.
#'
#' \describe{
#'   \item{`"sigmoid"` (default)}{Each segment follows a logistic sigmoid
#'     \eqn{\sigma(t) = 1/(1+e^{-t})} on \eqn{t \in [-s, s]} where
#'     \eqn{s} is the `smooth` parameter. Endpoints are clamped to
#'     exact knot values by rescaling \eqn{\sigma} to \eqn{[0, 1]},
#'     and a Hermite-basis derivative correction drives the slope to
#'     zero at every interior knot, guaranteeing C1 (first-derivative)
#'     continuity across segments. The `smooth` parameter controls
#'     steepness: lower values (e.g. 2--3) give gentle S-curves, higher
#'     values (e.g. 12--15) give near-step-function transitions.}
#'   \item{`"hermite"`}{Uses [stats::splinefunH()] with zero slopes at
#'     all knots (the cubic Hermite "smoothstep"). This is
#'     mathematically simpler: a single spline is evaluated across all
#'     knots, with C1 continuity guaranteed by construction. The
#'     `smooth` parameter is ignored. The visual shape is similar to
#'     `"sigmoid"` but not identical --- the cubic polynomial
#'     \eqn{3t^2 - 2t^3} has slightly different curvature distribution
#'     than the logistic function.}
#' }
#'
#' Both methods produce identical results for 2-point groups (a single
#' segment has no join to worry about).
#'
#' @inheritParams ggplot2::geom_ribbon
#' @param smooth Steepness of the sigmoid curve. Higher values produce
#'   sharper S-shaped transitions. Only used when `method = "sigmoid"`.
#'   Default is `8`.
#' @param n Number of interpolation points per segment. Default is `100`.
#' @param width Ribbon full width in data units. Default is `0.8`.
#' @param method Interpolation method. `"sigmoid"` (default) uses
#'   logistic S-curves with C1 derivative correction at segment joins.
#'   `"hermite"` uses cubic Hermite smoothstep interpolation via
#'   [stats::splinefunH()]. See section **Interpolation methods**.
#'
#' @returns A [ggplot2 layer][ggplot2::layer()] that can be added to a plot.
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' # basic: 5 items, 2 time points
#' df <- data.frame(
#'   x     = rep(1:2, each = 5),
#'   y     = c(1, 2, 3, 4, 5, 3, 1, 5, 2, 4),
#'   group = rep(LETTERS[1:5], 2)
#' )
#' ggplot(df, aes(x, y, group = group, fill = after_stat(avg_y))) +
#'   geom_bump_ribbon() +
#'   scale_fill_viridis_c() +
#'   scale_y_reverse()
#'
#' # multi-period: 3 time points
#' df3 <- data.frame(
#'   x     = rep(1:3, each = 4),
#'   y     = c(1,2,3,4, 3,1,4,2, 2,4,1,3),
#'   group = rep(LETTERS[1:4], 3)
#' )
#' ggplot(df3, aes(x, y, group = group, fill = after_stat(avg_y))) +
#'   geom_bump_ribbon(alpha = 0.7) +
#'   scale_fill_viridis_c() +
#'   scale_y_reverse()
#'
#' # Hermite method
#' ggplot(df3, aes(x, y, group = group, fill = after_stat(avg_y))) +
#'   geom_bump_ribbon(method = "hermite", alpha = 0.7) +
#'   scale_fill_viridis_c() +
#'   scale_y_reverse()
#'
#' # mtcars: MPG rank vs HP rank
#' mt <- mtcars[1:10, ]
#' mt$car   <- rownames(mt)
#' mt_long  <- data.frame(
#'   x     = rep(1:2, each = 10),
#'   y     = c(rank(-mt$mpg), rank(-mt$hp)),
#'   group = rep(mt$car, 2)
#' )
#' ggplot(mt_long, aes(x, y, group = group, fill = after_stat(avg_y))) +
#'   geom_bump_ribbon() +
#'   scale_fill_gradientn(colours = c("#2ecc71", "#f7dc6f", "#eb4d4b"),
#'                        guide = "none") +
#'   scale_y_reverse() +
#'   theme_void()
geom_bump_ribbon <- function(mapping = NULL,
                              data = NULL,
                              position = "identity",
                              ...,
                              smooth = 8,
                              n = 100,
                              width = 0.8,
                              method = "sigmoid",
                              na.rm = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  ggplot2::layer(
    stat     = StatBumpRibbon,
    geom     = ggplot2::GeomRibbon,
    data     = data,
    mapping  = mapping,
    position = position,
    show.legend  = show.legend,
    inherit.aes  = inherit.aes,
    params = rlang::list2(
      smooth = smooth,
      n      = n,
      width  = width,
      method = method,
      na.rm  = na.rm,
      ...
    )
  )
}

#' @rdname geom_bump_ribbon
#' @format NULL
#' @usage NULL
#' @export
StatBumpRibbon <- ggproto("StatBumpRibbon", Stat,

  required_aes = c("x", "y"),

  extra_params = c("na.rm", "smooth", "n", "width", "method"),

  compute_group = function(data, scales, smooth = 8, n = 100, width = 0.8,
                           method = "sigmoid") {
    data <- data[order(data$x), ]

    if (nrow(data) < 2) return(data.frame())

    dup <- duplicated(data$x)
    if (any(dup)) data <- data[!dup, ]
    if (nrow(data) < 2) return(data.frame())

    hw    <- width / 2
    avg_y <- mean(data$y)

    upper <- smooth_path(data$x, data$y - hw, smooth = smooth, n = n,
                         method = method)
    lower <- smooth_path(data$x, data$y + hw, smooth = smooth, n = n,
                         method = method)

    out <- data.frame(
      x     = upper$x,
      y     = (upper$y + lower$y) / 2,
      ymin  = upper$y,
      ymax  = lower$y,
      avg_y = avg_y
    )

    aesthetic_cols <- setdiff(names(data), c("x", "y"))
    for (col in aesthetic_cols) {
      out[[col]] <- data[[col]][1]
    }

    out
  }
)
