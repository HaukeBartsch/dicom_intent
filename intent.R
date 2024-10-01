library(rpart)
library(rpart.plot)
library(dplyr)

setwd("~/src/dicom_intent")
# combine individual csv files
files <- list.files("~/src/dicom_intent/train", pattern = '*\\.csv')
data <- NULL
for (file in files) {
  if (is.null(data))
    data <- read.csv(paste0("~/src/dicom_intent/train/", file))
  else {
    d <- read.csv(file)
    bind_rows(data, d)
  }
}

names(data)
data <- data[, !(names(data) %in% c(".", "Modality", "SeriesDescription", "SequenceName", "ProtocolName"))]
data$Intent <- as.factor(data$Intent)


fit.tree = rpart(Intent ~ ., data=data, method = "class", cp=0.008)

fit.tree

rpart.plot(fit.tree)

# Checking the order of variable importance
fit.tree$variable.importance

# try to predict on a test dataset
pred.tree = predict(fit.tree, data.test, type = "class")
