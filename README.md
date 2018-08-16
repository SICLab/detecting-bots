# detecting-bots
This is a function designed for Qualtrics surveys to detect responses that may be from bots and survey-farmers.
This function creates a vector that you can save as a new column in your dataset that assignes a "score" to each response. 
The score is intended to count the number of features in each response that are associated with bots and survey-farmers. 
Suggestions for new features to add to the function should be emailed to jprims2@uic.edu.

bot.detector(Data, Latitude, Longitude, Comments, Comments2, Comments3)

Files: 
  Function: 180816mTurkLowQualityResponseDetection.R
  Example: 180816mTurkLowQualityResponseDetection_Example.R
  Load function from GitHub: HowToLoadBotDetector.R
  
This function assigns a score to each response. The higher the score, the higher the probability that the respondant is a bot or survey-farmer. 
It is best to examine each response with a high score manually. This function cannot replace the human eye- it can only guide it. 

Function arguments: 
  1. Data - your dataset
  2. Latitude - A column with latitude coordinates for your respondant. 
  3. Longitude - A column with longitude coordinates for your respondant. 
  4. Comments - An optional free-response field. 
  5. Comments2 - A second, optional free-response field. 
  6. Comments3 - A third, optional free-response field. 

Scoring: 
  Scores can go as high as 7 if you have three free-resposne fields. 
  Having a latitude and longitude that appears in more than 1% of responses adds 1 point. (I recommend changing the percentage depending on the size of your dataset.)
  Comments consisting solely of phrases typically attributed to bots/duplicate responses/survey farmers adds 1 point. (Send new suggestions for phrases to jprims2@uic.edu.)
  Duplicate comments that other respondants have already made in response to the same question add 1 point. 
  
  Max score for only latitude and longitude: 1
  Max score for latitude, longitude, and one free-response: 3
  Max score for latitude, longitude, and two free-responses: 5
  Max score for latitude, longitude, and three free-responses: 7
