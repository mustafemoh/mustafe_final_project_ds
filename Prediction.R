# Prediction.R — runtime-only: load n-gram tables + define nextWordPredictor

suppressPackageStartupMessages({
  library(tm)
  library(data.table)
})

# ---- 1) Load prebuilt n-gram tables (placed in ./data) ----
req_files <- c("data/final_bigram.Rda", "data/final_trigram.Rda", "data/final_fourgram.Rda")
missing <- req_files[!file.exists(req_files)]
if (length(missing)) {
  stop(sprintf(
    "Missing model files: %s\nPlace these in a 'data' folder next to the app.",
    paste(missing, collapse = ", ")
  ))
}

bigram   <- readRDS("data/final_bigram.Rda")
trigram  <- readRDS("data/final_trigram.Rda")
fourgram <- readRDS("data/final_fourgram.Rda")

# Optional: ensure they are data.table (in case they were saved as data.frame)
bigram   <- as.data.table(bigram)
trigram  <- as.data.table(trigram)
fourgram <- as.data.table(fourgram)

# ---- 2) Keys for fast lookup ----
if (all(c("one","two") %in% names(bigram)))                  setkey(bigram, one)
if (all(c("one","two","three") %in% names(trigram)))         setkey(trigram, one, two)
if (all(c("one","two","three","four") %in% names(fourgram))) setkey(fourgram, one, two, three)

# ---- 3) Input cleaning (match training-time normalization) ----
clean_input <- function(txt) {
  txt <- tolower(txt)
  txt <- removeNumbers(txt)
  txt <- removePunctuation(txt)
  txt <- stripWhitespace(txt)
  trimws(txt)
}

# (Optional) filter to hide hashtags in predictions without rebuilding tables
.filter_candidates <- function(x, drop_hashtags = FALSE) {
  if (!drop_hashtags) return(x)
  x[!grepl("^#", x)]
}

# ---- 4) Predictor with 4→3→2 Katz backoff (frequency-sorted) ----
nextWordPredictor <- function(inputTxt, top_n = 4, drop_hashtags = FALSE) {
  if (is.null(inputTxt) || !nzchar(inputTxt)) return(character(0))
  ws <- strsplit(clean_input(inputTxt), "\\s+")[[1]]
  n  <- length(ws)
  
  runBigram <- function(w2) {
    if (!all(c("one","two") %in% names(bigram))) return(character(0))
    res <- bigram[.(w2)]
    if (!nrow(res)) return(character(0))
    if ("count" %in% names(res)) res <- res[order(-count)]
    unique(res$two)
  }
  runTrigram <- function(w1, w2) {
    need <- c("one","two","three"); if (!all(need %in% names(trigram))) return(character(0))
    res <- trigram[.(w1, w2)]
    if (!nrow(res)) return(character(0))
    if ("count" %in% names(res)) res <- res[order(-count)]
    unique(res$three)
  }
  runFourgram <- function(w1, w2, w3) {
    need <- c("one","two","three","four"); if (!all(need %in% names(fourgram))) return(character(0))
    res <- fourgram[.(w1, w2, w3)]
    if (!nrow(res)) return(character(0))
    if ("count" %in% names(res)) res <- res[order(-count)]
    unique(res$four)
  }
  
  preds <- character(0)
  if (n >= 3) {
    preds <- c(preds, runFourgram(ws[n-2], ws[n-1], ws[n]))
    if (length(preds) < top_n) preds <- c(preds, runTrigram(ws[n-1], ws[n]))
    if (length(preds) < top_n) preds <- c(preds, runBigram(ws[n]))
  } else if (n == 2) {
    preds <- runTrigram(ws[1], ws[2]); if (!length(preds)) preds <- runBigram(ws[2])
  } else {
    preds <- runBigram(ws[1])
  }
  
  preds <- unique(.filter_candidates(preds, drop_hashtags = drop_hashtags))
  if (length(preds) > top_n) preds <- preds[1:top_n]
  preds
}

