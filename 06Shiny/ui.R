#ui.R 

library(shiny)
library(ggplot2)
statesList <- c("AL", "AK")


# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(

  # Application title
  headerPanel("Medicare by State"),

  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput("state", 
                "Select State:", 
                statesList)
  ),

  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
  )
))
