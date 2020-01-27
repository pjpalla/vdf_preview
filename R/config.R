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
# bucket_name <- "vodafone-analytics"
# file_names <- get_bucket_df("vodafone-analytics")[["Key"]]
# print(file_names)








# mappings <- read.csv("mappings/multimap_ras.csv", sep = ";")
# head(mappings)


##### 
# io =input_output_min %>% filter(kpi == "arrivals" & map == 3)
# io$value = gsub(x = io$value, pattern = "\\*", 0)
# io <- transform(io, date = as.Date(as.character(date), "%Y%m%d"))
# library(lubridate) ### to process data 


