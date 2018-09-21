####################################
#### Testing mTurk Bot Function ####
####################################

# This is an example of how to use this function. This function is designed to identify low-quality mTurk responses. 
# This function assigns a score to each response. The higher the score, the higher the probability that the respondant is a bot or survey-farmer. 
# It is best to examine each response with a high score manually. This function cannot replace the human eye- it can only guide it. 

# Function arguments: 
  # Data - your dataset
  # Latitude - A column with latitude coordinates for your respondant. 
  # Longitude - A column with longitude coordinates for your respondant. 
  # Time - An optional column with Qualtrics-formatted date and time stamps. 
  # Comments - An optional free-response field. 
  # Comments2 - A second, optional free-response field. 
  # Comments3 - A third, optional free-response field. 

# Scoring: 
  # Scores can go as high as 7 if you have three free-resposne fields. 
  # Having a latitude and longitude that appears in more than 1% of responses adds 1 point. (I recommend changing the percentage depending on the size of your dataset.)
  # Having a duplicate latitude and longitude, AND responding within 10 minutes of the other responses from the same latitude and longitude adds 1 point. (I recommend StartedDate.)
  # Comments consisting solely of phrases typically attributed to bots/duplicate responses/survey farmers adds 1 point. (Send new suggestions for phrases to jprims2@uic.edu.)
  # Duplicate comments that other respondants have already made in response to the same question add 1 point. 
  # Max score for only latitude and longitude: 1
  # Max score for latitude, longitude, and time: 2
  # Max score for latitude, longitude, and one free-response: 3
  # Max score for latitude, longitude, time, and one free-response: 4
  # Max score for latitude, longitude, and two free-responses: 5
  # Max score for latitude, longitude, time, and two free-responses: 6
  # Max score for latitude, longitude, and three free-responses: 7
  # Max score for latitude, longitude, time, and three free-responses: 8

# Creating a dataset with suspected bots. 
  LocationLatitude <-  c(1:100, 9, 9, 10, 10)
  LocationLongitude <-  c(-1:-100, 9, 9, 10, 10)
  time <- c(seq(c(ISOdate(2018,8,17)), by = "10 min", length.out = 100), seq(c(ISOdate(2018,8,17)), by = "1 min", length.out = 4))
  comments <- c(rep("blep",92),"good","NICE!", "yeet","yeet","Yeet","good","blah","boop","cheese","jumprope","good","NICE!")
  comments2 <- c(rep("boom", 92), "hey","NICE!","zoop","yeet","loop","good","heck","doggo","jumprope","nominal","good","NICE!")
  dat <- data.frame(LocationLatitude, LocationLongitude, time, comments, comments2)
  
  # Previewing dataset
  head(dat)

