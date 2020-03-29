library(tidyverse)
library(plotly)
library(drc)

deaths      <- c( 1, 1, 1, 2, 3, 7, 8,10,12,16,20,23,33,36,42,66,92,102,NA)
predictions <- c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,124)

data <- data.frame(deaths=deaths,day=1:length(deaths),predictions=predictions)

model <- drm(deaths ~ day, data = data, fct = LL.4(fixed=c(NA,0,NA,NA)))

steepness <- model$coefficients["b:(Intercept)"]
deceased <- model$coefficients["d:(Intercept)"]
inflection <- model$coefficients["e:(Intercept)"]
inflection_date <- Sys.Date() - max(data$day) + as.integer(inflection)
final_date <- Sys.Date() - max(data$day) + as.integer(inflection)*2

predict_deceased <- function(x) {
  as.integer(deceased - deceased/(1 + (x/inflection)^(-steepness)))
} 

data$model <- predict_deceased(data$day)

max_day <- max(data$day)
next_day <- max(data$day) + 1
end_day <- as.integer(2*inflection)
end_day <- max(end_day, next_day+30)

for (x in next_day:end_day) {
  data <- add_row(data,
      day = x,
      deaths = NA,
      predictions = NA,
      model = predict_deceased(x)
  )
}

data$day <- Sys.Date() - (max_day - data$day)

predict_total_today <- filter(data,day==Sys.Date())$model
predict_new_today <- predict_total_today - filter(data,day==Sys.Date()-1)$deaths

data %>%
  plot_ly(
    x = ~day,
    y = ~model,
    color = "Ny prognos",
    type = "scatter",
    mode = "lines"
  ) %>%
  add_markers(y = ~deaths, color="Historik") %>%
  add_markers(y = ~predictions, color="Gamla prognoser", alpha=0.5, size=2) %>%
  layout(
    title = paste(
      "COVID-19 - Estimerad dödskurva - Sverige",
      "\nDagens prognos ", Sys.Date(), " : ", predict_total_today, " (+", predict_new_today, ")",
      sep=""
    ),
    yaxis = list(title="Antal döda", type="log"),
    xaxis = list(title="Datum")
  ) %>%
  add_segments(x = inflection_date, xend = inflection_date, color = I("black"), y = 0, yend = deceased, showlegend = FALSE) %>%
  add_segments(x = Sys.Date(), xend = Sys.Date(), color = I("black"), y = 0, yend = deceased, showlegend = FALSE)

