## FOR GETTING ALPHALEVELS ASSOCIATED TO 'A' TYPE EVALUATION MODES

## EXAMPLES
if (FALSE) {
library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
x <- getAlphalevelsA(user,threshold,maxListings,alphalist.df)
uncprsd <- uncompress(x,alphalist.df,c("userdescription","example","sound","alphaID"))

file <- "20120504_14_13_X0AT2.pdf"
subject <- attr(x,"subject")
level <- attr(x,"level")
alphalevels2xml(uncprsd,file,subject, level)
}


## FUNCTION
alphalevels2xml <- function(uncprsd,file,subject,level) {
  TAB <- "  "
  cat("<results>\n")
  ## adding 'print' node
  cat(TAB,'<print file="',file,'"/>\n',sep="")
  ## adding 'timestamp' node
  ts <- format(Sys.time(),"%Y%m%d%H%M%S")
  cat(TAB,'<timestamp order="YMDhms" value="',ts,'"/>\n',sep="")
  ## adding 'subject' node
  cat(TAB,'<subject value="',subject,'"/>\n',sep="")
  ## adding 'level' node
  cat(TAB,'<level value="',level,'"/>\n',sep="")
  ## adding 'eval' nodes
  modes <- names(uncprsd)
  ##mode <- modes[[1]]
  for (mode in modes) {
    cat(TAB,'<eval mode="',mode,'"',sep="")
    dat <- uncprsd[[mode]]
    nr <- nrow(dat)
    if (nr > 0) {
      cat('>\n')
      r <- 1
      for (r in 1:nr) {
        cat(TAB,TAB,'<alphanode alphaID="',dat[r,"alphaID"],'" userdescription="',dat[r,"userdescription"],'" example="',dat[r,"example"],'">\n',sep="")
      }
      cat(TAB,'</eval>\n',sep="")   
    } else cat('/>\n')
  }
  cat("</results>\n")
}
