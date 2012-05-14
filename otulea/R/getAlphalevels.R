## OTULEA MAIN ROUTINE
## this is a complete rewrite from scratch

## SETTINGS
user <- "6CKBT" ## user id as character stringíí
subject <- "Schreiben" ## What are the possible values here? /Maybe it's not important/ (character string?)
level <- "Mittel" ## What are the possible values here? /Maybe it's not important/ (character string?)
eval <- A1 ## is in 1:4
## possible values here: 
## 1: (A1) What do I know?
## 2: (A2) What can be improved?
## 3: (A3) What I will be able of, if I will do some more?
## 4: (B) Teachers' report.
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number

## CONSTANTS
usersDir <- "www/data/user"
alphalist <- "www/data/item/alphalist/alphalist.XML"

## REQUIREMENTS
library(otulea) 
library(XML) ## later on we can leave this out because it's a dependency


## MAIN

## Information extraction
## location of global user file
userDir <- file.path(usersDir,user)
guf <- file.path(userDir,paste(user,"xml",sep=".")) ## later on we rewrite this with system.file
## tests taken by the user (returned as an XMLNodeSet)
tests <- list.tests(guf)
## getting the last test taken
tests.last <- last(tests)
testresults <- file.path(userDir,testToDf(tests.last)$data)
markings <- getMarkings(testresults)
markings

## Derivation of results

## What do I know?
thresholds <- tapply(as.numeric(markings[,"mark"]),markings[,"alphalevel"],mean)
thresholds
## getting alphalevels above the specified threshold
alphas.A1 <- sort(names(thresholds)[thresholds >= threshold/100],decreasing=TRUE)
alphas.A1
## first maxListings entries
alphas <- alphas.A1[1:min(length(alphas.A1),maxListings)]
alphas

## What can be improved?
## getting alphalevels above the specified threshold
alphas.A2 <- sort(names(thresholds)[thresholds <= threshold/100],decreasing=FALSE) ## Only difference compared to A1!!
alphas.A2
## first maxListings entries
alphas <- alphas.A2[1:min(length(alphas.A2),maxListings)]
alphas

## What will I be able of, if I will do some more?
alphas.A3 <- sort(names(thresholds)[thresholds >= threshold/100],decreasing=TRUE)
alphas.A3
##xmlParse(alphalist) 
## I must include alphalist as .rda and a put a script into inst which converts an alphalist to this form



## getting alphalevels below the specified threshold
alphas.all <- sort(names(thresholds)[thresholds >= threshold/100],decreasing=TRUE)
## seems like it's reasonable to use maxListinsg here
alphas <- alphas.all[1:min(length(alphas.all),maxListings)]
alphas
## It remains to look it up in alphalist.XML 
## specification is unclear here (how would I know if I should take both userdesc and example?)
## I suppose I need both in this case.


## SWITCH statement
     require(stats)
     centre <- function(x, type) {
       switch(type,
              A1 = mean(x),
              A2 = median(x),
              A3 = mean(x, trim = .1))
     }

     x <- rcauchy(10)
     centre(x, "A1")
     centre(x, "A2")
     centre(x, "trimmed")

thresholds <- tapply(as.numeric(markings.df[,"mark"]),markings.df[,"alphalevel"],mean)
## getting alphalevels above the specified threshold
alphas.all <- sort(names(thresholds)[thresholds >= threshold/100],decreasing=TRUE)
## seems like it's reasonable to use maxListinsg here
alphas <- alphas.all[1:min(length(alphas.all),maxListings)]
alphas





## QUESTIONS
## -- possible values of subject and level and where is it used?
## -- what does it mean exactly?
## -- is maxLisings used in all eval modes?
## -- can I trust in the ordering of tests within guf, or should I perform an additional ordering?
## -- when calculating the threshold, is pointuse maxpoint="1" always the same? 
## -- thresholds equal or greater or equal

## NOTES
## 1. no ordering is done, we use the natural ordering
##    I might need to enhance it?
## 2. using xpathApply somehow?
