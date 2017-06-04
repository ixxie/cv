

# Graphical Parameters
par <- list()
    par$col = c( "darkorange", "grey50", "gray80", "chartreuse2", "deepskyblue3")
    par$alp = c(10,40,70)
    par$basealp = 90

# Input path
par$i <- "./in/" 
# Output directory
par$o <- "./out/"

source("./in/code/skillpie.R")


makeSet(par)