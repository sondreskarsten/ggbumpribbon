#' Smooth-curved lines between rank positions
#'
#' `geom_bump_line()` renders smooth curves connecting discrete
#' rank positions across time periods. It is the line counterpart to
#' [geom_bump_ribbon()], producing stroked paths instead of filled areas.
#'
#' @section Aesthetics:
#' `geom_bump_line()` understands the following aesthetics
#' (required aesthetics are in **bold**):
#'
#' - **`x`**
#' - **`y`**
#' - `alpha`
#' - `colour`
#' - `group`
#' - `linetype`
#' - `linewidth`
#'
#' @section Computed variables:
#' \describe{
#'   \item{`avg_y`}{Mean of y values in the group, inverse-transformed to
#'     original data space. Works correctly with `scale_y_reverse()`.
#'     Map to colour via `after_stat(avg_y)`.}
#' }
#'
#' @section Multi-bend curves:
#' The number of bends is controlled by the data, not by parameters.
#' Two x-values produce one sigmoid. Four x-values (with the two middle
#' points holding the start/end y positions) produce three sigmoids that
#' mimic the "exit–channel–enter" pattern common in infographics:
#'
#' ```
#' df <- data.frame(
#'   x     = rep(c(1, 1.4, 1.6, 2), each = 5),
#'   y     = c(from, from, to, to),
#'   group = rep(groups, 4)
#' )
#' ```
#'
#' @inheritParams ggplot2::geom_path
#' @param smooth Steepness of the sigmoid curve. Higher values produce
#'   sharper S-shaped transitions. Only used when `method = "sigmoid"`.
#'   Default is `8`.
#' @param n Number of interpolation points per segment. Default is `100`.
#' @param method Interpolation method. `"sigmoid"` (default) uses
#'   logistic S-curves with C1 derivative correction at segment joins.
#'   `"hermite"` uses cubic Hermite smoothstep interpolation via
#'   [stats::splinefunH()]. See [geom_bump_ribbon()] for details.
#'
#' @returns A [ggplot2 layer][ggplot2::layer()] that can be added to a plot.
#' @family bump geoms
#' @seealso [geom_bump_ribbon()], [ggplot2::geom_path()]
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' # basic 2-point line bump
#' df <- data.frame(
#'   x     = rep(1:2, each = 5),
#'   y     = c(1, 2, 3, 4, 5, 3, 1, 5, 2, 4),
#'   group = rep(LETTERS[1:5], 2)
#' )
#' ggplot(df, aes(x, y, group = group, colour = after_stat(avg_y))) +
#'   geom_bump_line(linewidth = 1) +
#'   scale_colour_viridis_c() +
#'   scale_y_reverse()
#'
#' # 3-bend pattern (exit-channel-enter)
#' df3 <- data.frame(
#'   x     = rep(c(1, 1.4, 1.6, 2), each = 5),
#'   y     = c(1,2,3,4,5, 1,2,3,4,5, 3,1,5,2,4, 3,1,5,2,4),
#'   group = rep(LETTERS[1:5], 4)
#' )
#' ggplot(df3, aes(x, y, group = group, colour = after_stat(avg_y))) +
#'   geom_bump_line(linewidth = 1.2) +
#'   scale_colour_viridis_c() +
#'   scale_y_reverse()
geom_bump_line <- function(mapping = NULL,
                            data = NULL,
                            position = "identity",
                            ...,
                            smooth = 8,
                            n = 100,
                            method = "sigmoid",
                            na.rm = FALSE,
                            show.legend = NA,
                            inherit.aes = TRUE) {
  ggplot2::layer(
    stat     = StatBumpLine,
    geom     = ggplot2::GeomPath,
    data     = data,
    mapping  = mapping,
    position = position,
    show.legend  = show.legend,
    inherit.aes  = inherit.aes,
    params = rlang::list2(
      smooth = smooth,
      n      = n,
      method = method,
      na.rm  = na.rm,
      ...
    )
  )
}

#' @rdname ggbumpribbon-ggproto
#' @format NULL
#' @usage NULL
#' @export
StatBumpLine <- ggproto("StatBumpLine", Stat,

  required_aes = c("x", "y"),

  extra_params = c("na.rm", "smooth", "n", "method"),

  compute_group = function(data, scales, smooth = 8, n = 100,
                           method = "sigmoid") {
    if (!is.numeric(n) || length(n) != 1L || n < 2) {
      cli_abort("{.arg n} must be a single integer >= 2, not {.val {n}}.")
    }

    data <- data[order(data$x), ]

    if (nrow(data) < 2) return(data.frame())

    dup <- duplicated(data$x)
    if (any(dup)) data <- data[!dup, ]
    if (nrow(data) < 2) return(data.frame())

    mean_y <- mean(data$y)
    avg_y  <- if (!is.null(scales$y) && !is.null(scales$y$trans)) {
      scales$y$trans$inverse(mean_y)
    } else {
      mean_y
    }

    path <- smooth_path(data$x, data$y, smooth = smooth, n = n,
                        method = method)
    path$avg_y <- avg_y

    aesthetic_cols <- setdiff(names(data), c("x", "y"))
    for (col in aesthetic_cols) {
      path[[col]] <- data[[col]][1]
    }

    path
  }
)
