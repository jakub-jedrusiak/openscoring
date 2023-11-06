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
