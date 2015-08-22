#setwd("~/DataScientist/Get_Clean_Data/Project")
if(!file.exists("./data")){dir.create("./data")}
    
##Download and unzip folder
fileurlproj <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurlproj, destfile = "./data/smartphones.zip")
unzip("./data/smartphones.zip",exdir="./data")

## Get files
filelist <- list.files(path="./data/UCI HAR Dataset", full.names=TRUE,recursive=TRUE)
filelist

##Read in files
data_act_label  <- read.table(filelist[1],header = FALSE)
data_features <- read.table(filelist[2],header = FALSE)

data_test_subj <- read.table(filelist[14],header = FALSE)
data_xtest <- read.table(filelist[15],header = FALSE)
data_ytest <- read.table(filelist[16],header = FALSE)

data_train_subj <- read.table(filelist[26],header = FALSE)
data_xtrain <- read.table(filelist[27],header = FALSE)
data_ytrain <- read.table(filelist[28],header = FALSE)

## Merge Training and Test
data_subject <- rbind(data_test_subj, data_train_subj)
data_x<- rbind(data_xtest, data_xtrain)
data_y<- rbind(data_ytest, data_ytrain)

## Variable names
names(data_subject)<-c("subject")
names(data_y)<- c("activity")
names(data_x)<- data_features$V2

##Combine data 
data_sub_y_x <- cbind(data_subject, data_y, data_x)

## measurements on the mean and standard deviation only
mean_std<-data_features$V2[grep("mean\\(|std\\(", data_features$V2)]
mean_std
    #Convert factor into a list
    mean_std_list <- as.character(mean_std)
    str(mean_std_list)
Data_mean_std<-subset(data_sub_y_x,select=c("subject", "activity",mean_std_list))
str(Data_mean_std)

##activity names to name the activities in the data set
library(dplyr)
Data_act <- merge(Data_mean_std,data_act_label,by.x="activity", by.y="V1", all=TRUE)
str(Data_act)
Data_act2 <- subset(Data_act,select=c(V2,2:68))
Data_act3 <- rename(Data_act2,activity=V2)

## descriptive variable names
names(Data_act3)<-gsub("^t", "time_", names(Data_act3))
names(Data_act3)<-gsub("^f", "freq_", names(Data_act3))
names(Data_act3)<-gsub("Acc", "accelerometer_", names(Data_act3))
names(Data_act3)<-gsub("Gyro", "gyroscope_", names(Data_act3))
names(Data_act3)<-gsub("Mag", "magnitude_", names(Data_act3))
names(Data_act3)<-gsub("Body", "body_", names(Data_act3))
names(Data_act3)<-gsub("-", "_", names(Data_act3))
names(Data_act3)<-gsub("__", "_", names(Data_act3))
Data_tidy <- Data_act3

##tidy data set with the average of each variable for each activity and each subject
library(plyr)
by_group<- group_by(Data_tidy, subject, activity)
Data_tidy2 <- summarise_each(by_group,funs(mean))
write.table(Data_tidy2,file="./project_data_tidy.txt",row.name=FALSE) 

