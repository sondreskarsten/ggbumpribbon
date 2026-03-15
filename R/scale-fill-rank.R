#' Rank-based gradient fill scale
#'
#' A convenience wrapper around [ggplot2::scale_fill_gradientn()] with
#' defaults suited to rank comparison charts (green = best, red = worst).
#'
#' @param colors Character vector of gradient colours. Default is a
#'   six-colour green-yellow-red ramp.
#' @param limits Numeric vector of length 2 giving the scale limits, or
#'   `NULL` (default) to compute limits from the data range.
#' @param ... Passed to [ggplot2::scale_fill_gradientn()].
#'
#' @returns A ggplot2 scale object.
#' @export
#'
#' @examples
#' library(ggplot2)
#' df <- data.frame(
#'   x     = rep(1:2, each = 5),
#'   y     = c(1,2,3,4,5, 3,1,5,2,4),
#'   group = rep(LETTERS[1:5], 2)
#' )
#' ggplot(df, aes(x, y, group = group, fill = after_stat(avg_y))) +
#'   geom_bump_ribbon() +
#'   scale_fill_rank() +
#'   scale_y_reverse()
scale_fill_rank <- function(colors = c("#2ecc71", "#a8e063", "#f7dc6f",
                                       "#f0932b", "#eb4d4b", "#c0392b"),
                            limits = NULL,
                            ...) {
  if (!is.null(limits)) {
    breaks <- seq(limits[1], limits[2], length.out = length(colors))
    values <- scales::rescale(breaks)
  } else {
    values <- scales::rescale(seq(0, 1, length.out = length(colors)))
  }
  ggplot2::scale_fill_gradientn(
    colours = colors,
    values  = values,
    limits  = limits,
    guide   = "none",
    ...
  )
}
