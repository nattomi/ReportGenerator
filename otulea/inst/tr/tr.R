## SETTINGS
##green <- rgb(193,255,193)
##yellow <- rgb(255,246,143)
##blue <- rgb(135,216,255)
x <- tr$Schreiben

table.print <- function(x) {
  l <- length(x$aufgabe) 
  cat("\\begin{tabularx}{\\textwidth}{@{}X@{}}\n")
  for (i in 1:l) {
    cat("  \\hline\n") # start of outer cycle
    symb <- switch(x$tendency[i],down="$\\Downarrow$",constant="$\\Rightarrow$",up="$\\Uparrow$","")
    cat("  \\rowcolor{",x$color[i],"}[0pt][0pt]",x$aufgabe[i]," ",symb,"\\\\\n",sep="")
    cat("  \\hline\n")
    ll <- length(x$description[[i]])
    for (j in 1:ll) {
      cat("  \\rowcolor{",x$color[i],"}[0pt][0pt]$\\bullet$ ",x$description[[i]][j],"\\\\\n",sep="")
    }
    cat("  \\hline\n")
  }
  cat("\\end{tabularx}\n")
}

Lesen <- c("1.2.1","1.2.2","1.3.2","1.3.3","1.3.4")
Lesen.description <- list(c("Kann Zeitpläne sinnentnehmend lesen (Dokument literacy).","Komplexität (Konsonantenhäufungen) recodieren und dekodieren."),"Kann Wörter mit ansteigender Komplexität (Konsonantenhäufung) recodieren und decodieren.", "Kann Wörter mit ansteigender Komplexität (Konsonantenhäufung) recodieren und decodieren.",c("Kann Sätze mit ansteigender Länge sinnerfassend lesen.", "Kann SPO-Sätze und SPO-Sätze mit Einfügungen sinnerfassend lesen."),c("Kann einzelne Wörter im Satzkontext erlesen. Kann orthografisch komplexere Wörter erlesen.","Kann Sätze mit ansteigender Länge sinnerfassend lesen.","Kann SPO-Sätze und SPO-Sätze mit Einfügungen sinnerfassend lesen."))
Lesen.color <- c("A",rep("B",4))
Lesen.tendency <- c(rep(NA,5))
Schreiben <- c("2.1.1","2.1.2","2.1.3","2.1.4","2.1.5","2.1.6")
Schreiben.description <- list(c("Kann Wörter mit Silben, die aus einem Vokal oder einem Diphtong bestehen, schreiben.", "Kann Zahlen als Ziffern schreiben.", "Kann Wörter mit offenen Silben schreiben."),"Kann lautierte einzelne Laute verschriftlichen.","Kann Groß- und Kleinbuchstaben in Druckschrift unterscheiden.", "Kann Wörter mit Silben, die aus einem Vokal oder Diphtong bestehen schreiben (O-ma, Au-to)", "Kann Zahlen bis 20 als Zahl schrieben", "Kann in einem logographischen Zugriff Standardanreden wie „Liebe“ oder „Hallo“ groß schreiben.")
Schreiben.color <- c(rep("A",4),rep("C",2))
Schreiben.tendency <- c("up","up","constant","up","constant","constant")
Sprache <- c("3.1.1","3.1.2","3.1.3","3.1.4","3.2.1","3.2.2","3.2.3")
Sprache.description <- list("Kann prädikative Kongruenz im Präsens in einem kurzen Satz erkennen.","Kann verbale Kongruenz im Präsenz in einem kurzen Satz erkennen.", "Kann nominale Kongruenz in einem kurzen Satz erkennen.", "Kann den passenden Genetiv in einem kurzen Satz erkennen.", "Kann prädikative Kongruenz im Perfekt in einem mäßig kurzen Satz erkennen.", "Kann verbale Kongruenz im Perfekt in einem mäßig kurzen Satz erkennen.", "Kann nominale Kongruenz im Akkusativ in einem mäßig kurzen Satz erkennen")
Sprache.color <- c(rep("A",3),"B",rep("C",3))
Sprache.tendency <- c("up","constant","up","up","constant","constant","constant")
Mathe <- c("4.1.1","4.1.2","4.1.3","4.1.4","4.2.1","4.2.3")
Mathe.description <- list("Kann Mengen im Zehner-, Hunderter- und höheren Bereichen erfassen.", "Kann Ziffern und Zahlen 1-1000 erkennen.", "Kann Zahlen von 10 bis 100 erkennen.", "Kann Ziffern und Zahlen 100 bis 1000 erkennen.", "Kann Einer-Ziffern im Kopf addieren", c("Kann Einer- und Zehner-Zahlen im Kopf zusammen zählen", "Kann Zehner- und Einer-Zahlen im Kopf zusammen zählen."))
Mathe.color <- c(rep("A",3),rep("C",3))
Mathe.tendency <- c("constant","constant","up","down","constant","constant")

tr <- list(Lesen=list(aufgabe=Lesen,description=Lesen.description,color=Lesen.color,tendency=Lesen.tendency),
           Schreiben=list(aufgabe=Schreiben,description=Schreiben.description,color=Schreiben.color,tendency=Schreiben.tendency),
           Sprache=list(aufgabe=Sprache,description=Sprache.description,color=Sprache.color,tendency=Sprache.tendency),
           Mathe=list(aufgabe=Mathe,description=Mathe.description,color=Mathe.color,tendency=Mathe.tendency))
attributes(tr) <- c(attributes(tr),list(participant="XQAT2", date=as.Date("2012-2-14")))

## printing stuff
sink("Lesen.tex")
table.print(tr$Lesen)
sink()
sink("Schreiben.tex")
table.print(tr$Schreiben)
sink()
sink("Sprache.tex")
table.print(tr$Sprache)
sink()
sink("Mathe.tex")
table.print(tr$Mathe)
sink()
