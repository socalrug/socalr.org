library(htmltools)

as_card_upcoming <- function(Chapter, link, title, Date, Time, ...) {
  tags$div(class = "card",
           tags$div(class = "card-header-upcoming", Chapter),
           tags$div(class = "card-body",
                    tags$a(class = "card-title", href = link, title),
                    tags$div(class = "card-text", paste("Date:", Date)),
                    tags$div(class = "card-text", paste("Time (PST):", Time))
           )
  )
}

as_card <- function(Chapter, link, title, Date, Time, ...) {
  tags$div(class = "card",
           tags$div(class = "card-header", Chapter),
           tags$div(class = "card-body",
                    tags$a(class = "card-title", href = link, title),
                    tags$div(class = "card-text", paste("Date:", Date)),
                    tags$div(class = "card-text", paste("Time (PST):", Time))
           )
  )
}