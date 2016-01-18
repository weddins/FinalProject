#Final project app

require(shiny)

ui <- fluidPage(
    tags$h1("My Shiny Word App"),
    "Enter a web sentence without the last word and the app will guess the last word.", tags$br(),tags$br(),
    fluidRow(column(width=6, textInput(inputId = "phrase",
            label = "Enter a sentence without the last word"))),
    fluidRow(column(width=6, submitButton("Submit"))),
    fluidRow(column(width=4, verbatimTextOutput("guess")))
)
