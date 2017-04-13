## library("deepnet");
## library("EBImage");

## source("Utils.R");

source("Test.R");

convertPosition <- function(bbox, globalImage) {
    positionText <- "";
    tl <- bbox$TopLeft;
    br <- bbox$BottomRight;
    center <- (tl+br)/2
    print(center);
    width  <- dim(globalImage)[[1]];
    height <- dim(globalImage)[[2]];
    if (center[2]<(height/3)) {
        positionText <- p(positionText, "Top ");
    } else if (center[2]<(2*height/3)) {
        positionText <- p(positionText, "Center ");
    } else {
        positionText <- p(positionText, "Bottom ");
    }
    if (center[1]<(width/3)) {
        positionText <- p(positionText, "Left");
    } else if (center[1]<(2*width/3)) {
        positionText <- p(positionText, "Middle");
    } else {
        positionText <- p(positionText, "Right");
    }
    return(positionText);
}
## f = system.file("images", "sample.png", package="EBImage");
## img = readImage(f);
## convertPosition(list(TopLeft=c(10,10),BottomRight=c(20,20)),img)
### [1] "Top Left"
## convertPosition(list(TopLeft=c(10,10),BottomRight=c(758,512)),img)
### [1] "Center Middle"
## convertPosition(list(TopLeft=c(0,0),BottomRight=c(758/3,512/3)),img)
### [1] "Top Left"
## convertPosition(list(TopLeft=c(0,0),BottomRight=c(758/3,2*512/3)),img)
### [1] "Center Left"
## convertPosition(list(TopLeft=c(0,300),BottomRight=c(758/3,512)),img)
### [1] "Bottom Left"
## convertPosition(list(TopLeft=c(758*2/3-10,512-10),BottomRight=c(758*2/3,512)),img)
### [1] "Bottom Middle"
## convertPosition(list(TopLeft=c(758/3-10,512-10),BottomRight=c(758/3,512)),img)
### [1] "Bottom Left"
## convertPosition(list(TopLeft=c(758*2/3+100,512),BottomRight=c(758*2/3+120,512)),img)
### [1] "Bottom Right"

SIZE_STEP <- 5;


extractSubImage <- function(img, pos) {
    return(as.Image(img[pos$TopLeft[1]:pos$BottomRight[1], pos$TopLeft[2]:pos$BottomRight[2],]));
}
## f = system.file("images", "sample.png", package="EBImage");
## img = readImage(f);
## display(img);
## img2 <- extractSubImage(img,list(TopLeft=c(10,10),BottomRight=c(100,100)));
## display(img2);

load("../models/BlackAndRed/DeepNet5.rda.ASUSTaffOnRedTrainSet+1pcdropout");
MODEL     <- fitDN5;  # rm(fitDN5);
PRED_FUNC <- nn.predict;

findNumbers <- function(img) {
    width  <- dim(img)[[1]];
    height <- dim(img)[[2]];
    ratio  <- height/width;  # use TRAIN_HEIGHT/TRAIN_WIDTH

    positions <- list();

    ## For all sizes
    for(sampleW in seq(SIZE_STEP, width, SIZE_STEP)) {
        sampleH <- ratio*sampleW;
        ## For all possible positions w/r to current sample size
        for(xPos in seq(0, width-sampleW, SIZE_STEP)) {
            for(yPos in seq(0, height-sampleH, SIZE_STEP)) {
                bbox <- list(TopLeft=c(xPos,yPos), BottomRight=c(xPos+sampleW,yPos+sampleH));
                toTest <- extractSubImage(img, bbox);
                val <- predictImage(toTest, MODEL, PRED_FUNC);
                if (val!=CLASSES[length(CLASSES)]) {
                    center <- c(xPos+sampleW/2,yPos+sampleH/2);
                    print(p("Number ", val, " found at (",center[1],center[2],"): ", convertPosition(bbox,img)));
                    positions <- c(positions, bbox);
                }
            }
        }
    }
}

# todo write a method that draws the bbox-es on top of the image

main <- function() {
    multipleDigits <- readImage("../images/originals/ec9f9e3929808508a30bee101cb99572.jpg");
    findNumbers(multipleDigits);
}
