###Creation of tidy datasets for the Coursera class Getting and Cleaning Data


The R script *run_analysis.R* provided in the Github repository creates two tidy datasets:

* *onedata_means_stds*
* *means_by_subject_activity*.

The former contains measurements on the mean and standard deviation for each measurement, the latter contains average of each variable for each activity and each subject. Both datasets include both training and test sets, the origin of a record is told with incicator *training_ind* which is TRUE if subject belongs to training set.

This README file provides further information on how the R script creates the tidy datasets; the one most important thing is that the following six steps are run in order to create both tidy datasets.

<br><br>
  
####Step 1 - Import datasets into R using their original names in R

The datasets found on the following website are imported into R. Created R Objects preserve the names of the original files to ensure original ones can be identified easily.

Data Source: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones


```
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
```

<br><br>


####Step 2 - Merge the training and the test sets to create one data set.

Training and test sets are merged into single dataset. An indicator to tell whether a subject belongs to the training set is created on the fly.


```
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
```

<br><br>


####Step 3 - Appropriately label the data set with descriptive variable names. 

The variables in the dataset *onedata_temp* are renamed using features vector provided in the original data. Features start from the column 4 as the first three columns are *subject_id*, *training_ind* and *activity*.


```
#Use feature names provided in the dataset to rename features
colnames(onedata_temp)[c(4:564)] <- as.character(features[,2])

#Check the result
names(onedata_temp)
```

<br><br>

####Step 4 - Use descriptive activity names to name the activities in the data set

Activities described as numeric codes are replaced with activity labels.
It should be taken into account later that **merge()** places the by-column first in the output dataset.  

```
#Merge activity labels to dataset 
onedata <- merge(onedata_temp, activity_labels, by.x="activity", by.y="V1")

#--> Watch out, subject_id is no more the first column!!!!

#Check the result --> OK
table(onedata[,1],onedata[,565])

#Rename activity_label column
colnames(onedata)[565] <- "activity_label"
```

<br><br>

####Step 5 - Extract only the measurements on the mean and standard deviation for each measurement. 

Measurements on the mean and standard deviation are found by searching the words "mean" and "std" from the features vector. However, the last 7 features are not means although their labels contain the work "mean", hence they are excluded from the output.

```
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
```



<br><br>

#### Step 6 - Create a second, independent tidy data set with the average of each variable for each activity and each subject. 

A tidy dataset containing the average of each variable for each activity and each subject is created using **aggregate()**. The result is checked by comparing the length of unique values of variable combination *subject_id*, *training_ind*, *activity_label* to the length of their non-unique values. As the result is TRUE, there is no duplicates. At last, variables are renamed to avoid confusion with original variables.

```
#Rearrange columns in onedata
onedata <- onedata[,c(2:3, 565, 4:564)]


#Aggregate by computing means of means for each subject-id and activity
temp <- aggregate(onedata[,4:564], 
               by = list(subject_id = onedata[,1],
                         training_ind = onedata[,2],
                         activity_label = onedata[,3]),
               FUN=mean)


#Sort the resulting data
means_by_subject_activity <- temp[order(as.numeric(as.character(temp[,1])), temp[,3]), ]


#Check duplicates
length(unique(means_by_subject_activity[, 1:3]))==length(means_by_subject_activity[, 1:3])

#Rename columns to avoid confusion with original variables
x <- names(means_by_subject_activity)
y <- c(x[1:3], paste("avg", x[4:564], sep="_")) 
colnames(means_by_subject_activity) <- y

#Remove temporary objects
rm(x,y,temp,onedata_temp)

```

<br><br>

####Extract and import  tidy datasets

The created tidy datasets can be extracted as tab-delimited txt-files with the following lines of R code.
  
```
write.table(onedata_means_stds, "onedata_means_stds.txt", sep="\t", row.names=FALSE)
write.table(means_by_subject_activity, "means_by_subject_activity.txt", sep="\t", row.names=FALSE)
```

  
The txt-files can be imported into R  with the following lines of R code.

```
data1 <- read.table("onedata_means_stds.txt", header=TRUE, sep="\t")
data2 <- read.table("means_by_subject_activity.txt", header=TRUE, sep="\t")
```