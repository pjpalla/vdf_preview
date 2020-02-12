library(lubridate)
library(dplyr)



get_input_by_adr <- function(dataframe, map_value, kpi_value, month_selected, year_selected = 2019, threshold){
     if (map_value )          
     d <- filter(dataframe, map == map_value & kpi == kpi_value) %>% 
                    filter(month(date) == month_selected & year(date) == year_selected)
     
     ## Here we comput the total number of inputs grouped by AdR
     # print("Data used to aggregate")
     # print(head(d))
     inputs <- aggregate(d$value ~ d$adr_id, FUN = sum)
     names(inputs) = c("adr_id", "arrivals")
     inputs <- inputs[order(inputs$arrivals, decreasing = T), ]
     
     # mappings = read.csv("mappings/multimap_ras.csv", sep = ";")
     # mappings = mappings[mappings$MAP_ID == map_value, ]
     # 
     # inputs$adr_description = sapply(inputs$adr_id, function(x) mappings$AREA_LB_0[mappings$AREA_ID == x])
     inputs <- extend_map(map_id = map_value, inputs = inputs)
     
     ### here we filter the arrivals to visualize only relevant values
     inputs$percentage = round(inputs$arrivals/sum(inputs$arrivals), 6)
     tot <- sum(inputs$arrivals)
     inputs$filtered_arrivals <- sapply(inputs$arrivals, function(x){
               value <- round(x/tot, 6)
               ifelse(value >= threshold, x, 0)
               #ifelse(value >= threshold & value < 0.005, x, 0)
               })
     inputs
     
}


## This function adds the columns adr_name to the aggregated dataframe with the fields adr_id and arrivals
extend_map <- function(map_id, inputs){
          
          mappings <- read.csv("mappings/multimap_ras.csv", sep=";")
          mappings <- mappings[mappings$MAP_ID == map_id, ]
          map_adr_ids <- mappings$AREA_ID
          
          input_adr_ids <- unique(inputs$adr_id)
          
          ids_to_add <- setdiff(map_adr_ids, input_adr_ids)
          ## create the rows to append to the input dataframe to have the same number of adr_ids of the 
          ## dataframe mappings
          l <- lapply(ids_to_add, FUN = function(x) c(x, 0))
          for (r in l) {inputs = rbind(inputs, r)}
          
          
          inputs$adr_name <- sapply(inputs$adr_id, function(x) mappings$AREA_LB_0[mappings$AREA_ID == x])
          adr_name_levels <- as.character(inputs$adr_name)
          inputs$adr_name <- as.factor(adr_name_levels)
          inputs

}