#' Sigmoid-curved lines between rank positions
#'
#' `geom_bump_line()` renders smooth sigmoid curves connecting discrete
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
#'   sharper S-shaped transitions. Default is `8`.
#' @param n Number of interpolation points per segment. Default is `100`.
#'
#' @returns A [ggplot2 layer][ggplot2::layer()] that can be added to a plot.
#' @family bump geoms
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
      na.rm  = na.rm,
      ...
    )
  )
}

#' @rdname geom_bump_line
#' @format NULL
#' @usage NULL
#' @export
StatBumpLine <- ggproto("StatBumpLine", Stat,

  required_aes = c("x", "y"),

  extra_params = c("na.rm", "smooth", "n"),

  compute_group = function(data, scales, smooth = 8, n = 100) {
    data <- data[order(data$x), ]

    if (nrow(data) < 2) return(data.frame())

    mean_y <- mean(data$y)
    avg_y  <- if (!is.null(scales$y) && !is.null(scales$y$trans)) {
      scales$y$trans$inverse(mean_y)
    } else {
      mean_y
    }

    segs  <- nrow(data) - 1
    parts <- vector("list", segs)

    for (i in seq_len(segs)) {
      seg <- sigmoid_path(data$x[i], data$x[i + 1],
                          data$y[i], data$y[i + 1],
                          smooth, n)
      seg$avg_y <- avg_y
      if (i < segs) seg <- seg[-n, ]
      parts[[i]] <- seg
    }

    out <- do.call(rbind, parts)

    aesthetic_cols <- setdiff(names(data), c("x", "y"))
    for (col in aesthetic_cols) {
      out[[col]] <- data[[col]][1]
    }

    out
  }
)
