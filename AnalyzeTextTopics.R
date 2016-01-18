#Simulate generating words from DTM to TDM in CreateTrigrams
rm(list=ls())
require(tm); require(topicmodels); require(ggplot2)

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

saveSubset("en_US.blogs.txt", 0.09)
saveSubset("en_US.news.txt", 0.09)
saveSubset("en_US.twitter.txt", 0.09)

#Preprocess the files
#Create corpus
setwd("C:/coursera/DataScientist/10-Project/app")
docs <- Corpus(DirSource("./subset/")) 

#Motivation comes from following
# https://eight2late.wordpress.com/2015/09/29/a-gentle-introduction-to-topic-modeling-using-r/
#   A gentle introduction to topic modeling using R
docs <- tm_map(docs, content_transformer(tolower))
toSpace <- content_transformer(function(x, pattern)
    {
    return (sub(pattern, " ", x))
  })
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, "'")
docs <- tm_map(docs, toSpace, ".")
docs <- tm_map(docs, removePunctuation)
docs <- tm_map(docs, removeNumbers)
docs <- tm_map(docs, removeWords, stopwords("english"))
#Remove profane words
docs <- tm_map(docs, stripWhitespace)
ProfaneWords <- readLines("ProfaneWords.csv")
docs <- tm_map(docs, removeWords, ProfaneWords)
#Create a DTM
dtm <- DocumentTermMatrix((docs))
rownames(dtm) <- c("blogs", "news", "twitter")
freq <- sort(colSums(as.matrix(dtm)), decreasing=TRUE)
write.csv(freq, file = "WordFreq.csv")

#Following is motivated by url below
#http://stats.stackexchange.com/questions/25113/the-input-parameters-for-using-latent-dirichlet-allocation
best.model <- lapply(seq(3,15, by=3), function(k){LDA(dtm, k)})
best.model.logLik <- as.data.frame(as.matrix(lapply(best.model, logLik)))
best.model.logLik.df <- data.frame(topics=c(3, 6, 9, 12, 15),
    LL=as.numeric(as.matrix(best.model.logLik)))

png("Topics.png")
ggplot(best.model.logLik.df, aes(x=topics, y=LL)) +
  xlab("Number of topics") + ylab("Log likelihood of the model") +
  geom_line() +
  theme_bw() 
#dev.copy(png,'Topics.png')
dev.off()

#Plot above indicates 6 topics
best.model.logLik.df[which.max(best.model.logLik.df$LL),]
# topics        LL
# 2      6 -27065909
lda_Internet <- LDA(dtm, 6) # generate the model with 6 topics
get_terms(lda_Internet, 5) # gets 5 keywords for each topic, just for a quick look
# Topic 1  Topic 2 Topic 3 Topic 4 Topic 5 Topic 6
# [1,] "just"   "one"   "said"  "will"  "day"   "one"  
# [2,] "like"   "can"   "will"  "much"  "can"   "use"  
# [3,] "thanks" "time"  "year"  "can"   "now"   "like" 
# [4,] "love"   "just"  "can"   "just"  "get"   "may"  
# [5,] "will"   "will"  "one"   "like"  "good"  "get"  
get_topics(lda_Internet, 5) # gets 5 topic numbers per document
# blogs news twitter
# [1,]     2    3       1
# [2,]     4    4       5
# [3,]     6    6       6
# [4,]     5    5       4
# [5,]     3    1       2
