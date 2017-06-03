

# Graphical Parameters
pars <- list()
    pars$col = c( "darkorange", "grey50", "gray80", "chartreuse2", "deepskyblue3")
    pars$alp = c(10,40,70)
    pars$basealp = 90

#spath <- normalizePath(dirname(sys.frame(1)$ofile))
pars$path <- "./skills.csv" #paste0(spath,"/skillpie.R")/home/ixxie/Projects/Admin/CV/R

pars$out <- "./skills.pdf"

source("./R/skillpie.R")


makeHolo(pars)