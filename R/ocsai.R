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
#' @param chunk_size The number of rows to send to the API at once. Defaults to 50. If a request is too large, it will be split into 10-row chunks.
#' @param task The name of the task to be scored. Can be "uses" (default), "completion", "consequences", "instances" or "metaphors".
#' @param short_prompt Whether the prompt is a short prompt (`TRUE`) or a full question (`FALSE`). Defaults to `TRUE`.
#' @param question You can set this arg instead of providing the `item` column.
#'
#' @return The input data frame with the scores added.
#'
#' @examples
#' df <- data.frame(
#'   stimulus = c("brick", "hammer", "sponge"),
#'   response = c("butter for trolls", "make Thor jealous", "make it play in a kids show")
#' )
#'
#' df <- ocsai(df, stimulus, response, model = "davinci3")
#'
#' # The 1.5 model and upwards works for multiple languages
#' df_polish <- data.frame(
#'   stimulus = c("cegła", "młotek", "gąbka"),
#'   response = c("masło dla trolli", "wywoływanie zazdrości u Thora", "postać w programie dla dzieci")
#' )
#'
#' df_polish <- ocsai(df_polish, stimulus, response, model = "1.5", language = "Polish")
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

ocsai <- function(df, item, answer, model = c("1.6", "1-4o", "davinci3", "chatgpt2", "1.5", "chatgpt", "babbage2", "davinci2"), language = "English", scores_col = ".originality", quiet = FALSE, chunk_size = 50, task = "uses", short_prompt = TRUE, question = NULL) {
  if (is.null(question)) {
    item_col <- rlang::ensym(item)
  }
  answer_col <- rlang::ensym(answer)
  model <- rlang::arg_match(model)
  language <- rlang::arg_match0(language, values = c("Arabic", "Chinese", "Dutch", "English", "French", "German", "Hebrew", "Italian", "Polish", "Russian", "Spanish"))
  task <- rlang::arg_match0(task, values = c("uses", "completion", "consequences", "instances", "metaphors"))
  short_prompt <- as.logical(short_prompt)


  if (is.null(question) && !rlang::has_name(df, rlang::as_name(item_col))) {
    cli::cli_abort(
      c(
        "All columns must exist in the data.",
        "x" = "Column {.var {rlang::as_name(item_col)}} does not exist.",
        "i" = "Check the spelling."
      )
    )
  }

  if (!rlang::has_name(df, rlang::as_name(answer_col))) {
    cli::cli_abort(
      c(
        "All columns must exist in the data.",
        "x" = "Column {.var {rlang::as_name(answer_col)}} does not exist.",
        "i" = "Check the spelling."
      )
    )
  }

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

  df <- split(df, ceiling(seq_along(df[[rlang::as_label(answer_col)]]) / chunk_size)) # break into 50-row chunks

  purrr::map(
    df,
    \(df) {
      answer <- df[[rlang::as_label(answer_col)]]
      answer <- answer |>
        stringr::str_squish() |>
        curl::curl_escape()
      if (is.null(question)) {
        item <- df[[rlang::as_label(item_col)]]

        item <- item |>
          stringr::str_squish() |>
          curl::curl_escape()

        input <- paste0("\"", item, "\",\"", answer, "\"", collapse = "\n")
        query <- list(
          model = model,
          input = input,
          language = language,
          task = task,
          prompt_in_input = short_prompt,
          question_in_input = !short_prompt
        )
      } else {
        input <- paste0('"', answer, '"', collapse = "\n")
        query <- list(
          model = model,
          input = input,
          language = language,
          task = task,
          prompt_in_input = FALSE,
          question_in_input = FALSE
        )
        if (short_prompt) {
          query$prompt <- question
        } else {
          query$question <- question
        }
      }

      res <- httr::POST(
        "https://openscoring.du.edu/llm",
        httr::config(ssl_verifypeer = 0),
        query = query
      )

      if (res$status_code == 400 & any(stringr::str_detect(rawToChar(res$content), "Request Line is too large"))) {
        if (is.null(question)) {
          temp <- ocsai(df, !!item_col, !!answer_col, model = stringr::str_remove(model, "ocsai-?"), language = language, scores_col = "scores", quiet = TRUE, chunk_size = 10, task = task, short_prompt = short_prompt)
        } else {
          temp <- ocsai(df, NULL, !!answer_col, model = stringr::str_remove(model, "ocsai-?"), language = language, scores_col = "scores", quiet = TRUE, chunk_size = 10, question = question, task = task, short_prompt = short_prompt)
        }
        df[[scores_col]] <- temp$scores
      } else if (res$status_code != 200) {
        cli::cli_inform(c("!" = "The database possibly contains false {.code NA} values due to a server error", "i" = "Check your internet connection and consider rerunning the {.fn ocsai} fucntion call", " " = "OpenScoring API returned status code {res$status_code}", " " = "{res}"))
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
