library("ggplot2")
options(java.parameters="-Xmx2g")
library(rJava)
library(RJDBC)
library(maps)
library(mapproj)
library(zipcode)

jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="C:/Program Files/Java/jdk1.7.0/ojdbc7.jar")

# In the following, use your username and password instead of "CS347_prof", "orcl_prof" once you have an Oracle account
possibleError <- tryCatch(
  jdbcConnection <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "C##cs347_zi322", "orcl_zi322"), #zi322
  error=function(e) e
)
if(!inherits(possibleError, "error")){
  #med <- dbGetQuery(jdbcConnection, "select * from TEMP where rownum <= 1000")
  med <- dbGetQuery(jdbcConnection, "SELECT *
FROM TEMP INNER JOIN mc_outpatientvisits
ON temp.id = mc_outpatientvisits.providerid where mc_outpatientvisits.AVERAGESUBMITTEDCHARGES > 100")
  dbDisconnect(jdbcConnection)
}
head(med)

#data(med)
#data(zipcode)
#zipcode$region = substr(zipcode$zip, 1, 1)

#g = ggplot(data=med) + geom_point(aes(x=LONGITUDE, y=LATITUDE, colour=STATE))

# simplify display and limit to the "lower 48"
#g = g + theme_bw() + scale_x_continuous(limits = c(-125,-66), breaks = NULL)
#g = g + scale_y_continuous(limits = c(25,50), breaks = NULL)

# don't need axis labels
#g = g + labs(x=NULL, y=NULL)
#g

#gplot(med) + geom_histogram(aes(x = PROVIDERID))


map(database= "usa", ylim=c(45,90), xlim=c(-160,-50), col="grey80", fill=TRUE, projection="gilbert", orientation= c(90,0,225))
lon <- med$LONGITUDE  #fake longitude vector
lat <- med$LATITUDE  #fake latitude vector
coord <- mapproject(lon, lat, proj="gilbert", orientation=c(90, 0, 225))  #convert points to projected lat/long
points(coord, pch=20, cex=1.2, col=2)  #plot converted points

