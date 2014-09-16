library("ggplot2")
options(java.parameters="-Xmx2g")
library(rJava)
library(RJDBC)
library(maps)   #need to install
library(mapproj)#need to install
library(zipcode)

jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="C:/Program Files/Java/jdk1.7.0/ojdbc7.jar")

# In the following, use your username and password instead of "CS347_prof", "orcl_prof" once you have an Oracle account
possibleError <- tryCatch(
  jdbcConnection <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "C##cs347_zi322", "orcl_zi322"), #zi322
  error=function(e) e
)
if(!inherits(possibleError, "error")){
  #med <- dbGetQuery(jdbcConnection, "select * from TEMP where rownum <= 1000")
  med <- dbGetQuery(jdbcConnection, "SELECT * FROM TEMP INNER JOIN mc_outpatientvisits ON temp.id = mc_outpatientvisits.providerid where mc_outpatientvisits.AVERAGESUBMITTEDCHARGES > 100")
  med2 <- dbGetQuery(jdbcConnection, "SELECT * FROM TEMP INNER JOIN mc_outpatientvisits ON temp.id = mc_outpatientvisits.providerid where mc_outpatientvisits.AVERAGESUBMITTEDCHARGES < 100")
  med3 <- dbGetQuery(jdbcConnection, "SELECT * FROM TEMP INNER JOIN mc_outpatientvisits ON temp.id = mc_outpatientvisits.providerid INNER JOIN mc_outpatientservices ON mc_outpatientservices.ID = mc_outpatientVisits.APCID where mc_outpatientservices.description = ?", "Level I Debridement & Destruction")
  dbDisconnect(jdbcConnection)
}
head(med3)

map(database= "usa", ylim=c(45,90), xlim=c(-160,-50), col="grey80", fill=TRUE, projection="gilbert", orientation= c(90,0,225))
lon <- med$LONGITUDE 
lat <- med$LATITUDE  
coord <- mapproject(lon, lat, proj="gilbert", orientation=c(90, 0, 225))  #convert points to projected lat/long
points(coord, pch=20, cex=0.2, col=2)  #plot converted points

lon <- med2$LONGITUDE 
lat <- med2$LATITUDE  
coord <- mapproject(lon, lat, proj="gilbert", orientation=c(90, 0, 225))  #convert points to projected lat/long
points(coord, pch=20, cex=0.2, col=3)  #plot converted points

lon <- med3$LONGITUDE 
lat <- med3$LATITUDE  
coord <- mapproject(lon, lat, proj="gilbert", orientation=c(90, 0, 225))  #convert points to projected lat/long
points(coord, pch=20, cex=0.2, col=4)  #plot converted points