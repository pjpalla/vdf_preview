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