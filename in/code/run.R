

# Graphical Parameters
par <- list()

par$col = c( 
                Design="darkorange", 
                Organization="grey50", 
                Discourse="gray80", 
                Science="chartreuse2", 
                Technology="deepskyblue3"
            )

par$alp = c(10,40,70)
par$basealp = 90

par$lab <- c(
                Design="Technical \n Illustration & Brand \n Design",
                Organization="Impact Venture \n Organization & Operations \n Architecture",
                Discourse="Technical \n & Conceptual \n Writing",
                Science="Complex \n Model & Data \n Analytics",
                Technology="Reproducable \n Analytics & Publication \n Systems"
            )

# Input path
#par$i <- "./in/" 
# Output directory
#par$o <- "./out/"

source("./in/code/skills.R")

set <-makeSkills(par)