#' Compute a logistic sigmoid path between two points
#'
#' @param x_from,x_to Start and end x coordinates.
#' @param y_from,y_to Start and end y coordinates.
#' @param smooth Steepness of the logistic curve. Default `8`.
#' @param n Number of interpolated points. Default `100`.
#' @returns A data.frame with columns `x` and `y`.
#' @noRd
sigmoid_path <- function(x_from, x_to, y_from, y_to, smooth = 8, n = 100) {
  t <- seq(-smooth, smooth, length.out = n)
  data.frame(
    x = seq(x_from, x_to, length.out = n),
    y = y_from + (y_to - y_from) / (1 + exp(-t))
  )
}
