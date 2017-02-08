source("preprocess.R")
source("detectPosition.R")

rawFile<-list()
raw <- list()
rawRed <- list()
rawRChan <- list()
rawD <- list()
procFile <- list()


for (digit in c(1:10,"E","H")) {
    digitn <- p(as.numeric(digit)-1);
    if (digitn=="NA") { digitn=p(digit); }
    rawFile[[digit]] <- paste(c("../images/numbers/",digitn,".png"),collapse="")
    #print(rawFile[[digit]])
    raw[[digit]] <- readImage(rawFile[[digit]])
    #display(raw)
    rawRed[[digit]] <- pickColor(raw[[digit]], c(1.0,0.0,0.0), c(0.2,0.1,0.1))
    rawRChan[[digit]] <- channel(rawRed[[digit]], "red")>.9
    rawD[[digit]] <- getDigit(rawRChan[[digit]])
    #display(zeroD)
    procFile[[digit]] <- paste(c("../images/preprocessed/",digitn,".png"),collapse="")
    #print(procFile[[digit]])
    ## writeImage(rawD[[digit]], procFile[[digit]])
}
