library(shiny)

shinyUI(fluidPage(
  titlePanel("Next Word Prediction App"),
  sidebarLayout(
    sidebarPanel(
      h3("Introduction"),
      p("Type a phrase; the app predicts the next word."),
      p("Built with n-grams and Katz backoff."),
      hr(),
      h4("Links"),
      HTML("<p>GitHub: <a href='#' target='_blank'>add-your-repo</a></p>"),
      HTML("<p>RPubs slides: <a href='#' target='_blank'>add-your-slides</a></p>")
    ),
    mainPanel(
      h3("Input"),
      textInput("inputTxt", "Type in word(s) below:", width = "90%"),
      h4("Prediction (Top-1)"),
      textOutput("top1"),
      br(),
      h4("Suggestions"),
      uiOutput("words")
    )
  )
))
