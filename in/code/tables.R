library(ggplot2)
library(magrittr)
library(plyr)



stripPath <- function(path)
{
    sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(filepath))
}

makeSet <- function(par=list())
{
    set <- list("par"=par, "tab"=list(), "plot"=list())
    return(set)
}
# Loads the data set from a csv file:
loadTables <- function(set)
{
    tables <- list.files("./in/tables")
    # Load skills.csv into dataframe
    for (table in tables)
    {
        tabname <- stripPath(table)   
        set$tab[[tabname]] <- read.csv(table)
        set$tab[[tabname]] <- data.frame(set$tab[[tabname]], stringsAsFactors=TRUE)
    }

    return(set)
}

makeHistory <- function(set)
{
    set$phases <- levels(set$skills$phase)

    set$history <- set$skills[,c("type","level", "phase")]
    
    return(set) 
}




# Filters out the maximum skill levels in case of duplicates:
filterMax <- function(set)
{
    nskills <- data.frame()
    for (s in levels(set$skills$skill))
    {
        # Load subframe that has skill s
        sfr <- set$skills[set$skills$skill==s, ]
        # Extract the row with maximum skill level
        nskills <- rbind(nskills,sfr[sfr$level==max(sfr$level),])
    }
    set$skills <- nskills
    
    return(set)
}

countTable <- function(set)
{
    set$tab

    for (t in set$tab)
    {
        # Initialize fields to count the number of skills per type:
        set$tab[[t]]$num <- numeric(nrow(set$skills))

        # Cycle through skill type and count the number of skills of that type:
        for (t in set$types)
        {
                set$skills[set$skills$type==t,]$num <- 
                    nrow(set$skills[set$skills$type==t,])
        }

        # Reorder the skills & fields tables by decending type class size and decending level:
        set$skills <- set$skills[with(set$skills,order(-num, type, -level)),]
        row.names(set$skills) <- 1:nrow(set$skills)
    }

    return(set)
}

# Counts type frequencies and orders tables by it:
countSkills <- function(set)
{
    # Initialize fields to count the number of skills per type:
    set$skills$num <- numeric(nrow(set$skills))

    # Cycle through skill type and count the number of skills of that type:
    for (t in set$types)
    {
            set$skills[set$skills$type==t,]$num <- 
                nrow(set$skills[set$skills$type==t,])
    }

    # Reorder the skills & fields tables by decending type class size and decending level:
    set$skills <- set$skills[with(set$skills,order(-num, type, -level)),]
    row.names(set$skills) <- 1:nrow(set$skills)

    return(set)
}

# Counts type frequencies and orders tables by it:
countFields <- function(set)
{
    # Initialize fields to count the number of skills per type:
    set$fields$num <- numeric(nrow(set$fields))

    # Cycle through skill type and count the number of skills of that type:
    for (t in set$types)
    {
        set$fields[set$fields$type==t,]$num <-  
                nrow(set$skills[set$skills$type==t,])
    }

    # Reorder the skills & fields tables by decending type class size and decending level:
    set$fields <- set$fields[with(set$fields,order(-num)),]
    row.names(set$fields) <- 1:nrow(set$fields)

    return(set)
}

# Infers the color set 
makeColors <- function(set)
{
    # Construct colors and alpha levels from skill type and level:
    set$fields$col <- set$par$col[match(set$fields$type, set$types)]
    set$skills$col <- set$par$col[match(set$skills$type, set$types)]
    set$skills$alp <- set$par$alp[set$skills$level]

    # But set the field alpha to base alpha.
    set$fields$alp <- set$par$basealp

    return(set)
}

# Computes a central slice angle from linear slice coordinates:
makeTheta <- function(table)
{
    # Compute slice width
    table$dif <- 360*(table$ymax - table$ymin)/table$ydif
    # Compute slice position 
    table$pos <- -(cumsum(table$dif) - 0.5*table$dif)
    # Compute slice center
    table$theta <- table$pos + ((table$pos)%/%180+1)*180  + 90

    return(table)
}

# Computes linear and angular dimensions of slices of the data tables:
sliceSet <- function(set)
{
    skills <- set$skills
    fields <- set$fields

    # Construct Y-Coord. Spans from the table order and calculate total height:
    skills$ymin <- as.numeric(1:nrow(skills))
    skills$ymax <- skills$ymin + 1.
    skills$ydif <- max(skills$ymax) - min(skills$ymin)

    # Derive corresponsing Y-Coord. for fields:
    for (t in fields$type)
    {
        fr <- skills[skills$type == t,]
        fields[fields$type==t,"ymin"] <- min(fr$ymin)
        fields[fields$type==t,"ymax"] <- max(fr$ymax)    
    }
    fields$ydif <- max(fields$ymax) - min(fields$ymin)

    # Calculate the angular coordinate of slices and output to set:
    set$skills <- makeTheta(skills)
    set$fields <- makeTheta(fields)
    return(set)

}


makeExp <- function(set)
{
    set$exps <- data.frame(type=list(), freq=list(), level=list())
    for (p in set$phases)
    {
        set$exps[[p]] <- data.frame()
    }
}

# Build ggplot object for a Expchart

makeExpchart <- function(set)
{
    for (phase in set$phases)
    {

        dat <- set$history[[phase]]

        set$plot[[paste0("expchart-", phase)]] <- 
            ggplot(dat, aes(type, )) +
                geom_bar(data=)
    
    }
}

# Build ggplot object for a Skillpie:
makeSkillpie <- function(set)
{
set$plot$skillpie <- 
    ggplot() + 
        geom_rect(
            data=set$skills,
            aes(
                fill=col, colour=col, alpha=alp, 
                ymax=ymax, ymin=ymin, 
                xmax=15, xmin=7
                )
            ) +
        geom_rect(
            data=set$fields,
            aes(
                fill=col, colour=col, alpha=alp, 
                ymax=ymax, ymin=ymin,
                xmax=7, xmin=0
                )
            ) + 
        scale_fill_manual(values=set$par$col) +
        scale_colour_manual(values=set$par$col) +
        xlim(c(0, 15)) + 
    theme(
        aspect.ratio=1,
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        legend.position="none",
        axis.title.y=element_blank(),
        panel.background=element_blank(),
        panel.border=element_blank(),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank(),
        plot.background=element_blank()
        ) +
    geom_text(
        data=set$fields,
        aes(
            x=4,y=(ymin+ymax)/2, angle = theta, 
            label=type, fontface="bold", lineheight = 0.3
            ), size = 4
        ) +
    geom_text(
        data=set$skills,
        aes(
            x=11, y=(ymin+ymax)/2, angle = theta, 
            label=skill, fontface="bold", lineheight = 0.3
            ), size = 2.8
        ) +
    coord_polar(theta="y")  

    return(set)
}

# Save Plots as PDF
savePdfs <- function(set) 
{
    name <- names(set$plot)
    for (plot in 1:length(set$plot))
    {
        pdf(paste0(set$par$o,name[plot],".pdf"))
        print(set$plot[plot])
        dev.off()
        return()
    }
}


