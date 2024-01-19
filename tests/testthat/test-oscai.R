df <- data.frame(
  stimulus = c("brick", "hammer", "sponge"),
  response = c("butter for trolls", "make Thor jealous", "make it play in a kids show")
)

test_that("API responses", {
  expect_no_error(oscai(df, stimulus, response))
})

test_that("chatgpt model works", {
  expect_no_error(oscai(df, stimulus, response, model = "chatgpt"))
})

test_that("babbage2 model works", {
  expect_no_error(oscai(df, stimulus, response, model = "babbage2"))
})

test_that("davinci2 model works", {
  expect_no_error(oscai(df, stimulus, response, model = "davinci2"))
})