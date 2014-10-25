Normalization of Wearable Device Data
=====================================

This work normalizes raw available from experimentation with smartphones during several activities and published in the [Machine Learning Repository](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#) provided by the University of California, Irvine.

In the author's words, this "...experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data."[1]

How Does the Script Work
------------------------

Just execute `./run_analysis.R` and the script will go through all stages, from downloading raw data, to normalization, to generation of the final tidy data file:

1. Downloading bulk zip file with all data: If the file cannot be found on the local directory, it is downloaded from UCI and saved locally
1. Unzipping data: If the local directory is not found, the zipped file is unzipped on the default location
1. Load phase independent data

    1. Labels for each activity performed (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING). Labels are needed for later enrichement of the tidy data set. Activity labels are collected from `activity_labels.txt`
    1. Labels for each of the features, represented on the feature vector in each of the experiments, loaded from `features.txt`
    1. Filter features relevant to this exercise, only features related to mean and standard deviation.
    
    
    
1. Load phase dependent data: for each of the phases, training and test. In each phase an observation is related to an experiment, and the handling of each observation goes through the following steps:

    1. Load the identifier of the subject in each experiment, provided in `<phase>/subject_<phase>.txt`
    1. Load the activity on each experiment, provided in `<phase>/y_<phase>.txt`
    1. Load the vector feature for each experiment, provided in `<phase>/X_<phase>.txt`
    1. Join phase-dependent data to phase-independent data: enrich experiment with activity labels and subset the vector feature to the ones we care about (mean and standard deviation)


1. Finally, builds the tidy data set:

    1. Gathers all colums `tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std` into one temporary column, variable
    1. Select the columns we care about for the tidy data set: subject, activity, variable, value
    1. Group on variable, activity, subject and summarize by the mean
    1. Saves to `'tidy_data.txt'`

Code Book
---------

The final data set provided after all these steps is incredibly simple and can be sinthetized by just four columns:

* variable: one of the measurement variables, valued from `tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std`
* activity: one of WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING
* subject: an identifier of the subject in play in that experiment
* mean: the mean of the variable across all phases and experiments

The resut of overall computation is available in final result file `tidy_data.txt` 

To execute 
[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
