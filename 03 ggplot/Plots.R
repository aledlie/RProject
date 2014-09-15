options(java.parameters="-Xmx2g")
jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="~/ojdbc7.jar")
con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "c##cs347_zi322", "orcl_zi322")

#Import Smaller tables
HCAHPSMeasure = dbGetQuery(con, "Select * From mc_HCAHPSMeasure")
InpatientServices <- dbGetQuery(con, "Select * from mc_InpatientServices")
Providers = dbGetQuery(con, "Select * from mc_Providers")
OutpatientServices <- dbGetQuery(con, "Select * from mc_OutpatientServices")

#Inport Outpatient Visits Table
OutpatientVisits <- dbGetQuery(con, "select * from mc_OutpatientVisits_2 WHERE ID BETWEEN 0 and 30000")
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits_2 WHERE ID BETWEEN 30001 and 60000"))
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits_2 WHERE ID BETWEEN 60001 and 90000"))
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits_2 WHERE ID BETWEEN 90001 and 100000"))

#Import Inpatient Visits Table
InpatientVisits <- dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 0 and 30000")
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 30001 and 60000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 60001 and 90000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 90001 and 100000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 100001 and 130000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 130001 and 160000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 160001 and 190000"))

head(InPatientVisits)

outpatientCostByCity = dbGetQuery(con, 
"SELECT mc_Providers.City as City, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.City")

outpatientCostByState = dbGetQuery(con, 
"SELECT mc_Providers.State as State, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.State")

outpatientCostByHospital = dbGetQuery(con, "
SELECT mc_Providers.Name as Hospital, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.Name")

outpatientCostByCity = dbGetQuery(con, 
                                  "SELECT mc_Providers.City as City, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.City")

outpatientCostByState = dbGetQuery(con, 
                                   "SELECT mc_Providers.State as State, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.State")

outpatientCostByHospital = dbGetQuery(con, "
SELECT mc_Providers.Name as Hospital, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.Name")

graph1 <- ggplot(texas, aes(y = Rating, x = AverageCharge)) + geom_point()
graph2 <- ggplot(national, aes(y = Rating, x = AverageCharge)) + geom_point()
graph3 <- ggplot(austin, aes(y = AnswerPercent, x = AverageCharge)) + geom_point()
graph4 <- ggplot(nationalBYProcedure, aes(y = AverageCharge, x = Procedure)) + geom_boxplot()
graph5 <- ggplot(AustinBYProcedure, aes(y = AverageCharge, x = Procedure)) + geom_boxplot()
graph6 <- ggplot(HoustonByProcedure, aes(y = AverageCharge, x = Procedure)) + geom_boxplot()
graph7 <- graph4 <- ggplot(HoustonByProcedure, aes(y = AverageCharge, x = Procedure)) + geom_violin() + coord_flip()
graph2 + facet_wrap(~Procedure)


ggplot(data = diamonds) + geom_histogram(aes(x = carat))
ggplot(data = diamonds) + geom_density(aes(x = carat, fill = "gray50"))
ggplot(diamonds, aes(x = carat, y = price)) + geom_point()
p <- ggplot(diamonds, aes(x = carat, y = price)) + geom_point(aes(color = color))
p + facet_wrap(~color) # For ~, see http://stat.ethz.ch/R-manual/R-patched/library/base/html/tilde.html and http://stat.ethz.ch/R-manual/R-patched/library/stats/html/formula.html
p + facet_grid(cut ~ clarity)
p <- ggplot(diamonds, aes(x = carat)) + geom_histogram(aes(color = color), binwidth = max(diamonds$carat)/30)
p + facet_wrap(~color) 
p + facet_grid(cut ~ clarity)


