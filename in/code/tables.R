library(ggplot2)
library(ggrepel)
library(magrittr)
library(plyr)
library(showtext)


showtext.auto()

font.add.google("Alegreya", "aleg")
font.add.google("Alegreya SC", "alegsc")

# Makes an empty set
makeSet <- function(par=list())
{
    set <- list("par"=par, "tab"=list(), "plot"=list())
    return(set)
}

# Loads the data set from a csv file:
loadTables <- function(set)
{
    tables <- normalizePath(paste0("./in/tables/",list.files("./in/tables")))
    # Load skills.csv into dataframe
    for (table in tables)
    {
        tabname <- stripPath(table)   
        set$tab[[tabname]] <- read.csv(table)
        set$tab[[tabname]] <- data.frame(set$tab[[tabname]], stringsAsFactors=TRUE)
    }

    return(set)
}



# Filters out the maximum skill levels in case of duplicates:
filterMax <- function(table, ifactor, ffactor)
{
    ntable <- data.frame()
    for (fac in levels(table[[ifactor]]))
    {
        # Load subframe that has skill s
        subtbl <- table[table[[ifactor]]==fac, ]
        # Extract the row with maximum skill level
        ntable <- rbind(ntable,subtbl[subtbl[[ffactor]]==max(subtbl[[ffactor]]),])
    }
    
    return(ntable)
}

filterDups <- function(table)
{
    table <- table[!duplicated(table),]
    return(table)
}

seqTable <- function(table, factor)
{

    index <- function(row)
    {
        freqtab <- count(table, factor)
        row$num <- freqtab[row[[factor]], "freq"]
        return(row)
    }

    table <- adply(table, 1, index)
    
    table <- table[with(table, order(-num, table[[factor]],-level)), ]
    row.names(table) <- 1:nrow(table)

    table$ymin <- as.numeric(row.names(table)) - 1
    table$ymax <- as.numeric(row.names(table))


    return(table)
}


facTable <- function(table, factor)
{
    table <- count(table, factor)
    return(table)
}

sliceTable <- function(table, factor)
{
    ntable <- count(table, factor)
    ntable <- ntable[with(ntable, order(-freq)), ]
    row.names(ntable) <- 1:nrow(ntable)
    for (type in levels(table[[factor]]) )
    {
        tab <- table[table[[factor]]==type,]
        ntable[ntable[[factor]]==type,"ymin"] <- min(as.numeric(tab$ymin))
        ntable[ntable[[factor]]==type,"ymax"] <- max(as.numeric(tab$ymax))
        ntable[ntable[[factor]]==type,"col"] <- tab$col[1]        
        ntable[ntable[[factor]]==type,"alp"] <- tab$alp[1]

    }
    return(ntable)
}

# Strips path to file name without extension:
stripPath <- function(path)
{
    sub(pattern = "(.*)\\..*$", replacement = "\\1", basename(path))
}

stripNames <- function(vector)
{
    names(vector) <- NULL
    return(vector)
}

# Infers the color set 
mapAes <- function(table, factor, aes, aesname)
{
    subtable <- as.factor(table[,factor])
    # Construct aesthetic mapping for the factor:
    table[,aesname] <- aes[match(subtable, levels(subtable))]

    return(table)
}

# Computes a central slice angle from linear slice coordinates:
makeTheta <- function(table)
{
    dif <- max(table$ymax)-min(table$ymin)
    # Compute slice width
    table$dif <- 360*(table$ymax - table$ymin)/dif
    # Compute slice position 
    table$pos <- -(cumsum(table$dif) - 0.5*table$dif)
    # Compute slice center
    table$theta <- table$pos + ((table$pos)%/%180+1)*180  + 90

    return(table)
}


