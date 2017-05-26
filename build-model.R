library(readr)  # For reading files
library(dplyr)  # For data frames
library(mlr)    # For machine learning pipeline

training_data <- read_csv("training_data.csv") %>% data.frame()

# The task is to make a regression model based on the training data which tries to predict the view_count
task <- makeRegrTask(data = training_data, target = "view_count")

# The model is based on Cubist regression with a few hyperparamaters set
lrn <- makeLearner("regr.cubist", committees = 3, neighbors = 9)

# Test the model just to make sure it has a decent performance
rdesc = makeResampleDesc("CV")
r <- resample(lrn, task, rdesc, keep.pred = FALSE, models = TRUE, measures = mae)

# Fit the model
fit <- train(lrn, task)

# Save the MLR model to disk
saveRDS(fit, "cubist.model")
