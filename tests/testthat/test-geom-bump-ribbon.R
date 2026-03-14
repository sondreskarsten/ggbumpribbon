df <- data.frame(
  x     = rep(1:2, each = 3),
  y     = c(1, 2, 3, 3, 1, 2),
  group = rep(c("A", "B", "C"), 2)
)

test_that("geom_bump_ribbon returns a ggplot layer", {
  layer <- geom_bump_ribbon()
  expect_s3_class(layer, "LayerInstance")
})

test_that("geom_bump_ribbon builds without error", {
  p <- ggplot2::ggplot(df, ggplot2::aes(x, y, group = group, fill = group)) +
    geom_bump_ribbon()
  built <- ggplot2::ggplot_build(p)
  expect_s3_class(built, "ggplot_built")
})

test_that("StatBumpRibbon compute_group produces ymin and ymax", {
  group_data <- data.frame(x = 1:2, y = c(1, 3))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 50, width = 0.8)
  expect_true(all(c("x", "ymin", "ymax") %in% names(out)))
  expect_equal(nrow(out), 50)
  expect_true(all(out$ymax > out$ymin))
})

test_that("StatBumpRibbon handles 3+ time points", {
  group_data <- data.frame(x = 1:3, y = c(1, 3, 2))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 100, width = 0.8)
  expect_equal(nrow(out), 199)
  expect_true(all(out$ymax > out$ymin))
})

test_that("StatBumpRibbon returns empty for single-row input", {
  out <- StatBumpRibbon$compute_group(data.frame(x = 1, y = 1), NULL)
  expect_equal(nrow(out), 0)
})

test_that("computed avg_y is the group mean", {
  group_data <- data.frame(x = 1:2, y = c(2, 8))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 50, width = 0.8)
  expect_true(all(out$avg_y == 5))
})

test_that("width parameter controls ribbon thickness", {
  group_data <- data.frame(x = 1:2, y = c(5, 5))
  thin <- StatBumpRibbon$compute_group(group_data, NULL, width = 0.4)
  wide <- StatBumpRibbon$compute_group(group_data, NULL, width = 2.0)
  expect_true(mean(thin$ymax - thin$ymin) < mean(wide$ymax - wide$ymin))
})

test_that("smooth parameter affects curvature", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  sharp <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 20, n = 100, width = 0.8)
  gentle <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 2, n = 100, width = 0.8)
  mid <- 50
  expect_true(abs(sharp$ymin[mid] - sharp$ymin[1]) != abs(gentle$ymin[mid] - gentle$ymin[1]))
})
