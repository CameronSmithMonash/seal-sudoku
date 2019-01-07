source("user_counts.R")

# split into experts and non-experts
expert = user_counts[which(user_counts$expert == TRUE), c("imagefile", "user_anonymised", "counts")]
non_expert = user_counts[which(user_counts$expert == FALSE), c("imagefile", "user_anonymised", "counts")]


# each expert image
expert_images_list = unique(expert$imagefile)


# standard deviation for counts of image
image = c()
num_of_classification = c()
mean = c()
standard_deviation = c()
fractional_standard_deviation = c()
for(img in expert_images_list){
  counts = expert[which(expert$imagefile == img),"counts"] # counts for each classificaiton of img
  if (length(counts) > 0){
    image = c(image, img)
    mean = c(mean, mean(counts))
    standard_deviation = c(standard_deviation, sd(counts))
    fractional_standard_deviation = c(fractional_standard_deviation, sd(counts)/mean(counts))
    num_of_classification = c(num_of_classification, length(counts))
  }
}
# create a dataframe for expert statistics
expert_statistics = data.frame(image,num_of_classification, mean, standard_deviation, fractional_standard_deviation)


# calcualte average fractional standard deviation for non-zero expert statistics
non_zero_expert_statistics = expert_statistics[rowSums(is.na(expert_statistics)) == 0,]
average_fractional_standard_deviation = mean(non_zero_expert_statistics$fractional_standard_deviation)
print("Average fractional standard deviation (sd/mean) is: ")
cat(average_fractional_standard_deviation)


# find percentage user_score for each user compared to expert mean
# if user counted more then expert mean, assume correct counting
user = unique(user_counts$user_anonymised)
user_score = c()
number_of_classifications = c()
for(usr in user){
  counts = user_counts[(which(user_counts$user_anonymised == usr)),]
  user_user_scores = c()
  for(i in 1:nrow(counts)){
    current_img = counts$imagefile[i]
    if(current_img %in% expert_statistics$image){ # if image has been classified by at least one expert
      current_count = counts$counts[i]
      expert_mean = expert_statistics$mean[which(expert_statistics$image == current_img)]
      if(expert_mean != 0){
        current_user_score = 100*abs(expert_mean - current_count)/expert_mean # percentage that the count varies from the expert mean
      } else{
        current_user_score = 100*current_count
      }
      user_user_scores = c(user_user_scores, current_user_score)
    }
  }
  # if the number of classifications that experts have also is less than 30, set the user_score to 100%
  user_number_of_classifications = sum(user_counts$user_anonymised == usr)
  number_of_classifications = c(number_of_classifications, user_number_of_classifications)
  if(length(user_user_scores) < 30){
    mean_user_score = 100
  } else{
    mean_user_score = mean(user_user_scores)
  }
  user_score = c(user_score, mean_user_score)
}


# find images that were classified once, and by a non expert
images = unique(user_counts$imagefile)
unique_count = rep(0,length(user)) # count of number of unique images classified by user
image_list = list()
for(img in images){
  occurences = which(user_counts$imagefile == img)
  if(length(occurences) == 1){ # if image occurs once
    index = which(user == user_counts$user_anonymised[occurences])
    unique_count[index] = unique_count[index] + 1
    if(length(image_list) < index){
      image_list[[index]] = img
    } else{
      image_list[[index]] = c(image_list[[index]], img)
    }
  }
}


# put into dataframe and sort based on user_score
user_accuracy = data.frame(user, number_of_classifications, user_score, unique_count)
user_accuracy = user_accuracy[order(user_accuracy$user_score),]



# % of number classifications by users who classified less than 30 images
percentage_less_than_30 = sum(user_accuracy$number_of_classifications[user_accuracy$number_of_classifications < 30])/sum(user_accuracy$number_of_classifications)



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

# sort based on user_score
useful_user_accuracy = useful_user_accuracy[order(useful_user_accuracy$user_score),]

# write to csv
write.csv(useful_user_accuracy, file = "user_rankings.csv",row.names=FALSE)