fluxBars <- function(table, ifactor, xfactor, yfactor, afactor, col)
{

    ifacs <- levels(table[[ifactor]])

    tempdf <- do.call("ddply", list(table, c(ifactor,xfactor), transform, maxy=call("sum",as.symbol(yfactor)) ) )

    maxy <- max(tempdf[["maxy"]])


    plots <- list()

    for (i in ifacs)
    {

        tab <- subset(table, table[[ifactor]]==i)
        plots[[i]] <- 
            ggplot(tab, 
                aes_string(x=xfactor,y=yfactor, fill=xfactor, alpha=afactor)) +
                geom_bar(stat="identity") + 
            scale_fill_manual(values=col) +
            scale_colour_manual(values=col) +
                    scale_x_discrete(drop=FALSE) + 
                    scale_y_continuous(limits=c(0,maxy+1)) + 
                theme(
                    aspect.ratio=0.5,
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
                    )
    }

    return(plots)
}

# Build ggplot object for a Skillpie:
nestPie <- function(table, ifactor, ofactor, afactor, lab, col, alp, ialp=90)
{

    inner <- makeTheta(sliceTable(table, ifactor))
    inner$alp <- ialp
    col <- stripNames(col)

    plot <- 
        ggplot() + 
            geom_rect(
                data=table,
                aes_string(
                    fill=ifactor, colour=ifactor, alpha=afactor, 
                    ymax="ymax", ymin="ymin", 
                    xmax=22, xmin=9
                    )
                ) +
            geom_rect(
                data=inner,
                aes_string(
                    fill=ifactor, colour=ifactor, alpha=afactor, 
                    ymax="ymax", ymin="ymin", 
                    xmax=9, xmin=0
                    )
                ) + 
            scale_fill_manual(values=stripNames(col)) +
            scale_colour_manual(values=stripNames(col)) +
            xlim(c(0, 25)) +
        coord_polar(theta="y")  +
    scale_y_continuous(aes(x=24, vjust=0, hjust=0),
        breaks=(inner[["ymin"]]+inner[["ymax"]])/2,   # where to place the labels
        labels=lab[as.character(inner[[ifactor]]) ]  # the labels
    ) +
        theme(
            aspect.ratio=1,
            axis.line=element_blank(),
            axis.text.x=element_text(aes(fontface="bold"), color='black', size = 9.5, family="alegsc"),
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank(),
            axis.ticks.x=element_blank(),
            axis.title.x=element_blank(),
            legend.position="none",
            axis.title.y=element_blank(),
            panel.background=element_blank(),
            panel.border=element_blank(),
            panel.grid.major=element_blank(),
            panel.grid.minor=element_blank(),
            plot.background=element_blank(),
            ) +
        geom_text(
            data=table,
            aes(
                x=15.5, y=(ymin+ymax)/2, angle = theta, 
                label=table[[ofactor]],  lineheight = 0.3
                ), size = 3.5, family="aleg"
            ) +
        geom_text(
            data=inner,
            aes(
                x=5,y=(ymin+ymax)/2, angle = theta, 
                label=inner[[ifactor]], fontface="bold", lineheight = 0.3
                ),  size = 3.5, family="aleg"
            ) #+
        #geom_text(
         #   data=inner,
          #  aes(
           #     x=18,y=(ymin+ymax)/2, 
            #    label=lab[as.character(inner[[ifactor]]) ], lineheight = 0.3
             #   ),  vjust="outwards",hjust="outwards", size = 3.5, family="rock"
           # ) 



    return(plot)
}


printVar <- function(var)
{
    coord <- strsplit(deparse(substitute(var)),"$")
    varName <- coord[length(coord)]
    return(varName)
}

savePdf <- function(plot, path="./out/plot/") UseMethod("savePdf")

# Save Plots as PDF
savePdf.ggplot <- function(plot, path="./out/plots/") 
{
    pdf(paste0(path, ".pdf"))
    print(plot)
    dev.off()
    return(plot)
}


savePdf.list <- function(plot, path="./out/plots/") 
{
    for (el in names(plot))
    {
        savePdf(plot[[el]], paste0(path,el))
    }
}


