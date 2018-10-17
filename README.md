# bot.detector() Version 1.3
This is a function designed for Qualtrics surveys to detect responses that may be from bots and survey-farmers.
This function creates a vector that you can save as a new column in your dataset that assigns a "score" to each response. 
The score is intended to count the number of features in each response that are associated with bots and survey-farmers. 
We recommend that you examine responses with high scores manually before excluding them. This function cannot replace the human eye- it can only guide it. 
Suggestions for new features to add to the function should be emailed to jprims2@uic.edu

Suggested Citation: 
Prims, J., Motyl, M. (2018). A tool for detecting low quality data in internet research. GitHub: https://github.com/SICLab/detecting-bots

Files: 
 - Function: 180816mTurkLowQualityResponseDetection.R
 - Example: 180816mTurkLowQualityResponseDetection_Example.R
 - Load function from GitHub: HowToLoadBotDetector.R
 
This function assigns a score to each response. The higher the score, the more features associated with bots or survey-farmers. 
It is best to examine each response with a high score manually. This function cannot replace the human eye- it can only guide it. 

bot.detector(Latitude, Longitude, Threshold, Time, Comments, Comments2, Comments3)

Function arguments: 
  1. Latitude - A column with latitude coordinates for your respondant. 
  2. Longitude - A column with longitude coordinates for your respondant. 
  3. Threshold -  If a single latitude/longitude pair exceeds this proportion of the sample, it is considered suspicious. (Default is .01.)
  4. Time - An optional column with Qualtrics-formatted date and time stamps. (MM/DD/YYYY HH:MM)
  5. Comments - An optional free-response field. 
  6. Comments2 - A second, optional free-response field. 
  7. Comments3 - A third, optional free-response field. 

Scoring: 
  Scores can go as high as 8 if you have three free-response fields. 
  - Having a latitude and longitude that appears in more than the specified threshold adds 1 point. (Default threshold is .01.)
  - Having a duplicate latitude and longitude, AND responding within 10 minutes of the other responses from the same latitude and longitude adds 1 point. (I recommend using the StartedDate column, but any column in Qualtrics date-time format [MM/DD/YYYY HH:MM)] will do.)
  - Comments consisting solely of phrases typically attributed to bots/duplicate responses/survey farmers adds 1 point. (Send new suggestions for phrases to jprims2@uic.edu.)
  - Duplicate comments that other respondants have already made in response to the same question add 1 point. 
  - Comments containing the word "very" add 1 point.  (See https://www.maxhuibai.com/blog/a-proposed-procedure-for-testing-the-evidentiary-value-of-responses-from-duplicated-gps-sources-comments-invited)
  
  - Max score for only latitude and longitude: 1
  - Max score for latitude, longitude, and time: 2
  - Max score for latitude, longitude, and one free-response: 3
  - Max score for latitude, longitude, time, and one free-response: 4
  - Max score for latitude, longitude, and two free-responses: 5
  - Max score for latitude, longitude, time, and two free-responses: 6
  - Max score for latitude, longitude, and three free-responses: 7
  - Max score for latitude, longitude, time, and three free-responses: 8
  
Upcoming changes: 
 Adding a built-in list of suspicous locations using the method described in this post: https://www.facebook.com/groups/psychmap/permalink/670236310019961/ (Suggested by @NivReggev)
