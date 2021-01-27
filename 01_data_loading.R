library(reshape2)
library(stringr)


prepare_dataframe_from_file <- function(filepath){

  df = readLines(filepath)
  df1 = df[-1]
  df2 = data.frame(full_citation = df1)
  rm(df)
  rm(df1)
  
  # getting id
  df_transformed <- colsplit(df2$full_citation, ",", c("id","description"))
  
  # removing .0 from potential publication year value
  df_transformed$description <- str_remove(df_transformed$description, "\\.0")
  
  # getting all digits from string to find a year of publication if exists
  all_digits_from_text <- str_extract_all(df_transformed$description, "[[:digit:]]+") #returns all the pieces which match the pattern of having only digits
  how_many_digit_pieces <- sapply(all_digits_from_text, length) #information if we got more than one year-suspected value
  collapsed_digits_expressions <- sapply(seq_along(all_digits_from_text), function(x) paste(all_digits_from_text[x][[1]], collapse = "|"))
  
  df_transformed$possible_year <- collapsed_digits_expressions
  df_transformed$all_digits_pieces_from_text <- how_many_digit_pieces 
  df_transformed$description_digits_removed <- gsub("\\d", " ", df_transformed$description) # remove digits from further text
  df_transformed$desc_without_puct <- trimws(stripWhitespace(gsub("[[:punct:]]", " ", df_transformed$description_digits_removed)))
  
  df_transformed$short_words_removed <- trimws(stripWhitespace(gsub('\\b\\w{1,2}\\b','',df_transformed$desc_without_puct)))
  
  return(df_transformed)
  
}


precleaned_dataA <- prepare_dataframe_from_file("data_hackathon/tableA.txt")
precleaned_dataB <- prepare_dataframe_from_file("data_hackathon/tableB.txt")


# library(tm)
# docs <- Corpus(VectorSource(precleaned_dataA$description_digits_removed))
# docs <- tm_map(docs, content_transformer(tolower))
# docs <- tm_map(docs, removePunctuation)
# dtm <- TermDocumentMatrix(docs)
# m <- as.matrix(dtm)
# v <- sort(rowSums(m),decreasing=TRUE)
# d <- data.frame(word = names(v),freq=v)
# head(d, 10)

write.table(precleaned_dataA, "precleanedA.txt", sep = "|")
write.table(precleaned_dataB, "precleanedB.txt", sep = "|")





