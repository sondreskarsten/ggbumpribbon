#' Sigmoid-curved filled ribbons for rank comparison
#'
#' `geom_bump_ribbon()` renders filled ribbons that follow sigmoid curves
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
#'   \item{`avg_y`}{Mean of y values in the group, inverse-transformed to
#'     original data space. Works correctly with `scale_y_reverse()` and
#'     other scale transforms. Map to fill via `after_stat(avg_y)`.}
#' }
#'
#' @inheritParams ggplot2::geom_ribbon
#' @param smooth Steepness of the sigmoid curve. Higher values produce
#'   sharper S-shaped transitions. Default is `8`.
#' @param n Number of interpolation points per segment. Default is `100`.
#' @param width Ribbon full width in data units. Default is `0.8`.
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

  extra_params = c("na.rm", "smooth", "n", "width"),

  compute_group = function(data, scales, smooth = 8, n = 100, width = 0.8) {
    data <- data[order(data$x), ]

    if (nrow(data) < 2) return(data.frame())

    hw      <- width / 2
    mean_y  <- mean(data$y)
    avg_y   <- if (!is.null(scales$y) && !is.null(scales$y$trans)) {
      scales$y$trans$inverse(mean_y)
    } else {
      mean_y
    }
    segs  <- nrow(data) - 1
    parts <- vector("list", segs)

    for (i in seq_len(segs)) {
      upper <- sigmoid_path(data$x[i], data$x[i + 1],
                            data$y[i] - hw, data$y[i + 1] - hw,
                            smooth, n)
      lower <- sigmoid_path(data$x[i], data$x[i + 1],
                            data$y[i] + hw, data$y[i + 1] + hw,
                            smooth, n)
      seg <- data.frame(
        x     = upper$x,
        y     = (upper$y + lower$y) / 2,
        ymin  = upper$y,
        ymax  = lower$y,
        avg_y = avg_y
      )

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
