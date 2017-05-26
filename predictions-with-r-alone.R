library(readr)  # For reading files
library(dplyr)  # For data frames
library(mlr)    # For machine learning pipeline

incomplete_data <- read_csv("incomplete_data.csv") %>% data.frame()

# Load the MLR model from disk
fit <- readRDS("cubist.model")

# Make the prediction. This will take some hours to execute
predictions <- predict(fit, newdata = incomplete_data)

head(predictions)
head(predictions$time)