## GIVES FEEDBACK ABOUT ABILITIES TO STUDENT
if (FALSE) {
docTree <- doc.alphalist
alphaID <- "2.2.09"
getUserDescription(docTree,alphaID)
getExample(docTree,alphaID)
}

## gets the user description associated to a certain alphaID
getUserDescription <- function(docTree,alphaID) {
  ans <- xpathApply(docTree,paste("//alphanode[@alphaID='",alphaID,"']",sep=""), xmlGetAttr, "userdescription")
  ans[[1]]
}
## gets the example associated to a certain alphaID
getExample <- function(docTree,alphaID) {
  ans <- xpathApply(docTree,paste("//alphanode[@alphaID='",alphaID,"']",sep=""), xmlGetAttr, "example")
  ans[[1]]
}
