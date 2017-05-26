## Cubist Regression on Stack Overflow Data

This application supports an [article](https://cosminsanda.com/posts/a-compelling-case-for-sparkr/) on my blog where I present a use case appropiate for `SparkR`.

This problem that I am trying to solve is that of predicting the number of *views* Stack Overflow questions have based on a few attributes.

I use the [Cubist](https://cran.r-project.org/web/packages/Cubist/vignettes/cubist.pdf) package to build a model based on the `training_data.csv`.

The model can be built by running the `build-model.R` script.

After building the model the are two options for making the predictions:

### Using Vanilla R for Making Predictions

This is the simple but excruciating slow method. It will take hours to run it.

* Unzip the `incomplete_data.csv.zip`.
* Run the `predictions-with-r-alone.R`.
* After a few hours you'll get a dataframe with predictions.

You can shorten the time by selecting a subset of the input data with something like `incomplete_data <- read_csv("incomplete_data.csv") %>% data.frame() %>% top_n(100)`.

The purpose of making these predictions is to show how slow it runs :)

### Using Vanilla R for Making Predictions

This is the slightly more involved but much faster method. This will take less than an hour on the appropriately sized cluster. This is what you are here for. The guide expects that you use an AWS account and that you're willing to spend around 3$ on and all. I also assume that you know your way around AWS, if you have problems following these guidelines, you are welcome to contact me.
    
* Log into the AWS Console and head over to EMR and click on *Create cluster* and use advanced settings.
* Your new cluster needs to have the following characteristics:
    * Select release *5.5.0* and *Spark*.
    * For software configuration use `[{"classification":"capacity-scheduler","properties":{"yarn.scheduler.capacity.resource-calculator":"org.apache.hadoop.yarn.util.resource.DominantResourceCalculator"}},{"classification":"spark","properties":{"maximizeResourceAllocation":"true"}}]`.
    * For hardware use as Master 1 `c4.2xlarge` on Spot market and bid something like 0.3$. For Core use 4 `c4.2xlarge`, also on the Spot market.
    * For bootstrap actions you will need two things:
        * This [bootstrap](https://gist.github.com/cosmincatalin/a2e2b63fcb6ca6e3aaac71717669ab7f) to install RStudio Server.
        * This [bootstrap](https://gist.github.com/cosmincatalin/866233457e28ecb9224b126cd2747cb5) to install `mlr`, `Cubist` and `dplyr` packages.
    * Select an *EC2 key pair* that you have access to. You need this to access your cluster via `SSH`.
* Copy the contents of `incomplete_data.csv.zip` to a bucket you own, like `s3://your-bucket/incomplete-data.csv`
* Modify the `predictions-with-sparkr.R` so that this line `sdf <- read.df("hdfs:///tmp/incomplete_data.csv", "csv", header = "true", inferSchema = "true") %>% repartition(31)` will be something like `sdf <- read.df("s3://your-bucket/incomplete-data.csv", "csv", header = "true", inferSchema = "true") %>%repartition(31)`
* After your cluster starts, `scp` the `cubist.model` file to the `/tmp` folder of all the Core instances in the cluster.
* The `RStudio` server will be accessible on the Master instance according to the guidelines in the first bootstrap.
* Create an `R` script on the server and add the content of `predictions-with-sparkr.R`.
* Run the script, it shouldn't take more than an hour to complete.
* Kill the cluster, it spends money.
