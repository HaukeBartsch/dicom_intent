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
    d <- read.csv(paste0("~/src/dicom_intent/train/",file))
    data <- bind_rows(data, d)
  }
}
data <- unique(data)

names(data)
data <- data[, !(names(data) %in% c(".", "Modality", "SeriesDescription", "SequenceName", "ProtocolName"))]
data$Intent <- as.factor(data$Intent)

# split into train and test sets
#set.seed(234)
train = sample(1:nrow(data), nrow(data)*0.9)
data.train=data[train,]
data.test=data[-train,]

fit.tree = rpart(Intent ~ ., data=data.train, method = "class", cp=0.008)

fit.tree

rpart.plot(fit.tree)


# Checking the order of variable importance
fit.tree$variable.importance

# try to predict on a test dataset
# This only works if we have the same factor levels as in the training set
pred.tree = predict(fit.tree, data.test, type = "class")
table(pred.tree,data.test$Intent)

# could we prune the tree?

printcp(fit.tree)
# lowest cp value
fit.tree$cptable[which.min(fit.tree$cptable[,"xerror"]),"CP"]

# do the pruned tree
bestcp <-fit.tree$cptable[which.min(fit.tree$cptable[,"xerror"]),"CP"]
pruned.tree <- prune(fit.tree, cp = bestcp)
rpart.plot(pruned.tree)

# check for the quality of the pruned tree
pred.prune = predict(pruned.tree, data.test, type="class")
table(pred.prune,data.test$Intent)
