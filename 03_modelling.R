to_model <- read.delim("to_model.txt", sep = "|")
to_predict <- read.delim("to_predict.txt", sep = "|")
colnames(to_model)<- gsub("\\.", "_", colnames(to_model))
colnames(to_predict)<- gsub("\\.", "_", colnames(to_predict))


to_model_selected <- to_model %>% mutate(fuzzy_similarity_sorted_tokens_perc = fuzzy_similarity_sorted_tokens/100
                                         , fuzzy_similarity_partial_ratio_perc = fuzzy_similarity_partial_ratio/100
                                         , fuzzy_similarity_perc = fuzzy_similarity/100
                                         , if_years_equal = ifelse(possible_year_x == possible_year_y, 1, 0)) %>%
  select(label
         , fuzzy_similarity_sorted_tokens_perc
         , fuzzy_similarity_partial_ratio_perc
         , len_tokens_x
         , len_tokens_y
         , len_common_tokens
         , common_to_smaller_ratio       
         , common_to_longer_ratio
         , fuzzy_similarity_perc
         , if_years_equal) 

to_predict_selected <- to_predict %>% mutate(fuzzy_similarity_sorted_tokens_perc = fuzzy_similarity_sorted_tokens/100
                                         , fuzzy_similarity_partial_ratio_perc = fuzzy_similarity_partial_ratio/100
                                         , fuzzy_similarity_perc = fuzzy_similarity/100
                                         , if_years_equal = ifelse(possible_year_x == possible_year_y, 1, 0)) %>%
  select(fuzzy_similarity_sorted_tokens_perc
         , fuzzy_similarity_partial_ratio_perc
         , len_tokens_x
         , len_tokens_y
         , len_common_tokens
         , common_to_smaller_ratio       
         , common_to_longer_ratio
         , fuzzy_similarity_perc
         , if_years_equal) 



library(caret)

seeds <- sample(1:10, replace = FALSE)
run_experiments <- function(seeds_ = seeds){
  res_list <- vector(mode = "list", length = length(seeds_))
  for(i in seq_along(seeds_)){
    set.seed(seeds_[i])
    intrain<-createDataPartition(y=to_model_selected$label,p=0.7,list=FALSE)
    training<-to_model_selected[intrain,]
    testing<-to_model_selected[-intrain,]
    
    res_list[[i]][["training"]] <- training
    res_list[[i]][["testing"]] <- testing
    
    model_tmp <- glm(formula = label ~ ., data = training, family = binomial(link = "logit"))
    predictions_tmp <- round(predict(model_tmp, testing[, -c(1)], type = "response"),6)
    
    res_list[[i]][["model"]] <- model_tmp
    res_list[[i]][["fitted_train"]] <- round(model_tmp$fitted.values,6)
    res_list[[i]][["labels_train"]] <- training$label
    res_list[[i]][["labels_test"]] <- testing$label
    res_list[[i]][["predictions"]] <- predictions_tmp
  }
  
  return(res_list)
}




abc <- run_experiments(seeds)



model1 <- glm(formula = label ~ ., data = to_model_selected, family = binomial(link = "logit"))
probabilities_labels <- data.frame(fitted = round(model1$fitted.values, 4), label = to_model_selected$label)


# final predictions
final_predictions <- data.frame(ltable_id = to_predict$ltable_id
           , rtable_id = to_predict$rtable_id
           , label = ifelse(predict(model1, to_predict_selected, type = "response")>0.4,1,0)
           )

write.table(final_predictions, "final_predictions.txt", sep = "|")
