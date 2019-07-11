library(dplyr)

### Load feature names
feature_names = read.table("UCI HAR Dataset/features.txt")

### Load label names
activity_names = read.table("UCI HAR Dataset/activity_labels.txt")
colnames(activity_names) = c("labels","activity")

### Read  test data set files
test_set <- read.table("UCI HAR Dataset/test/X_test.txt")
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt")
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")

test_set$labels <- test_labels$V1
test_set$subject <- test_subject$V1

### Read train data set files
training_set <- read.table("UCI HAR Dataset/train/X_train.txt")
training_labels <- read.table("UCI HAR Dataset/train/y_train.txt")
training_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")

training_set$labels <- training_labels$V1
training_set$subject <- training_subject$V1

### Merge files together to create a unique set
merged_set <- rbind(test_set, training_set)

### Add meaningfull column headers from the features.txt table
colnames(merged_set) <- c(as.character(feature_names$V2), "labels","subject")

### Extract columns with mean and standard deviation of each measurement only
column_of_interest <- c("subject","labels",
                        grep("mean\\(\\)|std\\(\\)",as.character(feature_names$V2), value = TRUE)
                         )

merged_set <- merged_set[,column_of_interest]

### Create a long skinny table where each of the measurement columns is in  variable colmun
merged_set <- merged_set %>%
    ### Pivot the table to use the column names as a Variable column
    tidyr::gather("Variable","Value", 3:ncol(merged_set))

### Uses descriptive activity names to name the activities in the data set
merged_set <- merged_set %>%
    dplyr::left_join(activity_names, by = "labels")

### Appropriately labels the data set with descriptive variable names.
### Here I decided to split the Variable in multiple columns just to play a bit with 
### the idea of having multiple ways of filtering and subsetting the data.

merged_set_c <- merged_set %>%
### Parse the different information in the Variable column into individual columns
dplyr::mutate(signal_origin = ifelse(grepl("Body", Variable),"Body", "Gravity"),
              sensor = ifelse(grepl("Acc", Variable), "Accelerometer", "Gyroscope"),
              signal_domain = ifelse(grepl("^t", Variable), "Time domain","Frequency domain"),
              signal_subtype = (ifelse(grepl("Jerk", Variable), "Jerk","")),
              axis = sub(".*([XYZ]$|Mag).*", "\\1", Variable),
              stat = ifelse(grepl("mean",Variable),"Mean","Standard_deviation")) %>%
    # Add rowid to overcome error in tidyr when trying to spread to separate Mean and std in two separate columns
    tibble::rowid_to_column("rowid") %>%
    ### Remove the Variable column that contains all the mixed info
    ### Also remove the labels column as now we have a column with activity which is more descriptive
    dplyr::select(-Variable,-labels) %>%
    ### Spread the Mean and Standard deviation column to two separate columns
    tidyr::spread(stat,Value )


### From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_set <- merged_set_c %>% 
    dplyr::group_by(subject,activity, signal_origin, sensor, signal_domain, signal_subtype, axis) %>%
    dplyr::summarise(AverageOfMeans = mean(Mean, na.rm = TRUE),
                     AverageofStd = mean(Standard_deviation, na.rm = TRUE))

### Store the tidy set into a new file
write.table(tidy_set, "tidy_data.txt", row.name=FALSE)
