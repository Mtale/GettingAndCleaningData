
################################################################################

#IMPORT DATASETS TO R; USE THEIR ORIGINAL NAMES IN R

################################################################################

#Labels and features
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", sep="")
features <- read.table("./UCI HAR Dataset/features.txt", sep="")


#Training set
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt", sep="")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt", sep="")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt", sep="")


#Test set
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt", sep="")
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt", sep="")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt", sep="")




################################################################################

#Merge the training and the test sets to create one data set.

################################################################################

#Convert subject-ids to factors
y_train <- factor(y_train[,1])
y_test <- factor(y_test[,1])

#Convert activities to factors
subject_train <- factor(subject_train[,1])
subject_test <- factor(subject_test[,1])


#Merge subject-ids and and activities to training set and 
#create indicator to tell whether a record belongs to training set or not
trainingset <- cbind(subject_id = subject_train, 
                     training_ind = TRUE, 
                     activity = y_train, 
                     X_train)


#Merge subject-ids and and activities to test set and 
#create indicator to tell whether a record belongs to training set or not
testset <- cbind(subject_id = subject_test, 
                 training_ind = FALSE, 
                 activity = y_test, 
                 X_test)

#Append testset to trainingset to single dataset
onedata_temp <- rbind(trainingset, testset)


################################################################################

#Appropriately label the data set with descriptive variable names. 

################################################################################

#Use feature names provided in the dataset to rename features
colnames(onedata_temp)[c(4:564)] <- as.character(features[,2])


#Check the result
names(onedata_temp)



################################################################################

#Use descriptive activity names to name the activities in the data set

################################################################################

#Merge activity labels to dataset 
onedata <- merge(onedata_temp, activity_labels, by.x="activity", by.y="V1")

#--> Watch out, subject_id is no more the first column!!!!


#Check the result --> OK
table(onedata[,1],onedata[,565])


#Rename activity_label column
colnames(onedata)[565] <- "activity_label"



################################################################################

#Extract only the measurements on the mean and standard deviation 
#for each measurement. 

################################################################################

#Exclude the angle values at the end of vector as they are not means
#although the variable names include "mean"
to_exclude <- grep("angle", tolower(features[,2]))


#Extract variables containing means from feature vector.
mean_features <- grep("mean", 
                      tolower(features[which(!features$V1 %in% to_exclude), 2]))


#Extract variables containing stds from feature vector
std_features <- grep("std",
                     tolower(features[which(!features$V1 %in% to_exclude), 2]))


#Concatenate to single vector and sort
means_stds <- sort(c(mean_features, std_features))


#Create dataset containing necessary ids and means and stds of features
onedata_means_stds <- onedata[,c(2:3, 565, means_stds + 3)]





################################################################################

#Create a second, independent tidy data set with 
#the average of each variable for each activity and each subject. 

################################################################################

#Rearrange columns in onedata
onedata <- onedata[,c(2:3, 565, 4:564)]


#Aggregate by computing means of means for each subject-id and activity
temp <- aggregate(onedata[,4:564], 
               by = list(subject_id = onedata[,1],
                         training_ind = onedata[,2],
                         activity_label = onedata[,3]),
               FUN=mean)


#Sort the resulting data
means_by_subject_activity <- temp[order(as.numeric(as.character(temp[,1])), 
                                        temp[,3]), ]


#Check duplicates
length(unique(means_by_subject_activity[, 1:3]))==
        length(means_by_subject_activity[, 1:3])

#Rename columns to avoid confusion with original variables
x <- names(means_by_subject_activity)
y <- c(x[1:3], paste("avg", x[4:564], sep="_")) 
colnames(means_by_subject_activity) <- y

#Remove temporary objects
rm(x,y,temp,onedata_temp)



