#run_analysis
#coursera: Getting and Cleaning Data -Project
#data description: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#data source: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

#set your working directory here or choose via menu, 
  #setwd("C:/Users/ralf/Desktop/coursera/GitHUB/GetDataProj")

#load required packages
  #install.packages("data.table")
  #install.packages("dplyr")
  library(data.table)
  library(dplyr)

#set directory and get data/clean temp files
  src_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(src_url, file.path(getwd(), "src_data.zip"))
  unzip(zipfile = "src_data.zip")
  file.remove("src_data.zip")


#reading activity labels and features
  src_dir <-paste(getwd(),"UCI HAR Dataset",sep="/") #chnage sep for Linux systems
  src_activitylabels <- fread(file.path(src_dir,"activity_labels.txt")
                            , col.names = c("label", "activity"))
  src_features <- fread(file.path(src_dir,"features.txt")
                            , col.names = c("index", "feature"))
#subset of features we are interested in (includes mean() and std() only)
  vec_features <- grep("(mean|std)\\(\\)", src_features[, feature])
  sub_features <- gsub('[()]', '', src_features[vec_features,feature])

#####load and combine training/test#####
  src_dir_tr <-paste(src_dir,"train",sep="/")
  src_dir_te <-paste(src_dir,"test",sep="/")
  #training
    tr_x <- fread(file.path(src_dir_tr, "X_train.txt"))[, vec_features, with = FALSE]
    data.table::setnames(tr_x, colnames(tr_x), sub_features)
    tr_y <- fread(file.path(src_dir_tr, "Y_train.txt")
                         , col.names = c("activity"))
    tr_sub <- fread(file.path(src_dir_tr, "subject_train.txt")
                       , col.names = c("sub"))
    tr <- cbind(tr_sub, tr_y, tr_x)
  #test
    te_x <- fread(file.path(src_dir_te, "X_test.txt"))[, vec_features, with = FALSE]
    data.table::setnames(te_x, colnames(te_x), sub_features)
    te_y <- fread(file.path(src_dir_te, "Y_test.txt")
              , col.names = c("activity"))
    te_sub <- fread(file.path(src_dir_te, "subject_test.txt")
                , col.names = c("sub"))
    te <- cbind(te_sub, te_y, te_x)
  ###test+training
  trte <-rbind(tr,te)
  trte[["activity"]] <- factor(trte[, activity]
                                 , levels = src_activitylabels[["label"]]
                                 , labels = src_activitylabels[["activity"]])
#write output
  #uncomment this if rounding is desired
  #trte_round <- trte %>%
  #  mutate_each(funs(round(., 6)))
  #write.table(trte_round, "rounded_data_means_std.txt")

  #normal tidy data
  write.table(trte, "data_means_std.txt")
  
  
  #aggregate by activity, sub, showing average
  write.table(aggregate(trte[, 3:length(trte)], list(trte$activity,trte$sub), mean), "agg_activity_sub_mean.txt")
