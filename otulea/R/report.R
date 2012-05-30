library(otulea)
user <- "6CKBT" ## user id as character string
threshold <- 50 ## percentage
maxListings <- 3 ## maximal number of results listed
alphalist.df <- alphalist2df(alphalist)
alphas <- getAlphalevels(user,threshold,maxListings,alphalist.df)

colnames(alphalist.df)
ind.A1 <- match(alphas$A1,alphalist.df$alphaID)
alphalist.df[ind.A1,c("userdescription","example")]
