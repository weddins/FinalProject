#Create Trigrams will produce a list of trigrams that can be use to fill in the last word

#Init
require(tm); require(rJava); require(RWeka)

#Load text files
  #Function that uses rbinom to reduce number of lines of text
saveSubset <- function(txtFile, propSave){
  txt <- readLines(paste0("C:/coursera/DataScientist/10-Project/app/texts/", txtFile), 
                   skipNul=TRUE, encoding = "UTF-8")
  txt <- sapply(txt,function(row) iconv(row, "latin1", "ASCII", sub=""))
  set.seed(1952)
  txt <- txt[rbinom(length(txt)*propSave, length(txt), .5)]
  write.csv(txt, file = paste0("C:/coursera/DataScientist/10-Project/app/subset/", 
                               paste0(txtFile, ".csv")), row.names = FALSE)
}

saveSubset("en_US.blogs.txt", 0.01)
saveSubset("en_US.news.txt", 0.01)
saveSubset("en_US.twitter.txt", 0.01)

#Preprocess the files
#Create corpus
setwd("C:/coursera/DataScientist/10-Project/app")
docs <- Corpus(DirSource("./subset/")) 

#Clean files
docs <- tm_map(docs, removePunctuation)
#Get rid of email chars and other unnecessary stuff
for(j in seq(docs))
{
  docs[[j]] <- gsub("/", " ", docs[[j]])
  docs[[j]] <- gsub("@", " ", docs[[j]])
  docs[[j]] <- gsub("\\|", " ", docs[[j]])
  docs[[j]] <- gsub("-", " ", docs[[j]]  )
}
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, tolower)
#Remove profane words
ProfaneWords <- readLines("ProfaneWords.csv")
docs <- tm_map(docs, removeWords, ProfaneWords)
docs <- tm_map(docs, stripWhitespace)
docs <- tm_map(docs, PlainTextDocument) #Tried to remove this because it's breaking meta
#Make TDM
triGramTokenizer <- function(x) NGramTokenizer(x,Weka_control(min=3,max=3))
tdm <- TermDocumentMatrix(docs,control=list(tokenize=triGramTokenizer))
tdm <- removeSparseTerms(tdm, 0.9)
freqTrigrams <- findFreqTerms(tdm, lowfreq = 4)
#Write to disk
write.csv(freqTrigrams, file = "FreqTerms.csv", row.names = FALSE)
#Make a matrix
mat <- as.matrix(tdm)
#Write matrix out
write.csv(mat, file = "Mat.csv", row.names = TRUE)