# Loading in the function
  
  bot.detector <- function(Latitude, Longitude, Time,  Threshold = .01, Comments, Comments2, Comments3){
    
    # This loads in required packages. (Mostly for the Time argument.)
    require(tidyr)
    require(dplyr)
    require(zoo)
    
    
    # This creates a new column to store our bot suspicion score. 
    bot.susp <- rep(0, length(Latitude))
    
    # First, let's work on detecting if there are some coordinates that appear in more than 1% of the a. 
    # With Qualtrics, the columns we want to look at are Latitude and Longitude. 
    
    # Creating an object combining those two into one column 
    latlong <- paste(Latitude,Longitude)
    
    # This counts the number of times each coordinate appears in the aset. 
    llcount <- summary(as.factor(latlong))
    
    # This determines if a certain latitude and longitude appears in more than 1% of responses.
    lllots <- llcount > length(Latitude) * Threshold # You can change the .01 to change the % of the sample. 
    
    # Pulls out the coordinates that make up more than 1% of the sample.   
    llmany <- names(lllots[lllots == TRUE]) 
    
    # Adds a 1 to the bot suspicion column if the coordinates appear in more than 1% of the sample
    bot.susp <- ifelse(latlong %in% llmany, 1,  0)
    
    # Now, let's check if their free response contains "good" or "NICE!"
    suswords <- c("good","NICE!")
    
    # Transform vector of phrases to lowercase
    suswords <- tolower(suswords) # See https://www.maxhuibai.com/blog/evidence-that-responses-from-repeating-gps-are-random for illustration
    
    
    # Check if person specified a column of times. If so, run.
    if(missing(Time)) {
      NULL
    } else {
      # First, converting time to a format R can use. Using the typical Qualtrics organization.
      Time <- as.POSIXct(Time, tz = "", format = "%m/%d/%Y %H:%M", optional = FALSE)
      Time <- as.numeric(Time)
      
      # I'd like to make a dataframe so I can filter things.
      tempdat <- data.frame(latlong, Time)
      # Now, adding an ID
      tempdat$id <- 1:(nrow(tempdat))
      
      # This filters it so the dataframe only keeps rows with suspicious coordinates, and moves it to long format.
      tempdatw <- spread(subset(tempdat, tempdat$latlong %in% llmany), latlong, Time)
      
      # Fill in NAs with 0s
      tempdatw[is.na(tempdatw)] <- 0
      
      # Check if time difference between a duplicate and the previous duplicate response is between 1 and 600 seconds (10 minutes)
      # Code for 1 duplicate and more duplicates
      ifelse(ncol(tempdatw) == 2,
             # If one repeating coordinate
             ifelse(abs(tempdatw[,2] - lag(tempdatw[,2], n = 1L)) < 600 & abs(tempdatw[,2] - lag(tempdatw[,2], n = 1L)) > 1, TRUE, FALSE),
             # If multiple coordinates
             tempdatw[,-1] <- lapply(tempdatw[,-1], function(x) ifelse(abs(x - lag(x, n = 1L)) < 600 & abs(x - lag(x, n = 1L)) > 1, TRUE, FALSE))
      )
      
      # I think I need to sum the two columns into one. 
      ifelse(ncol(tempdatw) == 2, 
             tempdatw$sum <- tempdatw[,2],
             tempdatw$sum <- rowSums(tempdatw[,-1]))
      
      # Putting it back in long format, so I can merge it back in with our temporary data frame
      # TEMPDAT L IS LISTING SOME IDS TWICE 
      tempdatl <- tempdatw[,c("id","sum")]
      
      # Merge back in to tempdat
      
      findat <- merge(tempdat, tempdatl[,c("id","sum")], by = "id", all.x = TRUE)
      
      findat$sum <- ifelse(is.na(findat$sum), 0, findat$sum)
      
      
      # Now, let's add that suspicion!
      
      bot.susp <- ifelse(findat$sum >= 1, bot.susp + 1, bot.susp) # For some reason, it's not adding. 
    }
    
    
    # Check if person specified a free-response. If so, run. 
    if(missing(Comments)) {
      NULL
    } else {
      
      # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
      
      # Transform comment vectors to lowercase
      Comments <- tolower(Comments)
      
      # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
      bot.susp <- ifelse(Comments %in% suswords, bot.susp + 1, bot.susp)
      
      # Now, check if any free responses are 100% matches to other free responses. 
      bot.susp <- ifelse(duplicated(Comments, incomparables=c('',NA)), bot.susp + 1, bot.susp)
    }
    
    # Check if person specified second free-response. If so, run. 
    if(missing(Comments2)) {
      NULL
    } else {
      # Transform comment vectors to lowercase
      Comments2 <- tolower(Comments2)
      
      # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
      # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
      bot.susp <- ifelse(Comments2 %in% suswords, bot.susp + 1, bot.susp)
      
      # Now, check if any free responses are 100% matches to other free responses. 
      bot.susp <- ifelse(duplicated(Comments2), bot.susp + 1, bot.susp)
    }
    
    # Check if person specified third free-response. If so, run. 
    if(missing(Comments3)) {
      NULL
    } else {
      
      # Transform comment vectors to lowercase
      Comments3 <- tolower(Comments3)
      
      # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
      # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
      bot.susp <- ifelse(Comments3 %in% suswords, bot.susp + 1, bot.susp)
      
      # Now, check if any free responses are 100% matches to other free responses. 
      bot.susp <- ifelse(duplicated(Comments3), bot.susp + 1, bot.susp)
    }
    
    # Outputting results
    return(bot.susp)
    
  }
  


# Testing the function
  
 dat$bot.susp <- bot.detector(dat$LocationLatitude, dat$LocationLongitude, Threshold = .01, Time = dat$time, Comments = dat$comments, Comments2 = dat$comments2)
  
 summary(dat$bot.susp)
 