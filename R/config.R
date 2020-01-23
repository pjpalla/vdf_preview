library("aws.s3")
library("aws.signature")
library(stringr)





# Sys.setenv("AWS_ACCESS_KEY_ID" = "mykey",
#            "AWS_SECRET_ACCESS_KEY" = "mysecretkey",
#            "AWS_DEFAULT_REGION" ="eu-west-1",
#            "AWS_SESSION_TOKEN" = "mytoken")

Sys.setenv("AWS_PROFILE" = "vodafone_profile", "AWS_DEFAULT_REGION" ="eu-west-1")
use_credentials(profile = "vodafone_profile")


bucketlist()
bucket_name <- "vodafone-analytics"
file_names <- get_bucket_df("vodafone-analytics")[["Key"]]
print(file_names)





build_kpi_df <- function(pattern_search = "eventname=in_out_points/disaggregation=min"){
  if (is.null(pattern_search) || pattern_search == ""){
    print("you must provide the pattern_search parameter")
    return()
  }
  data <- lapply(file_names, function(x) {
    if(str_detect(x, pattern_search)){
      print(x)
      object <- get_object(x, bucket_name)
      object_data <- readBin(object, "character")
      read.csv(text = object_data, stringsAsFactors = FALSE)
    }
  })
  data <- do.call(rbind, data)
}


mappings <- read.csv("mappings/multimap_ras.csv", sep = ";")
head(mappings)


##### 
io =input_output_min %>% filter(kpi == "arrivals" & map == 3)
io$value = gsub(x = io$value, pattern = "\\*", 0)
io <- transform(io, date = as.Date(as.character(date), "%Y%m%d"))
library(lubridate) ### to process data 


