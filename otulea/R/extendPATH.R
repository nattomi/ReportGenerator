## For adding directories to path (they will be ignored if they are already there). It is only needed because I can't find any better way to fix my somewhat broken TexLive installation (binaries are not found when apache2 tries to run them).

if (FALSE) {
path <- "/usr/local/texlive/2012/bin/i386-linux"
Sys.getenv("PATH")
extendPATH(path)
Sys.getenv("PATH")
}

extendPATH <- function(path) {
  oldpath <- Sys.getenv("PATH")
  PATH <- unlist(strsplit(oldpath,":"))
  "/usr/bin" %in% PATH
  if (!(path %in% PATH)) {
    PATH <- c(path,PATH)
    newpath <- paste(PATH,collapse=":")
    Sys.setenv(PATH=newpath)
  }
}
  
  
