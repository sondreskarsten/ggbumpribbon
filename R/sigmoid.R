#' Compute a C1-continuous smooth path through knots (Hermite method)
#'
#' Uses `stats::splinefunH()` (cubic Hermite interpolation) with zero
#' slopes at all knots, producing S-shaped transitions visually similar
#' to the logistic sigmoid while guaranteeing first-derivative continuity
#' at every segment join.
#'
#' @param x_knots Numeric vector of x coordinates (must be strictly
#'   increasing, length >= 2).
#' @param y_knots Numeric vector of y coordinates (same length as
#'   `x_knots`).
#' @param n Number of interpolation points per segment. Default `100`.
#' @returns A data.frame with columns `x` and `y`.
#' @noRd
smooth_path_hermite <- function(x_knots, y_knots, n = 100L) {
  n_knots <- length(x_knots)
  m <- rep(0, n_knots)
  sfun <- stats::splinefunH(x_knots, y_knots, m)
  n_total <- as.integer(n) * (n_knots - 1L) + 1L
  x_out <- seq(x_knots[1L], x_knots[n_knots], length.out = n_total)
  data.frame(x = x_out, y = sfun(x_out))
}


#' Compute a C1-continuous smooth path through knots (sigmoid method)
#'
#' Uses per-segment logistic sigmoid curves with endpoint clamping and
#' Hermite basis derivative correction to achieve C1 continuity at every
#' segment join while preserving the logistic sigmoid visual character.
#'
#' The base curve in each segment is a clamped sigmoid: the raw
#' `1/(1+exp(-t))` is rescaled so endpoints map to exactly 0 and 1
#' (eliminating the positional gap). A correction term using the Hermite
#' basis functions `h10(u) = u^3 - 2u^2 + u` and `h11(u) = u^3 - u^2`
#' is then added. These basis functions have zero *value* at both
#' endpoints (so knot positions are unchanged) but unit *derivative* at
#' one endpoint and zero at the other, allowing the slope at each knot
#' to be adjusted to a shared target of zero. This forces zero
#' derivative at every interior knot, matching the sigmoid's natural
#' flattening and guaranteeing C1 continuity across segments.
#'
#' @param x_knots Numeric vector of x coordinates (must be strictly
#'   increasing, length >= 2).
#' @param y_knots Numeric vector of y coordinates (same length as
#'   `x_knots`).
#' @param smooth Steepness of the logistic curve. Default `8`.
#' @param n Number of interpolation points per segment. Default `100`.
#' @returns A data.frame with columns `x` and `y`.
#' @noRd
smooth_path_sigmoid <- function(x_knots, y_knots, smooth = 8, n = 100L) {
  n_knots <- length(x_knots)
  n_seg <- n_knots - 1L
  n_per <- as.integer(n)

  if (smooth <= 0) {
    n_total <- n_per * n_seg - (n_seg - 1L)
    x_out <- seq(x_knots[1L], x_knots[n_knots], length.out = n_total)
    sfun <- stats::approxfun(x_knots, y_knots)
    return(data.frame(x = x_out, y = sfun(x_out)))
  }

  sigma_lo <- 1 / (1 + exp(smooth))
  sigma_hi <- 1 / (1 + exp(-smooth))
  sigma_range <- sigma_hi - sigma_lo
  eps_d <- sigma_hi * sigma_lo / sigma_range

  dx <- diff(x_knots)
  dy <- diff(y_knots)

  seg_slope_nat <- dy * eps_d * 2 * smooth / dx

  m_target <- rep(0, n_knots)
  m_target[1L] <- seg_slope_nat[1L]
  m_target[n_knots] <- seg_slope_nat[n_seg]

  t_v <- seq(-smooth, smooth, length.out = n_per)
  sigma_t <- 1 / (1 + exp(-t_v))
  sigma_norm <- (sigma_t - sigma_lo) / sigma_range
  u_base <- seq(0, 1, length.out = n_per)
  h10_u <- u_base^3 - 2 * u_base^2 + u_base
  h11_u <- u_base^3 - u_base^2

  segments <- vector("list", n_seg)
  for (i in seq_len(n_seg)) {
    x_v <- x_knots[i] + u_base * dx[i]
    y_base <- y_knots[i] + dy[i] * sigma_norm

    corr <- h10_u * (m_target[i] - seg_slope_nat[i]) * dx[i] +
            h11_u * (m_target[i + 1L] - seg_slope_nat[min(i, n_seg)]) * dx[i]

    segments[[i]] <- data.frame(x = x_v, y = y_base + corr)
  }

  for (i in seq_len(n_seg)[-1L]) segments[[i]] <- segments[[i]][-1L, ]

  out <- do.call(rbind, segments)
  rownames(out) <- NULL
  out
}


#' Compute a C1-continuous smooth path through knots
#'
#' Dispatches to either [smooth_path_hermite()] or
#' [smooth_path_sigmoid()] based on `method`.
#'
#' @param x_knots,y_knots Numeric vectors of knot coordinates.
#' @param smooth Steepness of the sigmoid curve (only used when
#'   `method = "sigmoid"`). Default `8`.
#' @param n Interpolation points per segment. Default `100`.
#' @param method One of `"sigmoid"` (logistic S-curve with C1
#'   correction) or `"hermite"` (cubic Hermite smoothstep).
#' @returns A data.frame with columns `x` and `y`.
#' @noRd
smooth_path <- function(x_knots, y_knots, smooth = 8, n = 100L,
                        method = c("sigmoid", "hermite")) {
  method <- match.arg(method)
  switch(method,
    sigmoid = smooth_path_sigmoid(x_knots, y_knots, smooth = smooth, n = n),
    hermite = smooth_path_hermite(x_knots, y_knots, n = n)
  )
}


#' Compute a logistic sigmoid path between two points
#'
#' Retained for backward compatibility. New code should prefer
#' [smooth_path()], which handles multi-segment paths with C1 continuity.
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
