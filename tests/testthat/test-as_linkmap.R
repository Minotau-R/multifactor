test_that("utils", {
  lst <- list(A = c("a", "b"), B = c("a", "b", "c"), C = c("b"))

  a2b <- as_linkmap(lst)

  expect_contains(levels(a2b)$x, c("a", "b", "c"))
  expect_equal(dim(a2b), c(6, 2))

  y <- names(lst)
  lst2 <- unname(lst)

  a2b <- as_linkmap(lst2, y, edge_names = c("a", "b"))

  expect_equal(names(a2b), c("a", "b"))
  expect_equal(levels(a2b)$b, y)

  mat <- matrix(c(TRUE, FALSE, TRUE), nrow = 3, ncol = 3)
  rownames(mat) <- LETTERS[seq(3)]
  colnames(mat) <- c("x", "y", "z")

  b2c <- as_linkmap(mat, edge_names = c("b", "c"))

  expect_equal(names(b2c), c("b", "c"))
  expect_equal(levels(b2c)$c, c("x", "y", "z"))

  mf <- as_multifactor(list(X1 = lst, X2 = mat))

  expect_equal(dim(mf), c(2, 3))
  expect_equal(levels(mf)$c, c("x", "y", "z"))
})


test_that("as.matrix and as_linkmap return each other" {
  x <- random_multifactor()@linkmap
  expect_identical(as_linkmap(as.matrix(x)), x)
})
