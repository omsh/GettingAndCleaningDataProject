setwd("~/Rdirectory/GettingAndCleaningData/W4/UCI HAR Dataset")
library(dplyr)

#  Loading the training dataset
# 3 columns          (subject_train.txt, y_train.txt, X_train.txt) [X_train has 561 columns] 
# store in variables (subjectId, activity, trainingSetData)

subjectId <- read.table("./train/subject_train.txt")
names(subjectId) <- c("subject_id")

activity <- read.table("./train/y_train.txt")
names(activity) <- c("activity_id")

trainingSetData <- read.table("./train/X_train.txt")

# variables names for the 561 columns changed to "TRS" training set data

names(trainingSetData) <- sub("V", "TRS", names(trainingSetData))


#  Loading the test dataset

# 3 columns          (subject_test.txt, y_test.txt, X_test.txt) [X_test has 561 columns] 
# store in variables (subjectIdtest, activityTest, testSetData)

subjectIdtest <- read.table("./test/subject_test.txt")
names(subjectIdtest) <- c("subject_id")

activityTest <- read.table("./test/y_test.txt")
names(activityTest) <- c("activity_id")

testSetData <- read.table("./test/X_test.txt")

# variables names for the 561 columns changed to "TSS" test set data

names(testSetData) <- sub("V", "TSS", names(testSetData))


# Load feature descriptions in order to determine the ones that are mean() and std()
features <- read.table("./features.txt")
names(features) <- c("index", "description")

# Find the features with description mean() or std() and store the indices
requiredIndicies <- grep("mean|std", features$description)

# Selecting the relevant columns only (the mean and std values)

trTbl <- tbl_df(trainingSetData)
meanStdTrainingData <- select(trTbl, requiredIndicies)

tsTbl <- tbl_df(testSetData)
meanStdTestData <- select(tsTbl, requiredIndicies)

# Set the names of the selected columns to the respective feature names
names(meanStdTrainingData) <- features$description[requiredIndicies]
names(meanStdTestData) <- features$description[requiredIndicies]

# create a data frame with the filtered training data
traindf <- data.frame(subjectId, activity, meanStdTrainingData)

# create a data frame with the filtered test data
testdf <- data.frame(subjectIdtest, activityTest, meanStdTestData)

# Merge both data frames by binding the rows, 
# Both data frames have the same column names now 
# (subject_id, activity, 79 selected features..)  = total 81 columns

mergeddf <- rbind(traindf, testdf)

mergedTbl <- tbl_df(mergeddf)


# Aggregate the values of the selected features over each subject and each activity

tidyDataSet <- aggregate.data.frame(mergedTbl, 
                            by = list(mergedTbl$subject_id, mergedTbl$activity_id),
                            FUN = mean)

# Remove the grouping columns introduced by the aggregate function

tidyDataSet <- select(tidyDataSet, -Group.1, -Group.2)

# Read Activity Names

activities <- read.table("./activity_labels.txt")
names(activities) <- c("activity_id", "activity_name")

# Add one column indicating activity names
# We do this by merging the tidy data set with the activities data frame

tidyDataSet <- merge(activities, tidyDataSet, by = "activity_id")

# If we want to remove the activity_id column completely, we run:
# (If we want to keep it for reference, we can skip the next line)

tidyDataSet <- select(tidyDataSet, -activity_id)

# write the new data set to a text file

write.table(tidyDataSet, file = "Dataset.txt")

