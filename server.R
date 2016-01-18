#Final project app

require(shiny)
require(stringr)

server <- function(input, output, session) {
    output$guess <- renderText({
        if (input$phrase=="") return(NULL)
        fileReaderData <- reactiveFileReader(50000, session, "./FreqTerms.csv", read.csv)
        triGrams <- fileReaderData()
        #Find last word in trigram 
        in.sent <- input$phrase
        
        GetInWord <- function(phrase, n){
            words <- str_split(phrase, boundary("word"))
            #str(words)
            count <- str_count(words, boundary("word"))
            return(words[[1]][count-n])
        }
        
        in.word1 <- GetInWord(in.sent, 2) #Get second to last word
        in.word2 <- GetInWord(in.sent, 1) #Get last word
        
        tri.grams <- triGrams[ with(triGrams,  grepl(in.word1, triGrams$x)  &  grepl(in.word2, triGrams$x) ) , ]
        #head(tri.grams)
        
        GuessOutWord <- function(tri.grams){
            phrase <- tri.grams[[1]]
            words <- str_split(phrase, boundary("word"))
            count <- str_count(words, boundary("word"))
            return(words[[1]][count-1])
        }
        
        guess <- tryCatch({
            GuessOutWord(tri.grams)
            }, error = function(err) {
              # error handler picks up where error was generated
              print(paste("MY_ERROR:  ",err))
              f <- "Sorry folks-had to trap subscript out of bounds"
              return(f)
            })
        return(guess)})
}




