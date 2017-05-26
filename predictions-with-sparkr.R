library(magrittr)   # Provides the pipe operator

# Load the library from where Spark is installed. There is no CRAN package
library(SparkR, lib.loc = c(file.path("/usr/lib/spark/R/lib")))
# Start a Spark session on the cluster
sparkR.session(master = "yarn", sparkConfig = list(spark.executor.memory = "1000m",
                                                   spark.executor.cores = "1",
                                                   spark.executor.instances = "31"))


# This is a Spark data frame
sdf <- read.df("hdfs:///tmp/incomplete_data.csv", "csv", header = "true", inferSchema = "true") %>%
  repartition(31)
sdf %>% cache()  # Cache the data
sdf %>% count()  # Materialize the cache

# Input to the function is an R data frame
getPredictions <- function(df) {
  # These libraries needs to be installed on all nodes in the cluster
  library(dplyr)  # For data frames
  library(mlr)    # For machine learning pipelines
  
  # Load the mlr model distributed to the cluster  
  fit <- readRDS("/tmp/cubist.model")
  # Make the predictions and return an R data frame
  predict(fit, newdata = df)$data
}

# The schema of the data frame retruned from the lambda function, Eg: getPredictions
outputSchema <- structType(structField("prediction", "double"))

# Make predictions on the dataset in a distributed manner and output the first few predictions
predictions <- sdf %>% dapply(getPredictions, outputSchema) %>% collect()

head(predictions)

# Stop the Spark session
sparkR.session.stop()
