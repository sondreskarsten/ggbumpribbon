#' @keywords internal
"_PACKAGE"

#' Base ggproto classes for ggbumpribbon
#'
#' These ggproto objects implement the statistical transformations for
#' bump ribbon and line charts. They are exported for extensibility but
#' should typically be used through [geom_bump_ribbon()] and
#' [geom_bump_line()].
#'
#' @returns ggproto objects that should not be called directly.
#' @seealso [ggplot2::Stat], [ggplot2::ggproto()]
#' @name ggbumpribbon-ggproto
#' @rdname ggbumpribbon-ggproto
NULL

#' @importFrom cli cli_abort
#' @importFrom ggplot2 ggproto Stat aes %+replace%
NULL
