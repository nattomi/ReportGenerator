## Configure directories
packagePath <- find.package("otulea", lib.loc=NULL, quiet = TRUE) ## this line is not needed if file paths are hard-coded
## edit the right sides before installing the package
usersDir <- file.path(packagePath,"data/user") 
alphalist <- file.path(packagePath,"data/item/alphalist/alphalist.XML")
templateFiles <- c(haken="template/haken.pdf",
                   leiter="template/leiter.pdf",
                   userfeedback="template/userfeedback.tex")
templateFiles <- sapply(templateFiles,function(x) file.path(packagePath,x))
## cleaning up
rm(packagePath) ## not needed if paths are hard-coded
## On my server, I need the following settings
##usersDir <- "/var/www/otulea/data/user"
##alphalist <- "/var/www/otulea/data/item/alphalist/alphalist.XML"
