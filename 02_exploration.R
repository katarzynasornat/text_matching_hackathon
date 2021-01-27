library(readr)
library(dplyr)
library(stringr)
library(tm)

cleanedA <- read.delim("precleanedA.txt", sep = "|")
cleanedB <- read.delim("precleanedB.txt", sep = "|")


labels_train <- read.csv("data_hackathon/train.csv")
validation_set <- read.csv("data_hackathon/valid.csv")

joined_train <- labels_train %>% 
  left_join(cleanedA, by = c("ltable_id" = "id")) %>% 
  left_join(cleanedB, by = c("rtable_id" = "id")) 

joined_validation <- validation_set %>% 
  left_join(cleanedA, by = c("ltable_id" = "id")) %>% 
  left_join(cleanedB, by = c("rtable_id" = "id")) 

write.table(joined_train, "joined_train.txt", sep = "|")
write.table(joined_validation, "joined_validation.txt", sep = "|")

# cleanedB %>% filter(str_detect(description_digits_removed,"compressing sql workloads"))
# cleanedB$description_digits_removed <-  gsub(",", " ", cleanedB$description_digits_removed)
# cleanedA$which_group <- 1
# cleanedB$which_group <- 2
# 
# all <- rbind(cleanedA, cleanedB)
# all$desc_without_puct <- stripWhitespace(gsub("[[:punct:]]", "", all$description_digits_removed))
# all$desc_without_puct1 <- stripWhitespace(gsub('\\b\\w{1,2}\\b',"", all$desc_without_puct))
# 
# 
# docs <- Corpus(VectorSource(all$desc_without_puct1))
# toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
# docs <- tm_map(docs, toSpace, "/")
# docs <- tm_map(docs, toSpace, "@")
# docs <- tm_map(docs, toSpace, "\\|")
# 
# # Convert the text to lower case
# docs <- tm_map(docs, content_transformer(tolower))
# # Remove numbers
# docs <- tm_map(docs, removeNumbers)
# # Remove english common stopwords
# docs <- tm_map(docs, removeWords, stopwords("english"))
# # Remove your own stop word
# # specify your stopwords as a character vector
# docs <- tm_map(docs, removeWords, c("blabla1", "blabla2")) 
# # Remove punctuations
# docs <- tm_map(docs, removePunctuation)
# # Eliminate extra white spaces
# docs <- tm_map(docs, stripWhitespace)
# 
# 
# dtm <- TermDocumentMatrix(docs)
# m <- as.matrix(dtm)
# v <- sort(rowSums(m),decreasing=TRUE)
# d <- data.frame(word = names(v),freq=v)
# 
# #install.packages("superml", dependencies=TRUE)
# 
# 
# library(superml)
# 
# # initialise the class
# tfv <- TfIdfVectorizer$new(max_features = 40, remove_stopwords = TRUE, ngram_range = c(1,3))
# 
# # generate the matrix
# tf_mat <- tfv$fit_transform(all$desc_without_puct1)
# 
# 
# barplot(d$freq, las = 2, names.arg = d$word,
#         col ="lightblue", main ="Most frequent words",
#         ylab = "Word frequencies")
