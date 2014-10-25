# 
# Normalization of raw data from wearable devices provided in 
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#
#

library(dplyr) 
library(tidyr)

# download data
url <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
local_zip_file <- 'getdata-projectfiles-UCI HAR Dataset.zip'
if (!file.exists(local_zip_file)) {
    print('downloading...')
    download.file(url, local_zip_file, method='curl')
}

# unzip data
local_dir <- 'UCI HAR Dataset'
if (!file.exists(local_dir)) {
    print('unzipping...')
    unzip(local_zip_file)
}

#
# builds data frames common to all phases
#

# load activity labels
if (!exists('activity')) {
    print('building activity label...')
    activity = read.csv(file.path(local_dir, 'activity_labels.txt'), header=FALSE, sep=' ')
    colnames(activity) <- c('id', 'description')
}

# load feature
if (!exists('feature')) {
    print('building feature...')
    feature = read.csv(file.path(local_dir, 'features.txt'), header=FALSE, sep=' ')
    colnames(feature) <- c('id', 'description')
    
    # use dplyr friendly names
    feature$description <- gsub('\\(|\\)', '', feature$description)
    feature$description <- gsub('-', '_', feature$description)
    
    # only mean or standard deviation measurements, see instructions
    feature <- feature %>%
        filter(grepl('std|mean', description)) %>%
        filter(!grepl('meanFreq', description))
}

if (!exists('raw_data_set')) {
    #
    # builds raw data set for all phases
    #
    
    phases <- c('test', 'train')
    
    #rm(raw_data_set)
    for (phase in phases) {
        print(paste('phase:', phase))
        
        # load subject_feature
        print('building subjects per feature set...')
        subject_feature <- read.csv(file.path(local_dir, phase, paste0('subject_', phase, '.txt')), header=FALSE, sep=' ')
        colnames(subject_feature) <- c('subject')
        
        # load activity per vector feature
        print('building labels per feature set...')
        activity_feature <- read.csv(file.path(local_dir, phase, paste0('y_', phase, '.txt')), header=FALSE, sep=' ')
        colnames(activity_feature) <- c('activity_id')
        
        # load vector feature
        print('building feature set...')
        file_name <- file.path(local_dir, phase, paste0('X_', phase, '.txt'))
        # trick to speed up loading, derive colclasses on a smaller number of rows
        sample <- read.table(file_name, header=FALSE, strip.white=TRUE, nrows=5)
        classes <- sapply(sample, class)                    
        set <- read.table(file_name, colClasses=classes, header=FALSE, strip.white=TRUE)
        
        # only measurements related to mean/std (we filtered these before into feature df)
        print('subsetting relevant measurements (std/mean)...')
        set <- set[,feature$id] # only measurements related to mean/std
        colnames(set) <- feature$description # update column names with feature description
        
        print('joining activity...')
        # join activity and actity name, we want to have the activity description
        raw_data_set_phase <- activity %>%
            inner_join(activity_feature, by=c('id'='activity_id')) %>%
            select(description)
        # better column name
        colnames(raw_data_set_phase)[1] <- 'activity'
    
        # set phase properly
        raw_data_set_phase$phase <- phase
        
        # join activity, subject and feature set for phase
        print('joining feature set...')
        raw_data_set_phase <- cbind(raw_data_set_phase, subject_feature, set)
        
        # join to overall raw_data_set
        if (exists('raw_data_set')) {
            print('merging to previous phases...')
            raw_data_set <- rbind(raw_data_set, raw_data_set_phase)
        } else {
            print('initializing raw data set...')
            raw_data_set <- raw_data_set_phase
        }
    }
}

#
# finally, builds tidy data set
#
print('building tidy data set...')
# gather all <measurement>_<metric>_<axis> attributes as measurements
tidy_data_frame <- raw_data_set %>% 
    gather(variable, value, tBodyAcc_mean_X:fBodyBodyGyroJerkMag_std) %>%
    select(subject, activity, variable, value) %>%
    group_by(variable, activity, subject) %>%
    summarise(mean = mean(value))

print('saving tidy data set...')
write.table(tidy_data_frame, 'tidy_data.txt', row.name=FALSE)

print('done.')



