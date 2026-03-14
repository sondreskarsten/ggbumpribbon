#' Dark theme for bump ribbon charts
#'
#' A minimal dark theme based on [ggplot2::theme_void()] with a dark
#' background and light text, suited to rank comparison infographics.
#'
#' @param bg Background fill colour. Default `"#1a1a2e"`.
#' @param title_color Title text colour. Default `"#e74c3c"`.
#' @param base_size Base font size. Default `10`.
#'
#' @returns A ggplot2 [theme][ggplot2::theme()] object.
#' @export
#'
#' @examples
#' library(ggplot2)
#' ggplot(mtcars, aes(wt, mpg)) +
#'   geom_point(colour = "white") +
#'   labs(title = "Motor Trend Cars") +
#'   theme_bump()
theme_bump <- function(bg = "#1a1a2e",
                       title_color = "#e74c3c",
                       base_size = 10) {
  ggplot2::theme_void(base_size = base_size) %+replace%
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = bg, colour = NA),
      panel.background = ggplot2::element_rect(fill = bg, colour = NA),
      plot.title       = ggplot2::element_text(
        colour = title_color, size = base_size * 1.6,
        face = "bold", hjust = 0.5,
        margin = ggplot2::margin(t = 15, b = 2)
      ),
      plot.subtitle = ggplot2::element_text(
        colour = "grey80", size = base_size * 0.8,
        hjust = 0.5, margin = ggplot2::margin(b = 10)
      ),
      plot.caption = ggplot2::element_text(
        colour = "grey50", size = base_size * 0.6,
        hjust = 1, margin = ggplot2::margin(t = 10, b = 5)
      ),
      plot.margin = ggplot2::margin(10, 10, 10, 10)
    )
}
