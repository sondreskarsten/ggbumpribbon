test_that("sigmoid_path returns correct structure", {
  out <- ggbumpribbon:::sigmoid_path(1, 2, 0, 10, smooth = 8, n = 50)
  expect_s3_class(out, "data.frame")
  expect_equal(nrow(out), 50)
  expect_named(out, c("x", "y"))
})

test_that("sigmoid_path endpoints converge to y_from and y_to", {
  out <- ggbumpribbon:::sigmoid_path(0, 1, 3, 7, smooth = 8, n = 200)
  expect_equal(out$y[1], 3, tolerance = 0.01)
  expect_equal(out$y[200], 7, tolerance = 0.01)
})

test_that("sigmoid_path is monotone when y_to > y_from", {
  out <- ggbumpribbon:::sigmoid_path(0, 1, 1, 5, smooth = 8, n = 100)
  expect_true(all(diff(out$y) >= 0))
})

test_that("sigmoid_path handles y_from == y_to", {
  out <- ggbumpribbon:::sigmoid_path(0, 1, 3, 3, smooth = 8, n = 50)
  expect_true(all(out$y == 3))
})
