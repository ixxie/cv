
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