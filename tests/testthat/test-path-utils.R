# Create complicated formula path
# env param for formula fm_1 is for test only.

fm_1 <- formula(
    paste0(
        "a ~ b + c ~ d <= 0.5 ~ e ~ f <= 0.6",
        " ~ g >= 0.7 ~ h + i == 0.3:j ~ k < 1"
    ),
    env = globalenv()
)
fm_2 <- formula(as_path_frame(fm_1))

test_that("as_path_frame() correctly parses formula", {


    expect_identical(fm_2, fm_1)
})
