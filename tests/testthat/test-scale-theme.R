test_that("scale_fill_rank returns a ggplot scale", {
  s <- scale_fill_rank()
  expect_s3_class(s, "ScaleContinuous")
})

test_that("scale_fill_rank respects custom limits", {
  s <- scale_fill_rank(limits = c(1, 10))
  expect_equal(s$limits, c(1, 10))
})

test_that("theme_bump returns a ggplot theme", {
  th <- theme_bump()
  expect_s3_class(th, "theme")
})

test_that("theme_bump uses specified background", {
  th <- theme_bump(bg = "#000000")
  expect_equal(th$plot.background$fill, "#000000")
})
