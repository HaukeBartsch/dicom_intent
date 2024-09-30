library(rpart)
library(rpart.plot)

setwd("~/src/dicom_intent")
data <- read.csv('mri_all.csv')

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
