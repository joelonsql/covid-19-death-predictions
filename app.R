library(shiny)
library(tidyverse)
library(plotly)
library(drc)

first_death <- as.Date("2020-03-11")
input_deaths      <- c( 1, 1, 1, 2, 3, 7, 8,10,12,16,20,23,33,36,42,66,92,102,110,146)
input_predictions <- c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA, NA,124,136)

base_data <- data.frame(deaths=input_deaths,day=1:length(input_deaths),predictions=input_predictions)
base_model <- drm(deaths ~ day, data = base_data, fct = LL.4(fixed=c(NA,0,NA,NA)))
y_limits <- c(1,10^round(log10(base_model$coefficients["d:(Intercept)"])))
x_limits <- c(first_death, first_death+as.integer(base_model$coefficients["e:(Intercept)"])*2)

ui <- fluidPage(
    titlePanel("COVID-19 - Dödsprognos - Sverige"),
    sidebarLayout(
        sidebarPanel(
            sliderInput("date",
                        "Time machine:",
                        min = first_death,
                        max = Sys.Date(),
                        value = Sys.Date())
        ),
        mainPanel(
           plotOutput("corona")
        ),
        fluid = TRUE
    )
)

server <- function(input, output) {
    output$corona <- renderPlot({

        data_points <- as.integer(input$date - first_death + 1)
        deaths      <- head(input_deaths, data_points)
        predictions <- head(input_predictions, data_points)
        today <- input$date
        
        data <- data.frame(deaths=deaths,day=1:length(deaths),predictions=predictions)
        model <- drm(deaths ~ day, data = data, fct = LL.4(fixed=c(NA,0,NA,NA)))
        steepness <- model$coefficients["b:(Intercept)"]
        deceased <- model$coefficients["d:(Intercept)"]
        inflection <- model$coefficients["e:(Intercept)"]
        inflection_date <- first_death + as.integer(inflection) - 1
        
        data$model <- NA
        predict_day <- length(deaths) + 1
        end_day <- as.integer(2*inflection)
        data <- data %>% add_row(
            day = predict_day:end_day,
            deaths = NA,
            predictions = NA,
            model = sapply(predict_day:end_day, function(day) {
                as.integer(deceased - deceased/(1 + (day/inflection)^(-steepness)))
            })
        )
        # Convert day from integer to date
        data$day <- first_death + data$day - 1
        predict_day <- first_death + predict_day - 1
        predict_total <- filter(data,day==predict_day)$model
        predict_new <- predict_total - filter(data,day==predict_day-1)$deaths

        ggplot(data, aes(x=day)) +
            geom_point(aes(y=deaths, color="Historik")) +
            geom_line(aes(y=model, color="Framtida prognos")) +
            geom_point(aes(y=predictions, color="Tidigare prognoser"), size=2, alpha=0.5) +
            theme_minimal() +
            scale_y_log10(limits=y_limits) +
            scale_x_date(limits=x_limits) +
            geom_vline(aes(xintercept = today, color="Dagens datum")) +
            geom_vline(aes(xintercept = inflection_date, color="Inflektionspunkt"))

    })
}

shinyApp(ui = ui, server = server)
