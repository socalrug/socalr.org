# tidyverse
library(dplyr)
library(purrr)
library(lubridate)
library(stringr)
library(readr)

# group info and credentials
library(googledrive)
#library(meetupr)

# map group locations
library(leaflet)
library(ggmap)

# render html
library(htmltools)
library(fontawesome)

# avoid base conflict with `filter()`
conflicted::conflict_prefer("filter", "dplyr")