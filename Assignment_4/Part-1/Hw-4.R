# Install
install.packages("tm")  # for text mining
install.package("SnowballC") # for text stemming
install.packages("wordcloud") # word-cloud generator 
install.packages("RColorBrewer") # color palettes
install.packages("superbiclust")
install.packages("cluster")
install.packages("igraph")
install.packages("fpc")

library(tm)
library(SnowballC)
library(RColorBrewer)
library(ggplot2)
library(wordcloud)
library(superbiclust)
library(cluster)
library(igraph)
library(fpc)
install.packages("Rcampdf", repos = "http://datacube.wu.ac.at/", type = "source")
cname <- file.path("C:/Users/zhaos/Desktop","texts")
dir(cname)

# Load the data as a corpus
library(tm)
docs <- Corpus(DirSource(cname))
summary(docs)

docs <- tm_map(docs,removePunctuation)

##remove the numbers
docs <- tm_map(docs,removeNumbers)

##convert to lowercase
docs <- tm_map(docs,tolower)

##remove "stopwords"
docs <- tm_map(docs,removeWords,stopwords("english"))

## Remove your own stop word
docs <- tm_map(docs,removeWords,c("balabala","yoyo"))


##Removing common word endings (e.g., "ing", "es", "s")
docs <- tm_map(docs,stemDocument)
##Stripping unnecesary whitespace from your documents
docs <- tm_map(docs,stripWhitespace)
docs <- tm_map(docs,PlainTextDocument)

##create a document term matrix
dtm <- DocumentTermMatrix(docs)
dtm
tdm <- TermDocumentMatrix(docs)
tdm

##explore the data
freq <- colSums(as.matrix(dtm))
length(freq)
#sort the word according to the frequence
ord <- order(freq)

##export the matrix to Excel
m <- as.matrix(dtm)
dim(m)
write.csv(m,file="dtm.csv")

##remove sparse terms
dtms <- removeSparseTerms(dtm,0.1)
inspect(dtms)


##word frequency
freq[head(ord)]
freq[tail(ord)]
head(table(freq),20)
tail(table(freq),20)

freq <- colSums(as.matrix(dtms))
freq


freq <- sort(colSums(as.matrix(dtm)),decreasing = TRUE)
head(freq,14)

findFreqTerms(dtm, lowfreq = 300)

wf <- data.frame(word=names(freq),freq=freq)
head(wf)

##plot word frequencies
library(ggplot2)
p <- ggplot(subset(wf,freq>500),aes(word,freq))
p <- p + geom_bar(stat="identity")
p <- p + theme(axis.text.x = element_text(angle=45, hjust=1))
p
##specifying a correlation limit of 0.98
findAssocs(dtm, c("heaven", "arm"),corlimit = 0.98)
findAssocs(dtms, "contract",corlimit = 0.90)

library(wordcloud)
set.seed(142)
wordcloud(names(freq),freq,min.freq = 250)

set.seed(142)
wordcloud(names(freq),freq,max.words = 100)

#Assignment different color on the word frequence map
set.seed(142)
wordcloud(names(freq),freq,min.freq=250, scale=c(5, .1),colors=brewer.pal(6, "Dark2"))

set.seed(142)
dark2 <- brewer.pal(6, "Dark2")
wordcloud(names(freq),freq, max.words = 100, rot.per = 0.2, colors=dark2)

dtmss <- removeSparseTerms(dtm, 0.15)
inspect(dtmss)

library(cluster)
d <- dist(t(dtmss), method="euclidian")
fit <- hclust(d=d, method="ward.D")
plot(fit,hang=-1)

plot.new()
plot(fit,hang = -1)
groups <- cutree(fit,k=5)
rect.hclust(fit,k=5,border="red")

library(fpc)
d <- dist(t(dtmss),method="euclidian")
kfit <- kmeans(d,2)
clusplot(as.matrix(d),kfit$cluster,color=T,shade=T,labels=2,lines=0)




