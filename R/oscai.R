#' @title Score with an AI
#' A basic function to score the creativity with an AI.
#' See [the OpenScoring site](https://openscoring.du.edu/scoringllm)
#' for more information. Requires an internet connection.
#'
#' @param df A data frame.
#' @param item The column name of the items or other kind of prompt.
#' @param answer The column name of the responses. Commas will be replaced with spaces for scoring.
#' @param model The model to use. Can be one of "ada", "babbage", "curie", or "davinci".
#' @param scores_col The column name to store the scores in. Defaults to ".originality".
#'
#' @return The input data frame with the scores added.
#'
#' @export

oscai <- function(df, item, answer, model = c("ada", "babbage", "curie", "davinci"), scores_col = ".originality") {
    item <- rlang::enquo(item)
    answer <- rlang::enquo(answer)
    model <- rlang::arg_match(model)

    model <- switch(model,
        ada = "gpt-ada-paper",
        babbage = "gpt-babbage-paper",
        curie = "gpt-curie-paper",
        davinci = "gpt-davinci-paper_alpha"
    )

    item <- df[[rlang::as_label(item)]]
    answer <- df[[rlang::as_label(answer)]]

    item <- stringr::str_replace_all(item, ",", " ")
    answer <- stringr::str_replace_all(answer, ",", " ")
    input <- paste0("\"", item, "\", \"", answer, "\"", collapse = "\n")

    res <- httr::GET(
        "https://openscoring.du.edu/llm",
        query = list(
            model = model,
            input = input
        )
    )
    content <- jsonlite::fromJSON(rawToChar(res$content))

    if (res$status_code != 200) {
        cli::cli_abort("OpenScoring API returned status code {res$status_code}")
    }

    cli::cli_inform(c("v" = "Remember to cite:\n\n{content$cite}"))
    df[[scores_col]] <- content$scores$originality

    return(df)
}
