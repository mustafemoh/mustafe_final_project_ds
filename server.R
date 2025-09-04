library(shiny)
source("./Prediction.R", local = TRUE)

shinyServer(function(input, output, session){
  savedWords <- reactiveVal(character(0))
  
  prediction <- reactive({
    preds <- nextWordPredictor(input$inputTxt, top_n = 4)
    savedWords(preds)
    preds
  })
  
  # Top-1 for rubric
  output$top1 <- renderText({
    preds <- prediction()
    if (length(preds)) preds[1] else "—"
  })
  
  # Buttons for up to 4 suggestions
  output$words <- renderUI({
    preds <- prediction()
    if (!length(preds)) return(NULL)
    
    btns <- lapply(seq_along(preds), function(i) {
      actionButton(inputId = paste0("word", i), label = preds[i])
    })
    
    do.call(tagList, btns)  # this unpacks them correctly
  })
  
  
  # Append chosen word
  observeEvent(input$word1, { p <- savedWords(); if (length(p) >= 1) updateTextInput(session, "inputTxt", value = paste(input$inputTxt, p[1])) })
  observeEvent(input$word2, { p <- savedWords(); if (length(p) >= 2) updateTextInput(session, "inputTxt", value = paste(input$inputTxt, p[2])) })
  observeEvent(input$word3, { p <- savedWords(); if (length(p) >= 3) updateTextInput(session, "inputTxt", value = paste(input$inputTxt, p[3])) })
  observeEvent(input$word4, { p <- savedWords(); if (length(p) >= 4) updateTextInput(session, "inputTxt", value = paste(input$inputTxt, p[4])) })
})
