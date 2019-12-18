source(here::here("R", "packages.R"))

drive_auth(path = Sys.getenv("LAOCRUG_TOKEN"))
drive_download(
  as_id("1PxjivIKfqs0nDuSQy-EU_w2Vge6rLoUsuLDfS5r8izI"), 
  path = here::here("data", "laocrugs.csv"),
  type = "csv", 
  overwrite = TRUE
)
laocrugs <- read_csv(here::here("data", "laocrugs.csv"))
laocrugs <- laocrugs %>% 
  sample_n(nrow(laocrugs))

drive_download(as_id("1FaubEkb4rumQhf8vNOOBee7AEBPw4FCR"), overwrite = TRUE)
meetup_auth(read_rds(".httr-oauth")[[1]])
googledrive::drive_update(as_id("1FaubEkb4rumQhf8vNOOBee7AEBPw4FCR"), ".httr-oauth")

get_any_events <- safely(get_events)

pull_events <- function(.meetup_page, .group_name, ...) {
  events <- get_any_events(.meetup_page, ...)
  if (!is.null(events$result)) events$result$group_name <- .group_name
  events
}

laocrugs_meetups <- laocrugs %>% 
  filter(group_name != "Data Science LA", group_name != "Los Angeles West R Users Group")

events <- map2(laocrugs_meetups$meetup_page, 
               laocrugs_meetups$group_name,
               pull_events) %>% 
  map(pluck(1)) %>% 
  bind_rows() %>% 
  mutate(
    group_name = dplyr::case_when(
      grepl("LA West", name) ~ "Los Angeles West R Users",
      grepl("LA East", name) ~ "Los Angeles East R Users",
      TRUE ~ group_name
    )
  ) %>% 
  filter(status == "upcoming")


past_laocrugs_meetups <- laocrugs
past_laocrugs_meetups <- laocrugs %>% 
  filter(!(group_name %in% c("Los Angeles East R Users Group", "Los Angeles West R Users Group")))

past_events <- map2(
  past_laocrugs_meetups$meetup_page, 
  past_laocrugs_meetups$group_name,
  pull_events, 
  event_status = "past"
) %>% 
  map(pluck(1)) %>% 
  bind_rows() %>% 
  mutate(
    group_name = dplyr::case_when(
      grepl("LA West", name) ~ "Los Angeles West R Users",
      grepl("LA East", name) ~ "Los Angeles East R Users",
      TRUE ~ group_name
    )
  ) 

past_events <- past_events %>% 
  group_by(group_name) %>% 
  arrange(desc(time)) %>% 
  slice(1:3) %>% 
  ungroup()

write_rds(events, here::here("data", "events.rds"))
write_rds(past_events, here::here("data", "past_events.rds"))