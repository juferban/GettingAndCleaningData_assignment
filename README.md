#Code and results file from the final assignment on the Getting and Cleaning Data course

##Steps to generate the final tidy_data.txt:

1- Download the files containing the raw data from:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

2- Unzip the file in the same folder as your run_analysis.R code.

3- Run the code un run_analysis.R code

4- The tidy_data.txt file will be written in the same folder as your run_analysis.R script


## Description of the run_analysis.R
1- Merges the training and test sets into a single dataset
2- Extract the mean and standard deviation measurement for each variable in the dataset
3- Incorporate descriptive names to the acitivities being measured
4- Pivots the columns to create a long skinny table and parses the variable names into multiple columns for each type of variable measured
5- Generates a tidy dataset that summarizes the cleaned up data.
