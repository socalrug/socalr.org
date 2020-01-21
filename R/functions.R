clean_events <- function(events_data, descending = FALSE) {
  print(events_data$time)
  lubridate::tz(events_data$time) <- "America/Los_Angeles"
  months <- lubridate::month(events_data$time)
  month_abbs <- month.abb[months]
  days <- lubridate::day(events_data$time)
  hours <- format(strptime(events_data$local_time, "%H:%M"), "%I:%M %p")
  events_data$event_time <- paste(month_abbs, days, "at", hours)
  
  if (descending) {
    events_data <- arrange(events_data, desc(time))
  } else {
    events_data <- arrange(events_data, time)
  }
  
  events_data %>% 
    select(event_name = name, group_name, event_time, link)
}

as_card <- function(event_name, group_name, event_time, link, ...) {
  tags$div(
    class = "card",
    tags$a(
      href = link,
      class = "action_link",
      div(
        class = "container",
        tags$div(group_name, class = "card-group"),
        tags$div(event_name, class = "card-header"),
        tags$div(event_time, class = "card-time")
      )
    )
  )
}

as_link <- function(link, icon, ...) {
  tags$a(style = "text-decoration:none", href = link, fa(icon, height = "1.8rem", fill = "steelblue"), ...)
}

as_meetup <- function(x) {
  if (is.na(x)) {
    return(NULL)
  } else {
    as_link(paste0("https://meetup.com/", x), 
            "meetup") %>% 
      tags$li()
  }
}

as_email <- function(x) {
  if (is.na(x)) {
    return(NULL)
  } else {
    as_link(paste0("mailto:", x), 
            "envelope") %>% 
      tags$li()
  }
}

as_website <- function(x) {
  if (is.na(x)) {
    return(NULL)
  } else {
    as_link(x, 
            "link") %>% 
      tags$li()
  }
}

as_twitter <- function(x) {
  if (is.na(x)) {
    return(NULL)
  } else {
    clean_name <- str_replace_all(x, "@", "")
    as_link(paste0("https://twitter.com/", clean_name), 
            "twitter") %>% 
      tags$li()
  }
}

as_github <- function(x) {
  if (is.na(x)) {
    return(NULL)
  } else {
    clean_name <- str_replace_all(x, "@", "")
    as_link(paste0("https://github.com/", clean_name), 
            "github") %>% 
      tags$li()
  }
}

as_group_name <- function(x) {
  tags$div(x, class = "fa-row-name")
}

as_ul <- function(...) {
  tags$div(class = "fa-row",
           tags$ul(class = "network-icon",  ...)
  )
}

fa_row <- function(group_name, website, email, meetup_page, twitter, github) {
  as_ul(as_group_name(group_name), as_website(website), as_email(email), as_meetup(meetup_page), as_twitter(twitter), as_github(github))
}