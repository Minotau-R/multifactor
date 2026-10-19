# Create complicated formula path
# env param for formula fm_1 is for test only.

fm_1 <- formula(
    paste0(
        "a ~ b ~ c ~ d <= 0.5 ~ e ~ f <= 0.6",
        " ~ g >= 0.7 ~ h ~ i == 0.3:j ~ k < 1"
    ),
    env = globalenv()
)

st_1 <- formula(
    paste0(
        "a ~ b + c ~ d <= 0.5 ~ e ~ f <= 0.6",
        " ~ g >= 0.7 ~ h + i == 0.3:j ~ k < 1"
    ),
    env = globalenv()
)

fm_pf <- as_path_frame(fm_1)
st_pf <- as_path_frame(st_1)
fm_2  <- formula(fm_pf)
st_2  <- formula(st_pf)

test_that("path_frame checks work properly", {
    # Unstacked
    expect_true(.check_path_frame_uses_coverage(fm_pf))
    expect_false(.check_path_frame_is_minimal(fm_pf))
    expect_false(.check_path_frame_uses_stack(fm_pf))

    # Stacked
    expect_true(.check_path_frame_uses_coverage(st_pf))
    expect_false(.check_path_frame_is_minimal(st_pf))
    expect_true(.check_path_frame_uses_stack(st_pf))
})

test_that("as_path_frame() correctly parses unstacked formula", {
    expect_identical(fm_2, fm_1)
})

test_that("as_path_frame() correctly parses stacked formula", {
    expect_identical(st_2, st_1)
})
