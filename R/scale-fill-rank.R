#' Rank-based gradient fill scale
#'
#' A convenience wrapper around [ggplot2::scale_fill_gradientn()] with
#' defaults suited to rank comparison charts (green = best, red = worst).
#'
#' @param colors Character vector of gradient colours. Default is a
#'   six-colour green-yellow-red ramp.
#' @param limits Numeric vector of length 2 giving the scale limits.
#'   Default `c(1, 60)`.
#' @param ... Passed to [ggplot2::scale_fill_gradientn()].
#'
#' @returns A ggplot2 scale object.
#' @family bump scales
#' @seealso [ggplot2::scale_fill_gradientn()], [geom_bump_ribbon()]
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
#'   scale_fill_rank(limits = c(1, 5)) +
#'   scale_y_reverse()
scale_fill_rank <- function(colors = c("#2ecc71", "#a8e063", "#f7dc6f",
                                       "#f0932b", "#eb4d4b", "#c0392b"),
                            limits = c(1, 60),
                            ...) {
  breaks <- seq(limits[1], limits[2], length.out = length(colors))
  ggplot2::scale_fill_gradientn(
    colours = colors,
    values  = scales::rescale(breaks),
    limits  = limits,
    guide   = "none",
    ...
  )
}
