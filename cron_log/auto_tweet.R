library(tidyverse)
library(googledrive)
library(rtweet)

# functions to post tweet depending on type
post_tweet_type <- function(tweet_type, tweet_data = tweet_queue) {
  tweet <- tweet_data %>% 
    filter(type == tweet_type, !tweeted) %>% 
    sample_n(1) %>% 
    pull(text)
  
  tweet_data <- tweet_data %>% 
    mutate(tweeted = ifelse(text == tweet, TRUE, tweeted))
  
  post_tweet(tweet)
  
  invisible(tweet_data)
}

post_membership <- function() {
  post_tweet_type("membership")
}

post_theory <- function() {
  post_tweet_type("theory")
}

post_playlist <- function() {
  post_tweet_type("playlist")
}

# download the existing tweet queue from google drive 
csv_id <- drive_find(pattern = "tweet_queue", type = "spreadsheet") %>% 
  pull(id) %>% 
  as_id()
drive_download(csv_id, type = "csv", overwrite = TRUE)
tweet_queue <- read_csv("tweet_queue.csv")

# pick a type of tweet depending on the day and post
todays_date <- lubridate::wday(Sys.Date(), label = TRUE)
post_tweet_of_type <- switch(todays_date,
  "Tue" = post_membership,
  "Wed" = post_theory,
  "Thurs" = post_playlist,
)

# post tweet and return updated data
tweet_queue <- post_tweet_of_type()

# if all tweets in the category of tweet have been posted, reset the queue
tweet_queue <- tweet_queue %>% 
  group_by(type) %>%
  mutate(all_tweeted = all(tweeted), 
         tweeted = ifelse(all_tweeted, FALSE, tweeted)) %>% 
  select(-all_tweeted)

write_csv(tweet_queue, "tweet_queue.csv")
drive_update(csv_id, "tweet_queue.csv")
