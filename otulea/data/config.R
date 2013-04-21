## Configure directories
packagePath <- find.package("otulea", lib.loc=NULL, quiet = TRUE) ## this line is not needed if file paths are hard-coded
## edit the right sides before installing the package
usersDir <- file.path(packagePath,"www/data/user") 
alphalist <- file.path(packagePath,"www/data/item/alphalist/alphalist.XML")
templateFiles <- c(haken="www/feedback/template/haken.pdf",
                                         leiter="www/feedback/template/leiter.pdf",
                                         userfeedback="www/feedback/template/userfeedback.tex")
templateFiles <- sapply(templateFiles,function(x) file.path(packagePath,x))
## cleaning up
rm(packagePath) ## not needed if paths are hard-coded
## On my server, I need the following settings
##usersDir <- "/var/www/otulea/data/user"
##alphalist <- "/var/www/otulea/data/item/alphalist/alphalist.XML"
