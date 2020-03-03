library(dplyr)
source("R/input_output.R")


### user_type possibile values: ITA, STR, ALL
get_overnight_stay_by_adr <- function(dataset, map_id, month, user_type){
  if (user_type == "ALL"){
    tmp_overnight <- dataset[dataset$map == map_id & dataset$mese == month & dataset$user_type != "INT", ]
    tmp_overnight <- aggregate(tmp_overnight$pernottamenti ~ tmp_overnight$adr + tmp_overnight$adr_id + tmp_overnight$map + tmp_overnight$mese, FUN = sum)
    names(tmp_overnight) = c("adr_names", "adr_id", "map", "mese", "pernottamenti")
    
  }else{
    tmp_overnight <- dataset[dataset$map == map_id & dataset$mese == month & dataset$user_type == user_type, ]
  }
  
  mappings <- read.csv("mappings/latest_multimap_ras.csv", sep=";")
  mappings <- mappings[mappings$MAP_ID == map_id, ]
  
  tmp_overnight$adr_names <- sapply(tmp_overnight$adr_id, function(x) mappings$AREA_LB_0[mappings$AREA_ID == x])
  
  overnight <- tmp_overnight
  #overnight <- extend_map(map_id = map_id, inputs = overnight)
  overnight %>% select(map, mese, adr_id, adr_names, pernottamenti)

}

### sired overnight stay


get_sired_overnight_stay <- function(dataset, month, user_type, mapping){
  
  sired_dataset = dataset
  
  if (user_type == "ALL"){
    sired_dataset <- sired_dataset %>% filter(Mese == month, Nazionalita != 'INT')
  }else{
    sired_dataset <- sired_dataset %>% filter(Mese == month, Nazionalita == user_type)
  }
  
  sired_dataset <- aggregate(sired_dataset$Pre ~ sired_dataset$comune + sired_dataset$Mese, FUN = sum)
  names(sired_dataset) = c("adr_names", "mese", "pernottamenti")
  #sired_dataset$adr_names <- sapply(sired_dataset$comune, function(x) mapping$Vodafone[mapping$Sired == x])
  sired_municipalities = as.character(sired_dataset$adr_names)
  convertion <- function(x){
    return(as.character(mapping$Vodafone[mapping$Sired == x]))
  }
  municipalities <- as.character(sapply(sired_municipalities, convertion))
  
  sired_dataset$adr_names = municipalities
  sired_dataset
  
  
}