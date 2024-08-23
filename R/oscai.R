#' @title Score with an AI
#' A basic function to score the creativity with an AI.
#' See [the OpenScoring site](https://openscoring.du.edu/scoringllm)
#' for more information. Requires an internet connection.
#'
#' @param df A data frame.
#' @param item The column name of the items or other kind of prompt.
#' @param answer The column name of the responses. Commas will be replaced with spaces for scoring.
#' @param model The model to use. Should be one of "1.6", "1-4o", "davinci3", "chatgpt2". Deprecated models are kept for compatibility.
#' @param language The language of the input. Only works for the 1.5 model upwards. Should be one of "Arabic", "Chinese", "Dutch", "English", "French", "German", "Hebrew", "Italian", "Polish", "Russian", "Spanish".
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
#' df <- oscai(df, stimulus, response, model = "davinci3")
#'
#' # The 1.5 model and upwards works for multiple languages
#' df_polish <- data.frame(
#'   stimulus = c("cegła", "młotek", "gąbka"),
#'   response = c("masło dla trolli", "wywoływanie zazdrości u Thora", "postać w programie dla dzieci")
#' )
#'
#' df_polish <- oscai(df_polish, stimulus, response, model = "1.5", language = "Polish")
#'
#' @details
#' Available models:
#' * ocsai-1.6: Update to the multi-lingual, multi-task 1.5 model, trained on GPT 4o instead of 3.5.
#' * ocsai1-4o: GPT-4o-based model, trained with more data and supporting multiple tasks. Last update to the Ocsai 1 models (i.e. the original ones).
#' * ocsai-chatgpt2: GPT-3.5-size chat-based model, trained with more data and supporting multiple tasks. Scoring is slower, with slightly better performance than ocsai-davinci.
#' * ocsai-davinci3: GPT-3 Davinci-size model. Trained with the method from Organisciak et al. 2023, but with the additional tasks (uses, consequences, instances, complete the sentence) from Acar et al 2023, and trained with more data.
#' * ocsai-1.5: Beta version of new multi-lingual, multi-task model, trained on GPT 3.5.
#' * ocsai-chatgpt: GPT-3.5-size chat-based model, trained with same format and data as original models. Scoring is slower, with slightly better performance than ocsai-davinci2. For more tasks and trained on more data, use davinci-ocsai2
#' * ocsai-babbage2: GPT-3 Babbage-size model from the paper, retrained with new model API. Deprecated, mainly because other models work better.
#' * ocsai-davinci2: GPT-3 Davinci-size model from the paper, retrained with a new model API.
#'
#' @export

oscai <- function(df, item, answer, model = c("1.6", "1-4o", "davinci3", "chatgpt2", "1.5", "chatgpt", "babbage2", "davinci2"), language = "English", scores_col = ".originality", quiet = FALSE) {
  item <- rlang::ensym(item)
  answer <- rlang::ensym(answer)
  model <- rlang::arg_match(model)
  language <- rlang::arg_match0(language, values = c("Arabic", "Chinese", "Dutch", "English", "French", "German", "Hebrew", "Italian", "Polish", "Russian", "Spanish"))

  model <- switch(model,
    "1.6" = "ocsai-1.6",
    "1-4o" = "ocsai1-4o",
    "1.5" = "ocsai-1.5",
    davinci3 = "ocsai-davinci3",
    chatgpt2 = "ocsai-chatgpt2",
    chatgpt = "ocsai-chatgpt",
    babbage2 = "ocsai-babbage2",
    davinci2 = "ocsai-davinci2"
  )

  df <- split(df, ceiling(seq_along(df[[rlang::as_label(item)]]) / 50)) # break into 50-row chunks

  purrr::map(
    df,
    \(df) {
      item <- df[[rlang::as_label(item)]]
      answer <- df[[rlang::as_label(answer)]]

      item <- stringr::str_replace_all(item, ",", " ")
      answer <- stringr::str_replace_all(answer, ",", " ")
      input <- paste0("\"", item, "\", \"", answer, "\"", collapse = "\n")

      res <- httr::POST(
        "https://openscoring.du.edu/llm",
        httr::config(ssl_verifypeer = 0),
        query = list(
          model = model,
          input = input,
          language = language
        )
      )

      if (res$status_code != 200) {
        cli::cli_inform(c("!" = "The database possibly contains false {.code NA} values due to a server error", "i" = "Check your internet connection and consider rerunning the {.fn oscai} fucntion call", " " = "OpenScoring API returned status code {res$status_code}", " " = "{res}"))
        df[[scores_col]] <- NA
      } else {
        content <- jsonlite::fromJSON(stringr::str_replace_all(rawToChar(res$content), "NaN", "\"NA\""))
        df[[scores_col]] <- content$scores$originality
      }
      return(df)
    },
    .progress = !quiet
  ) |>
    dplyr::bind_rows()
}
