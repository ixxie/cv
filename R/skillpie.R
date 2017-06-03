library(ggplot2)

# Main function for creating the holoplot:
makeHolo <- function(pars)
{

    savePdf(
        makeHoloplot(
            sliceSet(
                makeColors(
                    countSkills(
                        filterMax(
                            loadSet(pars)
                        )
                    )
                )
            )
        )
    )

}

# Loads the data set from a csv file:
loadSet <- function(pars)
{
    # Load skills.csv into dataframe
    skills <- read.csv(pars$path)
    skills$type <- as.factor(skills$type)

    # Construct the Specialization Table
    types <- levels(skills$type)
    specs <- data.frame(type=types)

    set <- list("pars"=pars, "skills"=skills, "specs"=specs, "types"=types)
    
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

# Counts type frequencies and orders tables by it:
countSkills <- function(set)
{
    # Initialize fields to count the number of skills per type:
    set$skills$num <- numeric(nrow(set$skills))
    set$specs$num <- numeric(length(set$types))

    # Cycle through skill type and count the number of skills of that type:
    for (t in set$types)
    {
        set$specs[set$specs$type==t,]$num <- 
            set$skills[set$skills$type==t,]$num <- 
                nrow(set$skills[set$skills$type==t,])
    }

    # Reorder the skills & specs tables by decending type class size and decending level:
    set$skills <- set$skills[with(set$skills,order(-num, type, -level)),]
    row.names(set$skills) <- 1:nrow(set$skills)
    set$specs <- set$specs[with(set$specs,order(-num)),]

    return(set)
}

# Infers the color set 
makeColors <- function(set)
{
    # Construct colors and alpha levels from skill type and level:
    set$specs$col <- set$pars$col[match(set$specs$type, set$types)]
    set$skills$col <- set$pars$col[match(set$skills$type, set$types)]
    set$skills$alp <- set$pars$alp[set$skills$level]

    # But set the specialization alpha to base alpha.
    set$specs$alp <- set$pars$basealp

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
    specs <- set$specs

    # Construct Y-Coord. Spans from the table order and calculate total height:
    skills$ymin <- as.numeric(1:nrow(skills))
    skills$ymax <- skills$ymin + 1.
    skills$ydif <- max(skills$ymax) - min(skills$ymin)

    # Derive corresponsing Y-Coord. for specs:
    for (t in specs$type)
    {
        fr <- skills[skills$type == t,]
        specs[specs$type==t,"ymin"] <- min(fr$ymin)
        specs[specs$type==t,"ymax"] <- max(fr$ymax)    
    }
    specs$ydif <- max(specs$ymax) - min(specs$ymin)

    # Calculate the angular coordinate of slices and output to set:
    set$skills <- makeTheta(skills)
    set$specs <- makeTheta(specs)
    return(set)

}



# Build ggplot object for Holoplot:
makeHoloplot <- function(set)
{
set$holoplot <- 
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
            data=set$specs,
            aes(
                fill=col, colour=col, alpha=alp, 
                ymax=ymax, ymin=ymin,
                xmax=7, xmin=0
                )
            ) + 
        scale_fill_manual(values=set$pars$col) +
        scale_colour_manual(values=set$pars$col) +
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
        data=set$specs,
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

# Save Holograph as PDF
savePdf <- function(set) 
{
        pdf(set$pars$out)
        print(set$holoplot)
        dev.off()
        return()
}


