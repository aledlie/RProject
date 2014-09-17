#ui.R 

library(shiny)
options(java.parameters="-Xmx2g")
library("ggplot2")
library(rJava)
library(RJDBC)

jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="/Library/Java/JavaVirtualMachines/jdk1.7.0_65.jdk/Contents/Home/ojdbc6.jar")
con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "c##cs347_zi322", "orcl_zi322")

statesList <- dbGetQuery(con, "SELECT DISTINCT State FROM MC_Providers")
outpatientProcedures <- dbGetQuery(con, "SELECT Description FROM MC_OutpatientServices")


# Define UI for application that plots random distributions 
shinyUI(pageWithSidebar(
  
  # Application title
  headerPanel("Outpatient Procedure Costs"),
  
  # Sidebar with a slider input for number of observations
  sidebarPanel(
    selectInput("procedure", 
                "Select Procedure:", 
                outpatientProcedures),
    sliderInput("maxProcCharge", "Select Average Procedure Charge Threshold",
                min = 12, max = 45000, value = 22000)
  ),
  
  # Show a plot of the generated distribution
  mainPanel(
    plotOutput("distPlot")
  )
))
