library(tidyverse)
library(plotly)
library(drc)

first_death <- as.Date("2020-03-11")
deaths      <- c( 1, 1, 1, 2, 3, 7, 8,10,12,16,20,23,33,36,42,66,92,102)
predictions <- c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA, NA)

today <- Sys.Date()

data <- data.frame(deaths=deaths,day=1:length(deaths),predictions=predictions)

model <- drm(deaths ~ day, data = data, fct = LL.4(fixed=c(NA,0,NA,NA)))

steepness <- model$coefficients["b:(Intercept)"]
deceased <- model$coefficients["d:(Intercept)"]
inflection <- model$coefficients["e:(Intercept)"]
inflection_date <- first_death + as.integer(inflection) - 1

predict_deceased <- function(day) {
  as.integer(deceased - deceased/(1 + (day/inflection)^(-steepness)))
} 

data$model <- NA

predict_day <- length(deaths) + 1
end_day <- max(as.integer(2*inflection), predict_day+7)

for (day in predict_day:end_day) {
  data <- add_row(data,
      day = day,
      deaths = NA,
      predictions = NA,
      model = predict_deceased(day)
  )
}

# Convert day from integer to date
data$day <- first_death + data$day - 1
predict_day <- first_death + predict_day - 1

predict_total <- filter(data,day==predict_day)$model
predict_new <- predict_total - filter(data,day==predict_day-1)$deaths

data %>%
  plot_ly(
    x = ~day,
    y = ~deaths,
    color = "Historik",
    type = "scatter",
    mode = "markers+lines"
  ) %>%
  add_lines(x = ~day, y = ~model, color="Framtida prognos") %>%
  add_markers(y = ~predictions, color="Tidigare prognoser", alpha=0.5, size=2) %>%
  layout(
    title = paste(
      "COVID-19 - Dödsprognos - Sverige",
      "\nPrognos för ", predict_day, " : ", predict_total, " totalt varav ", predict_new, " nya",
      sep=""
    ),
    yaxis = list(title="Antal döda", type="log"),
    xaxis = list(title="Datum")
  ) %>%
  add_segments(x = inflection_date, xend = inflection_date, color = "Inflektionspunkt", alpha=0.5, y = 0, yend = deceased) %>%
  add_segments(x = today, xend = today, color = "Dagens datum", alpha=0.5, y = 0, yend = deceased)

