library(stringr)
library(lubridate)

## This function converts the elements of the date field to Date objects
convert_date <- function(data){
  data <- transform(data, date = as.Date(as.character(date), "%Y%m%d"))
}

## This function replaces star elements from the field 'value' with zeroes.
## The value field is then converted from character to integer
remove_star <- function(data){
  data$value = gsub(x = data$value, pattern = "\\*", 0)
  data$value <- as.integer(data$value)
  data
}

#This function preprocesses kpi datasets replacing stars from the field 'value' and converting string elements from the 'date' field to Date objects.
#This last operation is made to allow to perform different filtering activities

preprocess <- function(data){
  tmp <- remove_star(data)
  final_dataset <- convert_date(tmp)
  final_dataset
}

#This function extracts data from the S3 bucket and builds a dataframe
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