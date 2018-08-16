source_github <- function(u) {
  # load package
  require(RCurl)
  
  # read script lines from website
  script <- getURL(u, ssl.verifypeer = FALSE)
  
  # parase lines and evaluate in the global environment
  eval(parse(text = script))
}

source("https://raw.githubusercontent.com/SICLab/detecting-bots/master/180816mTurkLowQualityResponseDetection.R")
