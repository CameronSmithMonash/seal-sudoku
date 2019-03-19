source("user_counts.R")
# split into experts and non-experts
expert = user_counts[which(user_counts$expert == TRUE), c("imagefile", "user_anonymised", "counts")]
non_expert = user_counts[which(user_counts$expert == FALSE), c("imagefile", "user_anonymised", "counts")]


# for each image, find classifications by experts and find standard deviation and mean
images = unique(user_counts$imagefile)
expert_images = c()
expert_classifications = list()
expert_sd = c()
num_of_expert_classification = c()
expert_mean = c()
i = 1
for(img in images){
  expert_counts = expert$counts[which(expert$imagefile == img)]
  if(length(expert_counts) > 0){
    expert_images = c(expert_images, img)
    expert_classifications[[i]] = expert_counts
    num_of_expert_classification = c(num_of_expert_classification, length(expert_counts))
    expert_mean = c(expert_mean, mean(expert_counts))
    expert_sd = c(expert_sd, sd(expert_counts))
    i = i + 1
  }
}
# add everything to a dataframe
image_counts = data.frame(expert_images)
image_counts$expert_classifications = expert_classifications
image_counts$expert_sd = expert_sd
image_counts$expert_mean = expert_mean
image_counts$num_of_expert_classification = num_of_expert_classification


# find recall, precision and f1 score (harmonised mean of recall and precision)
user = unique(non_expert$user_anonymised) # list of users
user_recall = c() # true positives / true positives + false negatives
user_precision = c() # true positives / true positives + false negatives
user_f1_score = c() # 2*(precision*recall)/(precision + recall)
number_of_classifications = c()
for(usr in user){
  true_positive_count = 0 # seals correctly identified
  false_positive_count = 0 # not a seal, but incorrectly identified as one
  false_negative_count = 0 # seals not identified
  counts = user_counts[(which(user_counts$user_anonymised == usr)),]
  expert_classification_count = 0 # number of classifications that have also been done by an expert
  for(i in 1:nrow(counts)){
    current_img = counts$imagefile[i]
    if(current_img %in% image_counts$expert_images){ # if image has been classified by at least one expert
      expert_classification_count = expert_classification_count + 1
      
      current_count = counts$counts[i]
      # find minimum expert count 
      expert_min = min(image_counts$expert_classifications[[which(image_counts$expert_images == current_img)]])
      # find maximum expert count
      expert_max = max(image_counts$expert_classifications[[which(image_counts$expert_images == current_img)]])
      
      if(current_count >= expert_min & current_count <= expert_max){
        true_positive_count = true_positive_count + current_count # number of seals identified (correctly)
      }
      else if (current_count < expert_min){
        true_positive_count = true_positive_count + current_count # add number of seals correctly identified
        false_negative_count = false_negative_count + (expert_min - current_count) # add number of seals not identified
      }
      else if (current_count > expert_max){
        true_positive_count = true_positive_count + expert_max # add number of seals correctly identified
        false_positive_count = false_positive_count + (current_count - expert_max) # number of times a seal was identified but wasn't there
      }
      else{
        warning("problem")
      }
    }

  }
  recall = true_positive_count/(true_positive_count + false_negative_count)
  user_recall = c(user_recall, recall)
  precision = true_positive_count/(true_positive_count + false_positive_count)
  user_precision = c(user_precision, precision)
  
  number_of_classifications = c(number_of_classifications, sum(user_counts$user_anonymised == usr))
  # if the number of classifications that experts have also is less than 20, set the f1 score to 0
  if(expert_classification_count < 20){
    f1_score = 0
  } else{
    f1_score = 2*(precision*recall)/(precision + recall)
  }
  user_f1_score = c(user_f1_score, f1_score)
}

# plot user_f1_score
hist(user_f1_score, xlab = "F1 Score", ylab = "Number of Users", main = "Histogram of user F1 Scores")
percentage_less_than_20 = sum(number_of_classifications < 20)/sum(number_of_classifications)


# add expert stats
user = c(user, unique(expert$user_anonymised))
for(usr in unique(expert$user_anonymised)){
  number_of_classifications = c(number_of_classifications, sum(user_counts$user_anonymised == usr))
}
user_f1_score = c(user_f1_score, rep(1, length(unique(expert$user_anonymised))))


# put into dataframe and sort based on user_f1_score
user_accuracy = data.frame(user, number_of_classifications, user_f1_score)
user_accuracy = user_accuracy[order(-user_accuracy$user_f1_score),]


# find number of "new" images for each user (images that haven't been classified by someone with a higher accuracy)
classified_images = c()
useful_image_count = c()
for(user in user_accuracy$user){
  user_images = user_counts$imagefile[user_counts$user_anonymised == user]
  user_useful_image_count = 0
  for(image in user_images){
    if(!(image %in% classified_images)){
      classified_images = c(classified_images, image)
      user_useful_image_count = user_useful_image_count + 1
    }
  }
  useful_image_count = c(useful_image_count, user_useful_image_count)
}
#add to dataframe
user_accuracy$useful_image_count = useful_image_count

# sort based on new image count
user_accuracy = user_accuracy[order(-user_accuracy$useful_image_count),]

# exclude user who did not make any useful classifications
useful_user_accuracy = user_accuracy[user_accuracy$useful_image_count != 0,]

# sort based on user_f1_score
user_accuracy = user_accuracy[order(-user_accuracy$user_f1_score),]
useful_user_accuracy = useful_user_accuracy[order(-useful_user_accuracy$user_f1_score),]


# write to csv
write.csv(useful_user_accuracy, file = "useful_user_rankings.csv",row.names=FALSE)
write.csv(user_accuracy, file = "all_user_rankings.csv",row.names=FALSE)
