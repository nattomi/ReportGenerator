## SETTINGS
dir.tests <- "/tmp/User-Usability-Test2013_all"
## REQUIREMENTS
library(XML)
## MAIN
users <- list.files(dir.tests)
##user <- users[4] # for testing
dat <- data.frame()
for (user in users) {
guf <- file.path(dir.tests,user,paste(user,"xml",sep="."))
doc <- xmlParse(guf)
r <- xmlRoot(doc)
if (!is.null(r[[1]])) {
  dat.user <- cbind(user=user,t(xmlSApply(r,xmlAttrs)))
  dat <- rbind(dat,dat.user)
}
}
write.csv(dat,file="/tmp/timestamps.csv",row.names=FALSE,quote=FALSE)
