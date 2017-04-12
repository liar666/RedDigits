library("deepnet");
library("EBImage");

source("Utils.R");

## source("../code/pick.R");
## img<-readImage("../images/numbers_orig/5.png");
## display(img);
## img<-pickColor(img,c(1.0,0.0,0.0),c(.2,.2,.3));
## img2<-channel(img,"red");
## display(img2);
## img2<-img2>.5;
## img2 <- sharpenImage(img2,.3);
## display(img2);
## img3<-resize(img2, 10, 14);
## display(img3)
## flatImg <- c(img3, recursive=T);
## flatDF <- as.data.frame(t(flatImg));
## names(flatDF) <- colnames(test[,dataCols])
## preds <- nn.predict(fitDN3, flatDF);
## names(test)[140+max.col(preds)];


## source("../code/pick.R");

## FOREGROUND <- c(1.0,0.0,0.0);
## FOREGROUND_MARGINS <- c(0.3,0.2,0.2);
## FOREGROUND_THRESHOLD <- .85;


## ### Erodes the borders
## sharpenImage <- function(image, force) {
##     kern <- makeBrush(force, shape='disc'); # force was 5 in docs
##     return(erode(image, kern));
## }

## preprocess <- function(img) {
##     img <- sharpenImage(img, 2);
##     if(colorMode(img)==2) {
##         redImg  <- pickColor(img, FOREGROUND, FOREGROUND_MARGINS);
##         redChan <- channel(redImg,"red") > FOREGROUND_THRESHOLD;
##         return(redChan);
##     }
##     return(img);
## }
fiveName   <- "../images/numbers_cleaned/5.png";
otherName  <- "../images/non_numbers/cartoon5.png";
other2Name <- "/usr/share/app-install/icons/xaos.png";
five  <- readImage(fiveName);
other <- readImage(otherName);
other2<- readImage(other2Name);
## ## Sharpen first, then preprocess (DEACTIVATE sharpening inside preprocess)
## five2 <- sharpenImage(five, 3);
## five2 <- preprocess(five2);
## display(five2);
## ## Preprocess then sharpen (DEACTIVATE sharpening inside preprocess)
## five3 <- preprocess(five);
## five4 <- sharpenImage(five3, 3);
## display(five4);

predictImageDistr <- function(img, model, predFunc) {
    #img2 <- preprocess(img); ## sharp+reduce colors+seuil=>crisp BW...
    img2 <- removeAlphaChannel(img);
    scaledImg <- resize(img2, w=TRAIN_WIDTH, h=TRAIN_HEIGHT); ## auto keep-ratio? / filter="none"/"bilinear"?
    flatImg <- c(scaledImg, recursive=T);
    names(flatImg) <- COL_IMG_NAMES;
    preds <- predFunc(model, t(as.data.frame(flatImg))); ### flatImg[dataCols]
    return(preds);
}
predictImage <- function(img, model, predFunc) {
    return(classesProbabilitesToClassNumber(predictImageDistr(img,model,predFunc)));
}

predictFileDistr <- function(filename, model, predFunc) {
    origImg <- readImage(filename);
    return(predictImageDistr(origImg, model, predFunc));
}
predictFile <- function(filename, model, predFunc) {
    return(classesProbabilitesToClassNumber(predictFileDistr(filename,model,predFunc)));
}


main <- function() {
    load(p(OUTDIR_MODELS,"DeepNet5.rda.ASUSTaffOnRedTrainSet+1pcdropout"))
    fitDN <- fitDN5;
    print(predictImage(five, fitDN, nn.predict));
    print(predictImage(other, fitDN, nn.predict));
    print(predictImage(other2, fitDN, nn.predict));
    print(predictFile(fiveName, fitDN, nn.predict));
    print(predictFile(otherName, fitDN, nn.predict));
    print(predictFile(other2Name, fitDN, nn.predict));
}
