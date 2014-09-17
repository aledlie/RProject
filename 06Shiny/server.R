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
  
  outpatientCostByState = dbGetQuery(con, queryString)
  # return outpatientCostByState
}

getProcedureMap <- function(procedureName, limitCharge) {
  queryString <- paste("SELECT * FROM TEMP INNER JOIN mc_outpatientvisits 
                       ON temp.id = mc_outpatientvisits.providerid 
                       INNER JOIN mc_outpatientservices ON mc_outpatientservices.ID = mc_outpatientVisits.APCID 
                       where mc_outpatientservices.description = '", procedureName, "'",
                       "and mc_outpatientvisits.averagesubmittedcharges < ", limitCharge , sep="")
  print(queryString)
  result <- dbGetQuery(con, queryString)
}

shinyServer(function(input, output) {
  
  states <- dbGetQuery(con, "SELECT DISTINCT State FROM MC_Providers")
  outpatientProcedures <- dbGetQuery(con, "SELECT Description FROM MC_OutpatientServices")
  maxes <- dbGetQuery(con, "Select MC_OutPatientServices.Description, MAX(MC_OutpatientVisits.AverageSubmittedCharges) as Max 
                      FROM MC_OutPatientVisits INNER JOIN MC_OutPatientServices
                      ON MC_OutPatientVisits.APCID = MC_OutPatientServices.ID
                      GROUP BY MC_OutPatientServices.Description")
  
  # This function only runs when the state input is changed
  #   dataset <- reactive(function() {
  #     getOutpatientCostByState(input$state)
  #   })
  dataset <- reactive(function(){ 
    print(input$state)
    getOutpatientCostByState(input$state)
    getProcedureMap(input$procedure, input$maxProcCharge)
  })
  
  max <- reactive(function() {
    max1 <- subset(maxes, DESCRIPTION == input$procedure)
    result <-max1$MAX
  })
  
  output$distPlot <- renderPlot({
    
    # Get query results
    
    # generate an rnorm distribution and plot it
    # dist <- rnorm(input$state)
    # hist(dist)
    medicareData <- dataset()
    #   render map plot
    map(database= "usa", ylim=c(45,90), xlim=c(-160,-50), col="grey80", fill=TRUE, projection="gilbert", orientation= c(90,0,225))
    
    lon <- medicareData$LONGITUDE 
    lat <- medicareData$LATITUDE  
    coord <- mapproject(lon, lat, proj="gilbert", orientation=c(90, 0, 225))  #convert points to projected lat/long
    points(coord, pch=20, cex=0.4, col=4)  #plot converted points
    #     p2 <- ggplot(dataset(), aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
    #     p2
  })
})
