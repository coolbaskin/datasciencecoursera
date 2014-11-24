# Problem Description

One of the most exciting areas in all of data science right now is wearable computing - see for example this article .
Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The
data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S
smartphone. A full description is available at the site where the data was obtained: 

    [http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphone)

Here are the data this script processes: 

    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

# Dataset Information

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person
performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone
(Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear
acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label
the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was
selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in
fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has
gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and
gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff
frequency was used. From each window, a vector of features was obtained by calculating variables from the time and
frequency domain. 

For each record in the dataset it is provided: 
- An identifier of the subject who carried out the experiment.
- Its activity label. 
- An average computed from standard deviation and mean variables from from a 561-feature vector with time and frequency domain variables that comprised the original dataset. 

Note: features are normalized and bounded within [-1,1].

*[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012*

# Script

This repository contains the R script called *run_analysis.R* that on does the following with this dataset: 

1. Reads common activity labeles and feature names (both stored in separate files).
2. Reads the observation files for TRAIN and TEST datasets (each stored in a set of separate files).
3. Filters out all the observations but the mean and standard deviation ones.
4. Merges the data and metadata from all the separate sources into one data frame.
5. Aggregates the data by computing averages of each observation variable for each activity and each subject.
6. Prints the results.
7. Profits!
