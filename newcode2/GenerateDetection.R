source("Utils.R");

library("EBImage");

RATIO  <- 1280/1024;
HEIGHT <- 200;
WIDTH  <- HEIGHT*RATIO;

MAX_DIGITS_BY_EXAMPLE <- 6;

NB_CLASSES <- length(CLASSES)-1

IMAGES <- list()
for (cl in CLASSES[1:NB_CLASSES]) {
    IMAGES[[cl]] <- readImage(p(INDIR_IMAGES_NUM, cl, ".png"))[,,1:3];
}

BACKGROUND <- Image(rep(WIDTH*HEIGHT*3,0),dim=c(WIDTH,HEIGHT,3), colormode='Color');
DIGIT_MASK <- Image(rep(0, times=TRAIN_WIDTH*TRAIN_HEIGHT*3),dim=c(TRAIN_WIDTH,TRAIN_HEIGHT,3), colormode='Color');
DIGIT_MASK[,,1] <- 1;

rand <- function(min, max, step) {
    return(min+round(runif(1)*((max-min)/step))*step);
}

## Replace part of imageDest starting at topLeft position with content of imageSrc
putImage <- function(imageSrc, imageDest, topLeft) {
    stopifnot(dim(imageSrc)[3]==3 && dim(imageDest)[3]==3);
    stopifnot(topLeft[1]>0 && topLeft[2]>0);

    dimSrc  <- dim(imageSrc);
    dimDest <- dim(imageDest);
    ## print(p("SRC: ", dimSrc));
    ## print(p("DST: ", dimDest));
    stopifnot(all(dimSrc[1:2]<dimDest[1:2]));

    Xd <- c(topLeft[1], min(dimDest[1],(topLeft[1]+dimSrc[1]-1)));
    Yd <- c(topLeft[2], min(dimDest[2],(topLeft[2]+dimSrc[2]-1)));
    ## print(p("Xd:", Xd[1],"->", Xd[2]));
    ## print(p("Yd:", Yd[1],"->", Yd[2]));

    Xs <- c(1, min(dimSrc[1],dimDest[1]-topLeft[1]+1));
    Ys <- c(1, min(dimSrc[2],dimDest[2]-topLeft[2]+1));
    ## print(p("Xs:", Xs[1], "->", Xs[2]));
    ## print(p("Ys:", Ys[1], "->", Ys[2]));

    imageDest[Xd[1]:Xd[2] , Yd[1]:Yd[2] , ] <-
        imageSrc[Xs[1]:Xs[2] , Ys[1]:Ys[2] , ];
    return(imageDest);
}
## Error
## im <- putImage(IMAGES[[4]], BACKGROUND, c(0,0))
### TopLeft corner
## im <- putImage(IMAGES[[4]], BACKGROUND, c(1,1))
## im <- putImage(IMAGES[[4]], BACKGROUND, c(1,10))
## im <- putImage(IMAGES[[4]], BACKGROUND, c(10,1))
### Middle
## im <- putImage(IMAGES[[4]], BACKGROUND, c(250,250))
### BottomRight corner
## im <- putImage(IMAGES[[4]], BACKGROUND, c(625-30,500-70))
## im <- putImage(IMAGES[[4]], BACKGROUND, c(625-40,300))
## im <- putImage(IMAGES[[4]], BACKGROUND, c(1,500-70))

generatePictures <- function(nbExamples) {
    for (currEx in 1:nbExamples) {
        expl  <- BACKGROUND;
        mask  <- BACKGROUND;
        mask2 <- BACKGROUND;
        for (digits in 1:runif(1,1,MAX_DIGITS_BY_EXAMPLE)) {
            ## Choose the digit
            digit <- IMAGES[[CLASSES[runif(1,1,NB_CLASSES)]]];
            ## Choose the position of the digit
            x <- round(runif(1,TRAIN_WIDTH/2,WIDTH-(TRAIN_WIDTH/2)));
            y <- round(runif(1,TRAIN_HEIGHT/2,HEIGHT-(TRAIN_HEIGHT/2)));

            ## Choose the operations on the digit
            tilt <- rand(-.4, .4, .2); mconvol <- matrix(c(1,tilt,-tilt*TRAIN_WIDTH,0,1,0), ncol=2);
            angle <- rand(-30, 30, 15);
            sigma <- rand(0.1,2.1,.5);
            ratio <- rand(.6, 1.0, .1);

            ## Apply operations on digit
            tiltedD   <- affine(x=digit, m=mconvol);
            rotatedD  <- rotate(tiltedD, angle);
            bluredD   <- gblur(rotatedD, sigma);
            resizedD  <- resize(bluredD, w=ratio*TRAIN_WIDTH);

            ## Apply operations on mask
            tiltedM   <- affine(x=DIGIT_MASK, m=mconvol);
            rotatedM  <- rotate(tiltedM, angle);
            resizedM  <- resize(rotatedM, w=ratio*TRAIN_WIDTH);

            ## Apply only resize on mask2
            resizedM2 <- resize(DIGIT_MASK, w=ratio*TRAIN_WIDTH*1.1);

            ## Place resizedD in expl & resizedM in mask
            expl  <- putImage(resizedD, expl, c(x,y));
            mask  <- putImage(resizedM, mask, c(x,y));
            mask2 <- putImage(resizedM2, mask2, c(x,y));
        }
        ## Save image+mask
        writeImage(expl, p("example_",currEx,".png"));
        writeImage(mask, p("mask_",currEx,".png"));
        writeImage(mask2, p("mask2_",currEx,".png"));
    }
}
# generatePictures(5)

