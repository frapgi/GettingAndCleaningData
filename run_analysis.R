#Reshape lets you flexibly restructure and aggregate data using just two functions: melt and cast.
library(reshape2) 

filename <- "getdata_dataset.zip" 
## Download and unzip the data 

if (!file.exists(filename)){ 
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip " 
  download.file(fileURL, filename, mode="wb") 
}   
if (!file.exists("UCI HAR Dataset")) {  
  unzip(filename)  
} 

# charge activity, labels, features 

AcLabels <- read.table("UCI HAR Dataset/activity_labels.txt") 
AcLabels[,2] <- as.character(AcLabels[,2]) 

features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2]) 

#Extract mean and standard deviation

FeaturesSelected <- grep(".*mean.*|.*std.*", features[,2]) 
FeaturesSelected.names <- features[FeaturesSelected,2] 
FeaturesSelected.names = gsub('-mean', 'Mean', FeaturesSelected.names) #'-mean'is replaced by 'Mean'
FeaturesSelected.names = gsub('-std', 'Std', FeaturesSelected.names) 
FeaturesSelected.names <- gsub('[-()]', '', FeaturesSelected.names) 

# Load the datasets 
train <- read.table("UCI HAR Dataset/train/X_train.txt")[FeaturesSelected] 
TActivities <- read.table("UCI HAR Dataset/train/Y_train.txt") 
TSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt") 
train <- cbind(TSubjects, TActivities, train) 

test <- read.table("UCI HAR Dataset/test/X_test.txt")[FeaturesSelected] 
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt") 
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt") 
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels 
Datos <- rbind(train, test) 
colnames(Datos) <- c("subject", "activity", FeaturesSelected.names) 


# turn activities & subjects into factors 
Datos$activity <- factor(Datos$activity, levels = AcLabels[,1], labels = AcLabels[,2]) 
Datos$subject <- as.factor(Datos$subject) 

Datos.melted <- melt(Datos, id = c("subject", "activity")) 
Datos.mean <- dcast(Datos.melted, subject + activity ~ variable, mean) 

write.table(Datos.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
