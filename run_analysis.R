## R code for getting and cleanind data project 1

#Download and unzip data:

fileUrl = "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile="gcd_1.zip")
                unzip("gcd_1.zip")


#read variables and name columns:

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



#Now with the requested code:
#1 Merges the training and the test sets to create one 
#  data set.


tests <- cbind(testid, testy, testx)
trains <- cbind(trainid, trainy, trainx)
total <- rbind(tests, trains)


#2 Extracts only the measurements on the mean and standard
#  deviation for each measurement. 


var.names <- colnames(total)

logvect = (grepl("..ID", var.names) | 
                grepl("-mean()..", var.names) & 
                !grepl("-meanFreq()..", var.names) |
                grepl("-std()..", var.names));

finaldata <- total[logvect==TRUE]


#3 Uses descriptive activity names to name the activities
#  in the data set


finaldata = merge(act.labels, finaldata,by="actID",
                  all.x=TRUE)


#4 Appropriately labels the data set with descriptive 
#  variable names. 


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


#5 From the data set in step 4, creates a second, 
#  independent tidy data set with the average of each variable 
#  for each activity and each subject.


library(plyr)

tidydata <- aggregate(. ~subID + actID, finaldata, mean)
tidydata <- tidydata[order(tidydata$subID,tidydata$actID),]

write.table(tidydata, file = "tidydata.txt",row.name=FALSE)



