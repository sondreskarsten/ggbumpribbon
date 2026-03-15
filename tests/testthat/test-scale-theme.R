test_that("scale_fill_rank returns a ggplot scale", {
  s <- scale_fill_rank()
  expect_s3_class(s, "ScaleContinuous")
})

test_that("scale_fill_rank defaults to NULL limits", {
  s <- scale_fill_rank()
  expect_null(s$limits)
})

test_that("scale_fill_rank respects custom limits", {
  s <- scale_fill_rank(limits = c(1, 10))
  expect_equal(s$limits, c(1, 10))
})

test_that("scale_fill_rank auto-ranges with default limits", {
  df <- data.frame(
    x     = rep(1:2, each = 5),
    y     = c(1, 2, 3, 4, 5, 3, 1, 5, 2, 4),
    group = rep(LETTERS[1:5], 2)
  )
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, group = group,
                                         fill = ggplot2::after_stat(avg_y))) +
    geom_bump_ribbon() +
    scale_fill_rank()
  b <- ggplot2::ggplot_build(p)
  fills <- unique(b$data[[1]]$fill)
  expect_true(length(fills) >= 2)
})

test_that("theme_bump returns a ggplot theme", {
  th <- theme_bump()
  expect_s3_class(th, "theme")
})

test_that("theme_bump uses specified background", {
  th <- theme_bump(bg = "#000000")
  expect_equal(th$plot.background$fill, "#000000")
})
