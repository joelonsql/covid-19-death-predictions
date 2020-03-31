library(shinydashboard)
library(tidyverse)
library(plotly)
library(drc)

country_name <- "Sverige"
first_death <- as.Date("2020-03-11")
input_deaths      <- c( 1, 1, 1, 2, 3, 7, 8,10,12,16,20,23,33,36,42,66,92,102,110,146,180)
input_predictions <- c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA, NA,124,136,167)

maxDeaths <- reactiveVal()
summaryVal <- reactiveVal()
graphDataVal <- reactiveVal()
inflectionDateVal <- reactiveVal()

base_data <- data.frame(deaths=input_deaths,day=1:length(input_deaths),predictions=input_predictions)
base_model <- drm(deaths ~ day, data = base_data, fct = LL.4(fixed=c(NA,0,NA,NA)))
summary <- summary(base_model)
y_limits <- c(1,10^round(log10(base_model$coefficients["d:(Intercept)"])))
x_limits <- c(first_death, max(
    first_death+as.integer(base_model$coefficients["e:(Intercept)"])*2,
    Sys.Date()+7
))

ui <- dashboardPage(
    dashboardHeader(title = "COVID-19"),
    dashboardSidebar(disable = TRUE),
    dashboardBody(
        fluidRow(
            box(
                plotOutput("graph")
            ),
            box(
                plotOutput("graph2")
            ),
            box(
                sliderInput("date",
                            "Datum:",
                            min = first_death,
                            max = Sys.Date(),
                            value = Sys.Date())
            ),
            infoBoxOutput("maxDeathsBox"),
            box(
                verbatimTextOutput("modelSummaryBox")
            )
        )
    )
)

server <- function(input, output) {
    output$graph <- renderPlot({

        data_points <- as.integer(input$date - first_death + 1)
        deaths      <- head(input_deaths, data_points)
        predictions <- head(input_predictions, data_points)

        data <- data.frame(deaths=deaths,day=1:length(deaths),predictions=predictions)
        model <- drm(deaths ~ day, data = data, fct = LL.4(fixed=c(NA,0,NA,NA)))
        model_summary <- summary(model)
        summaryVal(model_summary)
        steepness <- model$coefficients["b:(Intercept)"]
        deceased <- model$coefficients["d:(Intercept)"]
        inflection <- model$coefficients["e:(Intercept)"]
        inflectionDateVal(first_death + as.integer(inflection) - 1)

        maxDeaths(round(deceased))

        data$model <- NA
        predict_day <- length(deaths) + 1
        end_day <- max(as.integer(2*inflection), length(deaths) + 7)
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

        graphDataVal(data)
        
        ggplot(data, aes(x=day)) +
            geom_point(aes(y=deaths, color="Historik")) +
            geom_line(aes(y=model, color="Framtida prognos")) +
            geom_point(aes(y=predictions, color="Tidigare prognoser"), size=2, alpha=0.5) +
            theme_minimal() +
            scale_y_log10(limits=y_limits) +
            scale_x_date(limits=x_limits) +
            geom_vline(aes(xintercept = input$date, color="Dagens datum")) +
            geom_vline(aes(xintercept = inflectionDateVal(), color="Inflektionspunkt")) +
            xlab("Datum") +
            ylab("Döda") +
            ggtitle(paste0("COVID-19 - Dödsprognos - ", country_name),
                    subtitle = paste0("Prognos för ", predict_day, " : ", predict_total, " totalt varav ", predict_new, " nya")
            )

    })

    output$graph2 <- renderPlot({
        
        ggplot(graphDataVal() %>% subset(day >= (input$date-7) & day <= (input$date+7)), aes(x=day)) +
            geom_point(aes(y=deaths, color="Historik")) +
            geom_point(aes(y=model, color="Framtida prognos")) +
            geom_point(aes(y=predictions, color="Tidigare prognoser"), size=2, alpha=0.5) +
            geom_text(aes(y = deaths, label = deaths, color="Historik"),
                      vjust = "inward", hjust = "inward",
                      show.legend = FALSE, check_overlap = TRUE) +
            geom_text(aes(y = model, label = model, color="Framtida prognos"),
                      vjust = "inward", hjust = "inward",
                      show.legend = FALSE, check_overlap = TRUE) +
            theme_minimal() +
            xlab("Datum") +
            ylab("Döda") +
            ggtitle(paste0("COVID-19 - 7 dagars prognos - ", country_name))
        
    })
    
    output$maxDeathsBox <- renderInfoBox({
        infoBox(
            "MAX DÖDA", maxDeaths(), icon = icon("skull"),
            color = "purple"
        )
    })

    output$modelSummaryBox <- renderPrint({
        print(summaryVal())
    })
}

shinyApp(ui = ui, server = server)
