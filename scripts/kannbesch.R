## CONSTANTS
alphalist <- "../item/alphalist/alphalist.xml"
dir.items <- "../item"
## INCLUDES
library(XML)

## ROUTINES
alphalist2df <- function(alphalist) {                                       
  if (is.character(alphalist)) alphalist <- xmlInternalTreeParse(alphalist) 
  alphalist.list <- xmlToList(alphalist)                                    
  alphalist.list <- alphalist.list[names(alphalist.list)=="alphanode"]      
  ans <- data.frame(t(as.data.frame(alphalist.list)),stringsAsFactors=F)    
  rownames(ans) <- NULL                                                     
  ans                                                                       
} 

## getting the marking sections of various testresult files
## and merge them into a data frame containing character strings
##testresults <- testresults[[1]]
getMarkings <- function(testresults) {
  markings <- lapply(testresults, function(x) {
    x.parse <- xmlParse(x)
    x.marking <- getNodeSet(x.parse, "//marking")
    getNodeSet(x.marking[[1]],"//mark")
  })
  markings.all <- do.call("c",markings)
  markings.all2 <- lapply(markings.all,function(x) c(xmlAttrs(x)[c("itemnumber","alphalevel")],mark=xmlValue(x)))
  markings.all3 <- lapply(markings.all2,function(x) {
    m <- x[["mark"]]
    if (m=="" | m=="failed") x[["mark"]] <- 0
    x
  })
  markings.df <- as.data.frame(do.call("rbind",markings.all3))
  attributes(markings.df)<- c(attributes(markings.df),attributes(testresults))
  markings.df
}

## MAIN
alphalist.df <- alphalist2df(alphalist)
alphalist.df[["alphaID"]] # list of all ab.desc. IDs
## list of items
items <- list.files(dir.items)
items <- items[substr(items,1,1) %in% as.character(1:4)]
names(items) <- items
## 
dat0 <- lapply(items,function(item) {
  file.item <- file.path(dir.items,item,paste(item,"xml",sep="."))
  if (file.exists(file.item)) cbind(item,getMarkings(file.item)[,c("itemnumber","alphalevel")])
})
dat1 <- do.call("rbind",dat0)
rownames(dat1) <- NULL
names(dat1) <- c("item","itemnumber","alphaID")
dat2 <- merge(dat,alphalist.df[,c("alphaID","description")])
dat3 <- dat2[,c("item","itemnumber","alphaID","description")]
head(dat3)
dat4 <- dat3[order(dat3$item,dat3$itemnumber,dat3$alphaID),]
write.csv(dat4,file="dt0.csv",row.names=FALSE)
