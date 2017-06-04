
source("./code/tables.R")

# Main function for creating the holoplot:
makeSkills <- function(par=list())
{


    par %>% makeSet %>% loadTables -> set

    set %>% filterMax %>%  countSkills %>% countFields %>% makeColors %>% sliceSet %>% makeSkillpie -> set
  
    set %>% makeHistory -> set

    set %>% savePdfs

}