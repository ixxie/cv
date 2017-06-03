

# Graphical Parameters
pars <- list()
    pars$col = c( "darkorange", "grey50", "gray80", "chartreuse2", "deepskyblue3")
    pars$alp = c(10,40,70)
    pars$basealp = 90

# Input path
pars$i <- "./in/" 
# Output directory
pars$o <- "./out/"

source("./in/R/skillpie.R")


makeSet(pars)