classifications = read.csv("20181115-sealSpotter_classifications_anonymised.csv")

#removes factors which caused it to slow down
classifications$imagefile = as.character(classifications$imagefile)

# data frame of unique users, expert status, number of false matches, number of correct matches, accuracy
accuracy_data = unique(classifications[c("user_anonymised","expert")])
accuracy_data$false_count = rep(0,length(accuracy_data$user_anonymised))
accuracy_data$true_count = rep(0,length(accuracy_data$user_anonymised))
accuracy_data$accuracy = rep(0,length(accuracy_data$user_anonymised))

# sort based on user ID
accuracy_data = accuracy_data[order(accuracy_data$user_anonymised),]

# dataframe of user ids, expert status, imagefile and type
image_classifications = classifications[c("user_anonymised","expert","imagefile", "type")]

#sort based on user ID
image_classifications = image_classifications[order(image_classifications$user_anonymised),]

# sorting based on imagefile
image_classifications = image_classifications[order(image_classifications$imagefile),]

# split into experts and non-experts
expert_split = split(image_classifications, factor(image_classifications$expert))

expert = expert_split$"TRUE"

non_expert = expert_split$"FALSE"


# expert counts for each image
images = unique(classifications["imagefile"])
counts = rep(-1, length(images$imagefile))

expert_image_counts = data.frame(images,counts)


# initialisations
current_user = expert$user_anonymised[1]
current_image = expert$imagefile[1]
count = 0
counts = c()
for(i in 1:(length(expert$user_anonymised))){
  # if next user is different
  if(expert$user_anonymised[i] != current_user){
    current_user = expert$user_anonymised[i]
    counts = c(count,counts)
    count = 0
  }
  
  # if next image is different
  if(current_image != expert$imagefile[i]){
    counts = unique(c(count, counts))
    if(length(counts) == 1){
      image_index = which(expert_image_counts$imagefile == current_image)
      expert_image_counts$counts[image_index] = counts
    }
    current_image = expert$imagefile[i]
    count = 0
    counts = c()
  }
  
  # if the tyoe is "zerocount"
  if(expert$type[i] == "zerocount"){
    counts = c(0, counts)
  }
  
  # if there is a seal identified
  else{
    if(expert$type[i] != "comment"){
      count = count + 1
    }
  }
}


# non expert true/false counts 
current_user = non_expert$user_anonymised[1]
current_image = non_expert$imagefile[1]
count = 0
for(i in 1:(length(non_expert$user_anonymised))){
  # if next user is different or next image is different
  if((non_expert$user_anonymised[i] != current_user) |(current_image != non_expert$imagefile[i])){
    image_index = which(expert_image_counts$imagefile == current_image)
    # if there was an expert count
    if(expert_image_counts$counts[image_index] != -1){
      # if the count was correct
      if(expert_image_counts$counts[image_index] == count){
        accuracy_data$true_count[current_user] = accuracy_data$true_count[current_user] + 1
      }
      # if the count was not correct
      else{
        accuracy_data$false_count[current_user] = accuracy_data$false_count[current_user] + 1
      }
    }
    current_user = non_expert$user_anonymised[i]
    current_image = expert$imagefile[i]
    count = 0
  }
}

# calculate accuracy
for(i in 1:length(accuracy_data$user_anonymised)){
  # if expert, set accuracy to 1
  if(accuracy_data$expert[i]){
    accuracy_data$accuracy[i] = 1
  }
  # if not expert, calculate accuracy
  else{
    total = accuracy_data$false_count[i]+accuracy_data$true_count[i]
    if(total > 0){
      accuracy_data$accuracy[i] = accuracy_data$true_count[i]/total
    }
  }
}


#sort based on True Count
accuracy_data = accuracy_data[order(-accuracy_data$true_count),]

# sort based on accuracy
accuracy_data = accuracy_data[order(-accuracy_data$accuracy),]

#sort based on expert
accuracy_data = accuracy_data[order(-accuracy_data$expert),]

# write to csv
write.csv(accuracy_data, file = "user_accuracy.csv",row.names=FALSE)