extractRectangles <- function(image, xTL, yTL, xBR, yBR) {
    #stopifnot(xBR>xTL && yBR>yTL);
    cat(p("xTL=", xTL, "  yTL=", yTL, "  xBR=", xBR, "  yBR=", yBR, "\n"));
    if ( (xBR<=xTL) || (yBR<=yTL) ) { return(list()); }
    y <- yTL;
    while (y<=yBR) {
        x <- xTL;
        while (x<=xBR) {
            if (image[x,y,1]>.5 && image[x,y,2]<.2 && image[x,y,3]<.2) { ## Red is prominent
                cat(p("found a red pixel at: (", x, ",", y, ")\n"));
                topLeft  <- c(x,y);
                botRight <- c(0,0); # dummy val
                ## Looking for rightmost x pos
                xp <- x+1;
                xEndFound <- FALSE;
                while (!xEndFound && xp<=xBR) {
                    if (image[xp,y,1]<.5) {
                        cat(p("X: found a black pixel again at ", xp, "\n"));
                        xEndFound <- TRUE;
                        botRight[1] <- xp;
                    }
                    xp <- xp+1;
                }
                if (!xEndFound) { botRight[1] <- xp-1; }
                ## Looking for bottom most position
                yp <- y+1;
                yEndFound <- FALSE;
                while (!yEndFound && yp<=yBR) {
                    if (image[xp-2,yp,1]<.5) { # xp-2: -1 for last loop incr & -1 to get col before last black pixel (==last red pixel col)
                        cat(p("Y: found a black pixel again at ", yp, "\n"));
                        yEndFound <- TRUE;
                        botRight[2] <- yp;
                    }
                    yp <- yp+1;
                }
                if (!yEndFound) { botRight[2] <- yp-1; }
                cat(p("BR: (", botRight[1], ",", botRight[2], ")\n"));
                if (xEndFound && yEndFound && all(topLeft<botRight)) {
                    foundRect <- list(topLeft=topLeft,botRight=botRight);
                    res <- list(foundRect);
                    cat(p("FoundRect: ", foundRect, "\n"));
                    ## try to find rects on the right
                    rectsRight <- extractRectangles(image, botRight[1]+1, topLeft[2], xBR, yBR);
                    if (length(rectsRight)>0) { res <- c(res, rectsRight); }
                    ## try to find rects on the left
                    rectsLeft  <- extractRectangles(image, 1, topLeft[2], topLeft[1]-1, botRight[2]);
                    if (length(rectsLeft)>0) { res <- c(res, rectsLeft); }
                ## try to find rects on the below
                    rectsBelow <- extractRectangles(image, 1, botRight[2]+1, botRight[1], yBR);
                    if (length(rectsBelow)>0) { res <- c(res, rectsBelow); }
                    return(res);
                } else {
                    return(list());
                }
            }
            x<-x+1;
        }
        y<-y+1;
    }
    return(res);
}
## testImg <- readImage("mask2_4.png");
## rects <- extractRectangles(testImg, 1, 1, dim(testImg)[1], dim(testImg)[2]);

drawRect <- function(img, TL, BR, color=2){
    cat(p("TL: " , TL, "\n"));
    cat(p("BR: " , BR, "\n"));
    img[TL[1]:BR[1], TL[2] , color] <- 1;
    img[BR[1], TL[2]:BR[2] , color] <- 1;
    img[TL[1]:BR[1], BR[2] , color] <- 1;
    img[TL[1], TL[2]:BR[2] , color] <- 1;
    return(img)
}
## for (r in rects) { f <<- drawRect(testImg, unlist(r["topLeft"]), unlist(r["botRight"]), 2); }
