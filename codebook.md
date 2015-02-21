---
title: "codebook"
author: "massuti"
date: "Saturday, February 21, 2015"
output: html_document
---

## R code for getting and cleanind data project 1

### Download and unzip data:
In this code I download and unzip the data, as it is.

```
fileUrl = "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile="gcd_1.zip")
                unzip("gcd_1.zip")
```

And here I read the data, identify data with variables names and name the columns apropriately:

```

var.labels      <- read.table("UCI HAR Dataset/features.txt")
act.labels      <- read.table("UCI HAR Dataset/activity_labels.txt")
testid          <- read.table("UCI HAR Dataset/test/subject_test.txt")
testx           <- read.table("UCI HAR Dataset/test/X_test.txt")
testy           <- read.table("UCI HAR Dataset/test/y_test.txt")
trainid         <- read.table("UCI HAR Dataset/train/subject_train.txt")
trainx          <- read.table("UCI HAR Dataset/train/X_train.txt")
trainy          <- read.table("UCI HAR Dataset/train/y_train.txt")

colnames(testx)         <- var.labels[, 2]
colnames(trainx)        <- var.labels[, 2]
colnames(testy)         <- "actID"
colnames(trainy)        <- "actID"
colnames(testid)        <- "subID"
colnames(trainid)       <- "subID"
colnames(act.labels)    <- c("actID","actType")

```
The names for variables in testx and trainx where extracted from a features.txt file in the zipped data.  

With data readed and named, whe start the code, as requested.  


### 1 Merges the training and the test sets to create one data set.  

Here I united the data, all the test data and all the training data. After that, united them by rows, making a large data file.  
  
```
tests <- cbind(testid, testy, testx)
trains <- cbind(trainid, trainy, trainx)
total <- rbind(tests, trains)

```


### 2 Extracts only the measurements on the mean and standard deviation for each measurement.   

As my data file with total data had the original features.txt variable names, i selected them by using the common characters there for what was needed. In this case, "-mean", "-std" and "ID". The problem was that it would find meanFreq as well, so a negative grep1 was used to solve that, with and AND(&) between -mean and !-meandFreq.  


```
var.names <- colnames(total)

logvect = (grepl("..ID", var.names) | 
                grepl("-mean()..", var.names) & 
                !grepl("-meanFreq()..", var.names) |
                grepl("-std()..", var.names));

finaldata <- total[logvect==TRUE]

```


### 3 Uses descriptive activity names to name the activities in the data set.   

Merging data so that activity names, as Walking(1), would be added to better illustrate. Merged by it`s common variable, 'actID', and merged so that actID would be in the beggining of file.  


```
finaldata = merge(act.labels, finaldata,by="actID",
                  all.x=TRUE)

```


### 4 Appropriately labels the data set with descriptive variable names.   


Renamed all variables using gsub, so that it would be as readable as possible but not as long as it could be. Removed brackets and added some no-so-obvious descriptions for some variables.  


```
var.names  = colnames(finaldata)

for (i in 1:length(var.names)) 
        {
        var.names[i] <- gsub("\\()","",var.names[i])
        var.names[i] <- gsub("-std()","StDev",var.names[i])
        var.names[i] <- gsub("-mean()","Mean",var.names[i])
        var.names[i] <- gsub("^(t)","Time",var.names[i])
        var.names[i] <- gsub("^(f)","Freq",var.names[i])
        var.names[i] <- gsub("([Gg]ravity)","Gravity",var.names[i])
        var.names[i] <- gsub("([Bb]ody[Bb]ody|[Bb]ody)","Body",var.names[i])
        var.names[i] <- gsub("[Gg]yro","Gyro",var.names[i])
        var.names[i] <- gsub("AccMag","AccMagnitude",var.names[i])
        var.names[i] <- gsub("([Bb]odyaccjerkmag)","BodyAccJerkMagnitude",var.names[i])
        var.names[i] <- gsub("JerkMag","JerkMagnitude",var.names[i])
        var.names[i] <- gsub("GyroMag","GyroMagnitude",var.names[i])
        }

colnames(finaldata) <- var.names

```


### 5 From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.   

Created a second data, as tidydata, with means as requested, and wrote it as a new .txt file. Used plyr only for these.  


```
library(plyr)

tidydata <- aggregate(. ~subID + actID, finaldata, mean)
tidydata <- tidydata[order(tidydata$subID,tidydata$actID),]

write.table(tidydata, file = "tidydata.txt",row.name=FALSE)

```

And that`s it, The END

