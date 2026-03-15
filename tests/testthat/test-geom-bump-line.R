df <- data.frame(
  x     = rep(1:2, each = 3),
  y     = c(1, 2, 3, 3, 1, 2),
  group = rep(c("A", "B", "C"), 2)
)

test_that("geom_bump_line returns a ggplot layer", {
  layer <- geom_bump_line()
  expect_s3_class(layer, "LayerInstance")
})

test_that("geom_bump_line builds without error", {
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, group = group, colour = group)) +
    geom_bump_line()
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("StatBumpLine compute_group returns x and y", {
  group_data <- data.frame(x = 1:2, y = c(1, 3))
  out <- StatBumpLine$compute_group(group_data, NULL, smooth = 8, n = 50)
  expect_true(all(c("x", "y", "avg_y") %in% names(out)))
  expect_equal(nrow(out), 50)
  expect_false("ymin" %in% names(out))
  expect_false("ymax" %in% names(out))
})

test_that("StatBumpLine chains 3 segments for 4 x-values", {
  group_data <- data.frame(x = c(1, 1.4, 1.6, 2), y = c(1, 1, 5, 5))
  out <- StatBumpLine$compute_group(group_data, NULL, smooth = 8, n = 100)
  expect_equal(nrow(out), 298)
})

test_that("StatBumpLine avg_y inverse-transforms under scale_y_reverse", {
  group_data <- data.frame(x = 1:2, y = c(-2, -8))
  mock_scales <- list(y = list(trans = list(inverse = function(x) -x)))
  out <- StatBumpLine$compute_group(group_data, mock_scales, smooth = 8, n = 50)
  expect_true(all(out$avg_y == 5))
})

test_that("StatBumpLine returns empty for single row", {
  out <- StatBumpLine$compute_group(data.frame(x = 1, y = 1), NULL)
  expect_equal(nrow(out), 0)
})
