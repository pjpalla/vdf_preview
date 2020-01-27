library(dplyr)
source("R/config.R")
source("R/utility.R")

### get io data with different levels of disaggregation from the S3 bucket ###

daily_kpi = c("eventname=in_out_points/disaggregation=", "eventname=arrivals_attendances/disaggregation=", "eventname=mobility_graph/disaggregation=")
monthly_kpi = c("eventname=co_visits_matrix/disaggregation=max", "eventname=centrality/disaggregation=max", "eventname=visit_duration/disaggregation=max")

disaggregation = c("min", "mid")

for (k in daily_kpi[3]){
  for (d in disaggregation){
    pattern_string = paste(k, d, sep='')
    print(pattern_string)
    raw_data <- build_kpi_df(pattern_search = pattern_string)
    kpi_data <- preprocess(raw_data)
    if (str_detect(pattern_string, "in_out")){
      output_dir = "kpi/io/"
      output_path = paste(output_dir, "io_data_", d, ".csv", sep = '')
      print(output_path)
    }else if (str_detect(pattern_string, "arrivals_attendances")){
      output_dir = "kpi/arrivals_attendances/"
      output_path = paste(output_dir, "arrivals_attendances_", d, ".csv", sep = '')
      print(output_path)
    }else if (str_detect(pattern_string, "mobility")){
      output_dir = "kpi/mobility/"
      output_path = paste(output_dir, "mobility_", d, ".csv", sep='')
      print(output_path)
    }
    write.csv(x = kpi_data, file = output_path)
    print("file written to disk")
  }
 
}


# raw_data_min <- build_kpi_df(pattern_search = "eventname=in_out_points/disaggregation=min")
# io_data_min <- preprocess(raw_data_min)
# write.csv(x = io_data_min, file = "kpi/io/io_data_min.csv", row.names = FALSE)
# 
# raw_data_mid <- build_kpi_df(pattern_search = "eventname=in_out_points/disaggregation=mid")
# io_data_mid <- preprocess(raw_data_mid)
# write.csv(x = io_data_min, file = "kpi/io/io_data_mid.csv", row.names = FALSE)
# 
# raw_data_mid <- build_kpi_df(pattern_search = "eventname=in_out_points/disaggregation=m")
# io_data_mid <- preprocess(raw_data_mid)
# write.csv(x = io_data_min, file = "kpi/io/io_data_mid.csv", row.names = FALSE)
