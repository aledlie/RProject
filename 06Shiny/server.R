# server.R

library(shiny)
options(java.parameters="-Xmx2g")
library("ggplot2")
library(rJava)
library(RJDBC)

jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="/Library/Java/JavaVirtualMachines/jdk1.7.0_65.jdk/Contents/Home/ojdbc6.jar")
con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "c##cs347_zi322", "orcl_zi322")


outpatientCostByState = dbGetQuery(con, 
                                   "SELECT mc_Providers.State as State, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
                                   FROM mc_OutPatientVisits 
                                   INNER JOIN mc_Providers 
                                   ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
                                   GROUP BY mc_Providers.State")

tail(outpatientCostByState)

getOutpatientCostByState <- function(state) {
  # Construct query string
  queryString <- paste("SELECT mc_Providers.State as State, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
                  FROM mc_OutPatientVisits
                  INNER JOIN mc_Providers 
                  ON mc_Providers.ID = mc_OutPatientVisits.ProviderID  
                  WHERE mc_Providers.State = '", state,
                  "' GROUP BY mc_Providers.State", sep="")
#   queryString <- "SELECT mc_Providers.State as State, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
#                   FROM mc_OutPatientVisits
#                   INNER JOIN mc_Providers 
#                   ON mc_Providers.ID = mc_OutPatientVisits.ProviderID  
#                   WHERE mc_Providers.State = 'AL' 
#                   GROUP BY mc_Providers.State"
  outpatientCostByState = dbGetQuery(con, queryString)
  # return outpatientCostByState
}

shinyServer(function(input, output) {
  
  # This function only runs when the state input is changed
#   dataset <- reactive(function() {
#     getOutpatientCostByState(input$state)
#   })
  dataset <- reactive(function(){ 
    print(input$state)
    getOutpatientCostByState(input$state)
  })
  
  output$distPlot <- renderPlot({
    
    # Get query results
    
    # generate an rnorm distribution and plot it
    # dist <- rnorm(input$state)
    # hist(dist)
    dataset()
    p2 <- ggplot(dataset(), aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
    p2
  })
})
