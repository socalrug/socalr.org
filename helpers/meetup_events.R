###--------------------------------------------------------------------------###
###   REMAINING STEPS:                                                       ###
###   https://rladies.github.io/meetupr/articles/setup.html                  ###
###--------------------------------------------------------------------------###
# 1.  Save the MEETUPR_PWD environment variable as secret on CI (actually      #
#     called repo secret for e.g. GitHub Actions)                              #
# 2.  Use the code below to decrypt the secret before using meetupr. We save   #
#     the temporary token to disk but to a temporary folder so it won’t end    #
#     up in a package check artefact.                                          #
###--------------------------------------------------------------------------###

# Load packages
library(dplyr)
library(stringr)
library(lubridate)
library(purrr)
library(meetupr)
library(cyphr)

# Decrypt and Use MeetupR Token for CI/CD
key <- cyphr::key_sodium(sodium::hex2bin(Sys.getenv("MEETUPR_PWD")))

temptoken <- tempfile(fileext = ".rds")

cyphr::decrypt_file("meetupr_secret.rds",
                    key = key,
                    dest = temptoken)

token <- readRDS(temptoken)[[1]]

# meetupr auth
token <- meetupr::meetup_auth(
  token = token,
  use_appdir = FALSE,
  cache = FALSE
)

Sys.setenv(MEETUPR_PAT = temptoken)

socal_groups <- c("SOCAL-RUG", 
                  "Santa-Barbara-R-Users-Group", 
                  "Real-Data-Science-USA-R-Meetup",
                  "useR-Group-in-San-Luis-Obispo-County", 
                  "rladies-irvine",
                  "rladies-la",
                  "rladies-pasadena",
                  "rladies-riverside",
                  "rladies-santa-barbara",
                  "rladies-san-diego")

# Function for getting upcoming and past events from Meetupr
get_meetup_events <- function(x) {
  if (length(meetupr::get_events(urlname = x)) > 0) {
    meetupr::get_events(urlname = x) |> 
      dplyr::mutate(chapter = x)
  }
}

events_raw <- purrr::map_dfr(.x = socal_groups, .f = get_meetup_events) |> 
  dplyr::select(chapter, dplyr::everything())

events <- events_raw |> 
  dplyr::filter(status != "draft",
                !stringr::str_detect(title, "Cross-post|cross-post"),
                !stringr::str_detect(description, "Cross-post|cross-post")) |> 
  dplyr::distinct() |> 
  dplyr::arrange(dplyr::desc(time)) |>
  dplyr::mutate(Upcoming = dplyr::if_else(status == "published", "&#x2713;", ""),
                Chapter = dplyr::case_when(chapter == "SOCAL-RUG" ~ "SoCal RUG",
                                           chapter == "Santa-Barbara-R-Users-Group" ~ "Santa Barbara RUG",
                                           chapter == "Real-Data-Science-USA-R-Meetup" ~ "Los Angeles RUG",
                                           chapter == "useR-Group-in-San-Luis-Obispo-County" ~ "San Luis Obispo RUG",
                                           chapter == "rladies-irvine" ~ "R-Ladies Irvine",
                                           chapter == "rladies-la" ~ "R-Ladies Los Angeles",
                                           chapter == "rladies-pasadena" ~ "R-Ladies Pasadena",
                                           chapter == "rladies-riverside" ~ "R-Ladies Riverside",
                                           chapter == "rladies-santa-barbara" ~ "R-Ladies Santa Barbara",
                                           chapter == "rladies-san-diego" ~ "R-Ladies San Diego",
                                           TRUE ~ chapter),
                Event = paste0('<a href=', '"', link, '">', title, '</a>'),
                Date = lubridate::as_date(time),
                Time = format.POSIXct(time, format = "%I:%M %p")) |> 
  dplyr::select(Upcoming, Chapter, Event, Date, Time)

saveRDS(events, file = "events/events_past_and_upcoming.rds")
