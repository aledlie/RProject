######################
##      Set-up      ##
######################

#load libraries needed
library(shiny)
library(shinyapps)

#connect to Oracle database
options(java.parameters="-Xmx2g")
jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="~/ojdbc7.jar")
con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "c##cs347_zi322", "orcl_zi322")

########################################
##  Import tables into R from Oracle  ##
########################################

#Import Smaller tables
HCAHPSMeasure = dbGetQuery(con, "Select * From mc_HCAHPSMeasure")
InpatientServices <- dbGetQuery(con, "Select * from mc_InpatientServices")
Providers = dbGetQuery(con, "Select * from mc_Providers")
OutpatientServices <- dbGetQuery(con, "Select * from mc_OutpatientServices")

#Inport Outpatient Visits Table
OutpatientVisits <- dbGetQuery(con, "select * from mc_OutpatientVisits WHERE ID BETWEEN 0 and 30000")
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits WHERE ID BETWEEN 30001 and 60000"))
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits WHERE ID BETWEEN 60001 and 90000"))
OutpatientVisits = rbind(OutpatientVisits, dbGetQuery(con, "select * from mc_OutpatientVisits WHERE ID BETWEEN 90001 and 100000"))

#Import Inpatient Visits Table
InpatientVisits <- dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 0 and 30000")
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 30001 and 60000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 60001 and 90000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 90001 and 100000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 100001 and 130000"))
InpatientVisits = rbind(InpatientVisits, dbGetQuery(con, "select * from mc_InpatientVisits WHERE ID BETWEEN 130001 and 160000"))

###################################
## Run queries to get dataframes ##
###################################

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

