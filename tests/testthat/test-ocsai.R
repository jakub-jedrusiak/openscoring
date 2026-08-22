df <- data.frame(
  stimulus = c("brick", "hammer", "sponge"),
  response = c(
    "butter for trolls",
    "make Thor jealous",
    "make it play in a kids show"
  )
)

test_that("API responses", {
  expect_no_error(ocsai(df, stimulus, response, model = "2", quiet = TRUE))
})

test_that("documented form payload works", {
  expect_no_error(ocsai(df, stimulus, response, model = "2-xs", quiet = TRUE))
})

test_that("1.6 model works", {
  expect_no_error(ocsai(df, stimulus, response, model = "1.6", quiet = TRUE))
})

test_that("1-4o model works", {
  expect_no_error(ocsai(df, stimulus, response, model = "1-4o", quiet = TRUE))
})

test_that("autosplitting works", {
  autosplit_df <- readRDS(test_path("autosplit_data.RDS"))
  autosplit_df[["item"]] <- "Cegła"
  expect_no_error(ocsai(
    autosplit_df,
    item,
    response,
    model = "1.6",
    language = "Polish",
    quiet = TRUE
  ))
})

test_that("question arg works", {
  expect_no_error(ocsai(
    df,
    NULL,
    response,
    question = "brick",
    model = "2",
    quiet = TRUE
  ))
})

test_that("logprob_scoring adds a confidence column", {
  res <- ocsai(df, stimulus, response, model = "2", quiet = TRUE)
  expect_true(".confidence" %in% names(res))
})

test_that("logprob_scoring = FALSE omits the confidence column", {
  res <- ocsai(
    df,
    stimulus,
    response,
    model = "2",
    quiet = TRUE,
    logprob_scoring = FALSE
  )
  expect_false(".confidence" %in% names(res))
})

test_that("confidence_col renames the confidence column", {
  res <- ocsai(
    df,
    stimulus,
    response,
    model = "2",
    quiet = TRUE,
    confidence_col = "conf"
  )
  expect_true("conf" %in% names(res))
})
