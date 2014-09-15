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

head(InpatientVisits)

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
MC_OutpatientVisits_2.AverageSubmittedCharges AS Cost, MC_OutpatientServices.Description
From Mc_Hospital_Reviews
INNER JOIN MC_OutpatientVisits_2
ON Mc_Hospital_Reviews.ProviderID = MC_OutpatientVisits_2.ProviderID 
INNER JOIN MC_OutpatientServices
ON MC_OutpatientServices.ID = MC_OutpatientVisits_2.APCID
                          ")

aggregate(cost ~ rating, CostVSRating(QUESTION = 'H_HSP_RATING_9_10'), mean)

p1 <- ggplot(InpatientCostByState, aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
p2 <- ggplot(outpatientCostByState, aes(x = STATE, y = AVGBILLEDCOST)) + geom_point() + coord_flip()
p3 <- hist(InpatientVisits$TotalPayments, main = "Inpatient Procedure Cost", xlab = "Average Ammount Billed Per Procedure")
p4 <- hist(OutpatientVisits$AVERAGESUBMITTEDCHARGES, main = "Outpatient Procedure Cost", xlab = "Average Ammount Billed Per Procedure")
p5 <- hist(PatientsRated9or10$ANSWERPERCENT, main = "Patient Satisfaction", xlab = "Patients Rated Hospital 9 or 10")
p6 <- barplot(InpatientCostByState$AVGBILLEDCOST, main="Inpatient Procedures ", horiz=TRUE, ylab="State", xlab = "Average Cost")
p7 -> plot(CostVSRating$RATING ~ CostVSRating$Cost)
