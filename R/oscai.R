#' @title Score with an AI
#' A basic function to score the creativity with an AI.
#' See [the OpenScoring site](https://openscoring.du.edu/scoringllm)
#' for more information. Requires an internet connection.
#'
#' @param df A data frame.
#' @param item The column name of the items or other kind of prompt.
#' @param answer The column name of the responses. Commas will be replaced with spaces for scoring.
#' @param model The model to use. Can be one of "1.5", "chatgpt", "babbage2", "davinci2".
#' @param scores_col The column name to store the scores in. Defaults to ".originality".
#' @param quiet Whether to print the citation reminder.
#'
#' @return The input data frame with the scores added.
#'
#' @examples
#' df <- data.frame(
#'   stimulus = c("brick", "hammer", "sponge"),
#'   response = c("butter for trolls", "make Thor jealous", "make it play in a kids show")
#' )
#'
#' df <- oscai(df, stimulus, response, model = "davinci2")
#'
#' @export

oscai <- function(df, item, answer, model = c("1.5", "chatgpt", "babbage2", "davinci2"), scores_col = ".originality", quiet = FALSE) {
  item <- rlang::ensym(item)
  answer <- rlang::ensym(answer)
  model <- rlang::arg_match(model)

  model <- switch(model,
    "1.5" = "ocsai-1.5",
    chatgpt = "ocsai-chatgpt",
    babbage2 = "ocsai-babbage2",
    davinci2 = "ocsai-davinci2"
  )

  item <- df[[rlang::as_label(item)]]
  answer <- df[[rlang::as_label(answer)]]

  item <- stringr::str_replace_all(item, ",", " ")
  answer <- stringr::str_replace_all(answer, ",", " ")
  input <- paste0("\"", item, "\", \"", answer, "\"", collapse = "\n")

  res <- httr::GET(
    "https://openscoring.du.edu/llm",
    httr::config(ssl_verifypeer=0),
    query = list(
      model = model,
      input = input
    )
  )

  if (res$status_code != 200) {
    cli::cli_abort("OpenScoring API returned status code {res$status_code}\n\n{res}")
  }

  content <- jsonlite::fromJSON(stringr::str_replace_all(rawToChar(res$content), "NaN", "\"NA\""))

  if (!quiet) {
    cli::cli_inform(c("v" = "Remember to cite:\n\n{content$cite}"))
  }
  df[[scores_col]] <- content$scores$originality

  return(df)
}
