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

test_that("StatBumpRibbon compute_group produces ymin and ymax (sigmoid)", {
  group_data <- data.frame(x = 1:2, y = c(1, 3))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 50, width = 0.8,
                                       method = "sigmoid")
  expect_true(all(c("x", "ymin", "ymax") %in% names(out)))
  expect_equal(nrow(out), 50)
  expect_true(all(out$ymax > out$ymin))
})

test_that("StatBumpRibbon compute_group produces ymin and ymax (hermite)", {
  group_data <- data.frame(x = 1:2, y = c(1, 3))
  out <- StatBumpRibbon$compute_group(group_data, NULL, n = 50, width = 0.8,
                                       method = "hermite")
  expect_true(all(c("x", "ymin", "ymax") %in% names(out)))
  expect_equal(nrow(out), 51)
  expect_true(all(out$ymax > out$ymin))
})

test_that("StatBumpRibbon handles 3+ time points (sigmoid)", {
  group_data <- data.frame(x = 1:3, y = c(1, 3, 2))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 100, width = 0.8,
                                       method = "sigmoid")
  expect_equal(nrow(out), 199)
  expect_true(all(out$ymax > out$ymin))
})

test_that("StatBumpRibbon handles 3+ time points (hermite)", {
  group_data <- data.frame(x = 1:3, y = c(1, 3, 2))
  out <- StatBumpRibbon$compute_group(group_data, NULL, n = 100, width = 0.8,
                                       method = "hermite")
  expect_equal(nrow(out), 201)
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

test_that("smooth parameter affects curvature (sigmoid method)", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  sharp <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 15, n = 100,
                                         width = 0.8, method = "sigmoid")
  gentle <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 2, n = 100,
                                          width = 0.8, method = "sigmoid")
  mid <- 50
  expect_true(abs(sharp$ymin[mid] - sharp$ymin[1]) != abs(gentle$ymin[mid] - gentle$ymin[1]))
})

test_that("exact knot values at segment joins (sigmoid)", {
  group_data <- data.frame(x = 1:3, y = c(1, 5, 2))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 8, n = 100, width = 0.8,
                                       method = "sigmoid")
  mid <- which.min(abs(out$x - 2))
  expect_equal(out$x[mid], 2)
  expect_equal(out$ymin[mid], 5 - 0.4)
  expect_equal(out$ymax[mid], 5 + 0.4)
})

test_that("exact knot values at segment joins (hermite)", {
  group_data <- data.frame(x = 1:3, y = c(1, 5, 2))
  out <- StatBumpRibbon$compute_group(group_data, NULL, n = 100, width = 0.8,
                                       method = "hermite")
  mid <- which.min(abs(out$x - 2))
  expect_equal(out$x[mid], 2)
  expect_equal(out$ymin[mid], 5 - 0.4)
  expect_equal(out$ymax[mid], 5 + 0.4)
})

test_that("duplicate x values are handled", {
  group_data <- data.frame(x = c(1, 1, 2), y = c(1, 3, 5))
  out <- StatBumpRibbon$compute_group(group_data, NULL)
  expect_true(nrow(out) > 0)
  expect_true(all(c("x", "ymin", "ymax") %in% names(out)))
})

test_that("method parameter switches interpolation", {
  group_data <- data.frame(x = 1:3, y = c(1, 5, 2))
  out_s <- StatBumpRibbon$compute_group(group_data, NULL, method = "sigmoid")
  out_h <- StatBumpRibbon$compute_group(group_data, NULL, method = "hermite")
  expect_false(nrow(out_s) == nrow(out_h))
})

test_that("n < 2 errors with informative message", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  expect_error(
    StatBumpRibbon$compute_group(group_data, NULL, n = 0),
    "n.*must be.*>= 2"
  )
  expect_error(
    StatBumpRibbon$compute_group(group_data, NULL, n = 1),
    "n.*must be.*>= 2"
  )
  expect_error(
    StatBumpRibbon$compute_group(group_data, NULL, n = -5),
    "n.*must be.*>= 2"
  )
})

test_that("negative width is treated as positive", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  out_neg <- StatBumpRibbon$compute_group(group_data, NULL, width = -0.8)
  out_pos <- StatBumpRibbon$compute_group(group_data, NULL, width = 0.8)
  expect_equal(out_neg$ymin, out_pos$ymin)
  expect_equal(out_neg$ymax, out_pos$ymax)
  expect_true(all(out_neg$ymax > out_neg$ymin))
})

test_that("smooth = 0 produces linear interpolation (sigmoid method)", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = 0, n = 100,
                                       width = 0.8, method = "sigmoid")
  expect_true(nrow(out) > 0)
  expect_false(any(is.nan(out$ymin)))
  mid <- nrow(out) %/% 2
  expect_equal(out$y[mid], 3, tolerance = 0.1)
})

test_that("smooth < 0 falls back to linear (sigmoid method)", {
  group_data <- data.frame(x = 1:2, y = c(1, 5))
  out <- StatBumpRibbon$compute_group(group_data, NULL, smooth = -3, n = 100,
                                       width = 0.8, method = "sigmoid")
  expect_true(nrow(out) > 0)
  expect_false(any(is.nan(out$ymin)))
  expect_true(out$y[1] < out$y[nrow(out)])
})
