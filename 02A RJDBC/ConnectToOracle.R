library(RJDBC)
library(rJava)

options(java.parameters="-Xmx2g")

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

options(java.parameters="-Xmx2g")
jdbcDriver <- JDBC(driverClass="oracle.jdbc.OracleDriver", classPath="/Library/Java/JavaVirtualMachines/jdk1.7.0_65.jdk/Contents/Home/ojdbc6.jar")
con <- dbConnect(jdbcDriver, "jdbc:oracle:thin:@128.83.138.158:1521:orcl", "c##cs347_zi322", "orcl_zi322")


