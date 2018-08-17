####################################
#### Testing mTurk Bot Function ####
####################################

# This is an example of how to use this function. This function is designed to identify low-quality mTurk responses. 
# This function assigns a score to each response. The higher the score, the higher the probability that the respondant is a bot or survey-farmer. 
# It is best to examine each response with a high score manually. This function cannot replace the human eye- it can only guide it. 

# Function arguments: 
  # Latitude - A column with latitude coordinates for your respondant. 
  # Longitude - A column with longitude coordinates for your respondant. 
  # Threshold - If a single latitude/longitude pair exceeds this proportion of the sample, it is suspicious. (Default is .01.)
  # Comments - An optional free-response field. 
  # Comments2 - A second, optional free-response field. 
  # Comments3 - A third, optional free-response field. 

# Scoring: 
  # Scores can go as high as 7 if you have three free-resposne fields. 
  # Having a latitude and longitude that appears in more than the specified threshold adds 1 point. (Default threshold is .01.)
  # Comments consisting solely of phrases typically attributed to bots/duplicate responses/survey farmers adds 1 point. (Send new suggestions for phrases to jprims2@uic.edu.)
  # Duplicate comments that other respondants have already made in response to the same question add 1 point. 
  # Comments containing the word "very" add 1 point.
    # Max score for only latitude and longitude: 1
    # Max score for latitude, longitude, and one free-response: 3
    # Max score for latitude, longitude, and two free-responses: 5
    # Max score for latitude, longitude, and three free-responses: 7

# Creating a dataset with suspected bots. 
  LocationLatitude <- c(1:100, 10, 10)
  LocationLongitude <- c(-1:-100, 10, 10)
  comments <- c(rep("blep",90),"good","NICE!", "yeet","yeet","Yeet","good","blah","boop","cheese","jumprope","good","NICE!")
  comments2 <- c(rep("boom", 90), "hey","NICE!","zoop","yeet","loop","good","very good","doggo","jumprope","nominal","good","NICE!")
  dat <- data.frame(LocationLatitude, LocationLongitude, comments, comments2)
  
  # Previewing dataset
  head(dat)

# Loading in the function
  
  bot.detector <- function(Latitude, Longitude,  Threshold = .01, Comments, Comments2, Comments3){

    # This creates a new column to store our bot suspicion score. 
    bot.susp <- rep(NA, length(Latitude))
    
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
      suswords <- c("good","NICE!", "very")
    
    # Check if person specified a free-response. If so, run. 
        if(missing(Comments)) {
          NULL
        } else {
          
          # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
          # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
          bot.susp <- ifelse(Comments %in% suswords, bot.susp + 1, bot.susp)
          
          # Now, check if any free responses are 100% matches to other free responses. 
          bot.susp <- ifelse(duplicated(Comments), ifelse(is.na(Comments), bot.susp, bot.susp +1), bot.susp)
          
          # Now, looking for the presence of the word "very." 
          bot.susp <- ifelse(grepl("very", Comments), bot.susp + 1, bot.susp)
          
        }
    
    # Check if person specified second free-response. If so, run. 
        if(missing(Comments2)) {
          NULL
        } else {
          
          # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
          # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
          bot.susp <- ifelse(Comments2 %in% suswords, bot.susp + 1, bot.susp)
          
          # Now, check if any free responses are 100% matches to other free responses. 
          bot.susp <- ifelse(duplicated(Comments2), ifelse(is.na(Comments2), bot.susp, bot.susp +1), bot.susp)
          
          # Now, looking for the presence of the word "very." 
          bot.susp <- ifelse(grepl("very", Comments2), bot.susp + 1, bot.susp)
          
        }
        
    # Check if person specified third free-response. If so, run. 
        if(missing(Comments3)) {
          NULL
        } else {
          
          # Adds 1 to the bot suspicion column if suspicous phrases appear in the responses.
          # Putting the arguments in this order makes sure it won't flag comments that contain the word "good," but also have other content.
          bot.susp <- ifelse(Comments3 %in% suswords, bot.susp + 1, bot.susp)
          
          # Now, check if any free responses are 100% matches to other free responses. 
          bot.susp <- ifelse(duplicated(Comments3), ifelse(is.na(Comments3), bot.susp, bot.susp +1), bot.susp)

          # Now, looking for the presence of the word "very." 
          bot.susp <- ifelse(grepl("very", Comments3), bot.susp + 1, bot.susp)
        }
        
        # Outputting results
        return(bot.susp)
        
      }
  
  
# Testing the function
  dat$bot.susp <- bot.detector(dat$LocationLatitude, LocationLongitude, Threshold = .01, dat$comments, dat$comments2)
  