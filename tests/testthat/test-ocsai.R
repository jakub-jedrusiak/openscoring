df <- data.frame(
  stimulus = c("brick", "hammer", "sponge"),
  response = c("butter for trolls", "make Thor jealous", "make it play in a kids show")
)

test_that("API responses", {
  expect_no_error(ocsai(df, stimulus, response))
})

test_that("chatgpt model works", {
  expect_no_error(ocsai(df, stimulus, response, model = "chatgpt"))
})

test_that("babbage2 model works", {
  expect_no_error(ocsai(df, stimulus, response, model = "babbage2"))
})

test_that("davinci2 model works", {
  expect_no_error(ocsai(df, stimulus, response, model = "davinci2"))
})

test_that("autosplitting works", {
  autosplit_df <- readRDS(test_path("autosplit_data.RDS"))
  autosplit_df[["item"]] <- "Cegła"
  expect_no_error(ocsai(autosplit_df, item, response, model = "1.6", language = "Polish", quiet = TRUE))
})

test_that("question arg works", {
  expect_no_error(ocsai(df, NULL, response, question = "brick"))
})