
source("./code/tables.R")

# Main function for creating the holoplot:
makeSkills <- function(par=list())
{


    par %>% makeSet %>% loadTables -> set


    set$tab$skills[,c("field","level","skill")] %>%
        filterDups %>%
        filterMax("skill", "level") %>% 
        mapAes("field", par$col, "col") %>%
        mapAes("level", par$alp, "alp") %>%
        seqTable("field") %>%
        makeTheta %>% 
        nestPie("field", "skill", "alp", par$lab, par$col, par$alp) -> set$plot$skillpie

    set$tab$skills %>% 
        facTable(c("phase","field","level")) %>%
        fluxBars("phase", "field", "freq", "level", par$col) -> barplots 

    set$plot <- c(set$plot, barplots)
    
    savePdf(set$plot, "./plots/")

    return(set)

}