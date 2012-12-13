## EXAMPLES
if (FALSE) {
library(otulea)
guf <- "../inst/www/data/user/6CKBT/6CKBT.xml"
guf.df <- guf2df(guf)
sort.guf(guf.df)
sort(guf.df)
}

## extracts date-time information from a vector
## of path strings to test-result files
getDateTime <- function(x) {
  ans <- lapply(strsplit(x,"_"),function(x) do.call("ISOdatetime",as.list(as.integer(x[2:7]))))
  ans <- unlist(ans)
  class(ans) <- c("POSIXct","POSIXt")
  ans
}

## sorts a data frame extracted from a global user file
## according to columns data,subject and level
sort.guf <- function(guf.df) {
  ord <- order(getDateTime(guf.df$data),
               guf.df$subject,
               guf.df$level)
  guf.df[ord,]
}