outpatientCostByHospital = dbGetQuery(con, 
"SELECT mc_Providers.Name as Hospital, AVG(mc_OutPatientVisits.AverageSubmittedCharges) as AvgBilledCost 
FROM mc_OutPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_OutPatientVisits.ProviderID 
GROUP BY mc_Providers.Name")

InpatientCostByCity = dbGetQuery(con, 
"SELECT mc_Providers.City as City, AVG(mc_InPatientVisits.CoveredCharges) as AvgBilledCost 
FROM mc_InPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_InPatientVisits.ProviderID 
GROUP BY mc_Providers.City")

InpatientCostByState = dbGetQuery(con, 
"SELECT mc_Providers.State as State, AVG(mc_InpatientVisits.CoveredCharges) as AvgBilledCost 
FROM mc_InpatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_InpatientVisits.ProviderID 
GROUP BY mc_Providers.State")

InpatientCostByHospital = dbGetQuery(con, "
SELECT mc_Providers.Name as Hospital, AVG(mc_InPatientVisits.CoveredCharges) as AvgBilledCost 
FROM mc_InPatientVisits 
INNER JOIN mc_Providers 
ON mc_Providers.ID = mc_InPatientVisits.ProviderID 
GROUP BY mc_Providers.Name")

PatientsRated9or10 = dbGetQuery(con, "
Select MC_Providers.Name, MC_Hospital_Reviews.AnswerPercent FROM MC_Providers
INNER JOIN MC_Hospital_Reviews 
ON MC_Providers.ID = MC_Hospital_Reviews.ProviderID
WHERE MC_hospital_reviews.SurveyID = 'H_HSP_RATING_9_10' AND
MC_Hospital_Reviews.ANSWERPERCENT != 'null'")
PatientsRated9or10$ANSWERPERCENT <- as.numeric(PatientsRated9or10$ANSWERPERCENT)

CostVSRating = dbGetQuery(con, "
Select Mc_Hospital_Reviews.Answerpercent AS Rating, Mc_Hospital_Reviews.SurveyID AS Question, 
MC_OutpatientVisits.AverageSubmittedCharges AS Cost, MC_OutpatientVisits.AVERAGETOTALPAYMENTS AS InsuredCost, MC_OutpatientServices.Description AS Procedure,
MC_Providers.Name, MC_Providers.State, MC_Providers.HOSPITALREFERRALREGION AS Region
From Mc_Hospital_Reviews
INNER JOIN MC_OutpatientVisits
ON Mc_Hospital_Reviews.ProviderID = MC_OutpatientVisits.ProviderID 
INNER JOIN MC_OutpatientServices
ON MC_OutpatientServices.ID = MC_OutpatientVisits.APCID
INNER JOIN MC_Providers
On MC_OutpatientVisits.ProviderID = MC_Providers.ID   
WHERE MC_Hospital_Reviews.ANSWERPERCENT != 'null'
                          ")

#############################
##  Get Data subsets in R  ##
#############################

Rated9or10 = subset(CostVSRating, QUESTION == 'H_HSP_RATING_9_10')
Rated7or8 = subset(CostVSRating, QUESTION == 'H_HSP_RATING_7_8')
Rated0to6 = subset(CostVSRating, QUESTION == 'H_HSP_RATING_0_6')
DefinitelyRecommend = subset(CostVSRating, QUESTION == 'H_RECMND_DY')
ProbablyRecommend = subset(CostVSRating, QUESTION == 'H_RECMND_PY')
NotRecommend = subset(CostVSRating, QUESTION == 'H_RECMND_DN')
TexasQuery = subset(CostVSRating, STATE == 'TX')
AustinQuery = subset(TexasQuery, REGION == 'TX - Austin')

AverageCostBy910Rating <- aggregate(cbind(COST, INSUREDCOST) ~ PROCEDURE, Rated9or10, mean)
AverageCostBy910Rating$RATING <- as.numeric(AverageCostBy910Rating$RATING) 
InpatientVisits$TOTALPAYMENTS <- as.numeric(InpatientVisits$TOTALPAYMENTS)

costs <- table(AverageCostBy910Rating)
ex <- barplot(costs)

p <- subset(OutpatientVisits, APCID == 12)
p <- mean(p$AVERAGESUBMITTEDCHARGES)
TexasCostByProcedure <- aggregate(INSUREDCOST ~ PROCEDURE, TexasQuery, mean)

######################
##      Plots       ##
######################

p1 <- ggplot(InpatientCostByState, aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
p2 <- ggplot(outpatientCostByState, aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
p3 <- hist(InpatientVisits$TOTALPAYMENTS, main = "Inpatient Procedure Cost", xlab = "Average Ammount Billed Per Procedure", ylab = "# of Hospitals", xlim = c(0, 60000))
p4 <- hist(OutpatientVisits$AVERAGESUBMITTEDCHARGES, main = "Outpatient Procedure Cost", xlab = "Average Amount Billed Per Procedure", xlim = c(0, 12000))
p5 <- hist(PatientsRated9or10$ANSWERPERCENT, main = "Patient Satisfaction \nRatings", xlab = "Percent of Patients Who Rated \n Their Hospital 9+ out of 10", ylab = "# of Hospitals", xlim = c(25, 100))
p6 <- ggplot(AverageCostBy910Rating, aes(x = RATING, y = COST)) + geom_point() + coord_flip()
p7 <- ggplot(Rated9or10, aes(x = RATING, y = COST)) + geom_point() + facet_wrap(~PROCEDURE)
p8 <- ggplot(Rated9or10, aes(x = RATING, y = COST)) + geom_point() + facet_wrap(~STATE)
#p9 <- hist(TexasQuery$UNINSUREDCOST, main = "Texas Outpatient Procedure \nCost", xlab = "Cost")
p10 <- ggplot(TexasCostByProcedure, aes(x = Description, y = UNINSUREDCOST)) + geom_point() + coord_flip()
p11 <- ggplot(TexasQuery, aes(x = RATING, y = COST)) + geom_point() + facet_wrap(~PROCEDURE)
p12 <- ggplot(AustinQuery, aes(x = RATING, y = COST)) + geom_point() + facet_wrap(~PROCEDURE)