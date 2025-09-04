# mustafe_final_project_ds

Next Word Prediction App built with the SwiftKey dataset for the Coursera Data Science Capstone.  
A Shiny app that takes a phrase as input and predicts the most likely next word using n-grams with Katz backoff.

## About
The model was trained on a sample of the SwiftKey English corpus (blogs, news, Twitter).  
Text was cleaned (lowercased, punctuation/numbers/profanity removed) and tokenized into n-grams (2–4).  
Using Katz backoff, the app predicts the next word by first checking 4-grams, then 3-grams, then 2-grams.

## Live App
👉 [Shiny App on shinyapps.io](https://mustafemoh.shinyapps.io/final_project_data_sceince)

## Presentation
👉 [Slide Deck on RPubs](https://rpubs.com/yourname/capstone-slides)

## Files in this repo
- `ui.R` – Shiny UI
- `server.R` – Shiny server logic
- `Prediction.R` – Loads n-gram models and defines predictor
- `data/` – Contains `final_bigram.Rda`, `final_trigram.Rda`, `final_fourgram.Rda`
- `build_ngrams.R` – Script to build n-gram frequency tables from corpus
- `Milestone-Report.Rmd` – initial report

## How to run locally
Clone the repo and run:
```r
shiny::runApp()

