###library("EBImage")
#####options("EBImage.display"="raster")
###
###source("pick.R")
###
###### Load basic image
###f <- "~/Downloads/RedDigits/images/numbers/4.png"
###origImg <- readImage(f)
###imgSize <- dim(origImg)
###display(origImg)
###
###redImg <- pickColor(origImg, c(1.0,0.0,0.0), c(0.2,0.1,0.1))
###display(redImg)
###redChan <- channel(redImg,"red")>.9
###display(redChan)


source("utils.R")

### Computes the center of gravity (=weigthed average) and top-left
### position of the digit in a binary image
### img: a binary image
findDigit<- function(img) {

    if(!(is.Image(img) && colorMode(img)==0)) {
        stop("Argument 'image' is not a binary image");
    }

    ## Center of gravity (=weigthed average)
    rs <- rowSums(img)
    cx <- crossprod(rs, 1:nrow(img))/sum(rs)
    cs <- colSums(img)
    cy <- crossprod(cs, 1:ncol(img))/sum(cs)

    ## Top-Left point
    tpx <- min(which(rs>0))
    tpy <- min(which(cs>0))

    return(list(centerG=round(c(cx,cy)),topLeft=c(tpx,tpy)));
}

### Computes the BoundingBox around the digit found by findDigit()
### fdOut: the list(centerG,topLeft) = results of findDigit()
computeBBox <- function(fdOut) {

    stopifnot(is.list(fdOut), fdOut$topLeft != NULL, fdOut$bottomRight != NULL)

    dSize <- 2*(abs(fdOut$topLeft-fdOut$centerG))
    topL <- fdOut$topLeft
    botR <- topL+dSize
    return(list(topLeft=topL,bottomRight=botR))
}


putOnBackground <- function(img, background) {

    imSize <- dim(img)
    bgSize <- dim(background)

    ## print(p("FOUND POSITION:", bgSize, " ", imSize))

    if (all(bgSize<imSize)) {
        stop(p("Background is smaller than image! ", bgSize," (bg) versus ", imSize, "(im)"))
    }

    # Put the img on the right border + center in height
    new <- background
    xMin <- bgSize[[1]]-imSize[[1]]+1
    xMax <- bgSize[[1]]
    yMin <- (bgSize[[2]]-imSize[[2]])/2+1
    yMax <- (bgSize[[2]]-imSize[[2]])/2+imSize[[2]]
    new[xMin:xMax, yMin:yMax] <- img[1:imSize[[1]], 1:imSize[[2]]]

    return(new)
}

### Extracts the digit from the binary image
### img: a binary image
### bbox: the bounding box (topleft+bottomright corners = output of computeBBox)
## TODO1: set minimal size (so that digit like 1 does end up with final image of same size than 8)
## TODO2: does not work if image is total black!
getDigit <- function(img) {

    if(!(is.Image(img) && colorMode(img)==0)) {
        stop("Argument 'image' is not a binary image");
    }

    imgSize <- dim(img)
    pos  <- findDigit(img)
    bbox <- computeBBox(pos)

    ## Truncate BBox to image size
    topLConfined <- confine(bbox$topLeft-c(1,1), c(0,0), imgSize)
    botRConfined <- confine(bbox$bottomRight+c(2,2), c(0,0), imgSize)

    digit <- img[topLConfined[[1]]:botRConfined[[1]],topLConfined[[2]]:botRConfined[[2]]]

    return(digit)
}




###pos <- findDigit(redChan)
###bbox <- computeBBox(pos)
###digit <- getDigit(redChan)
###display(digit)
###bg <- EBImage::Image(0,c(60,120),0);
###new <- putOnBackground(digit, bg);






######quatre <- matrix(
###    c(
###        0,0,0,0,0,0,0,0,0,0,0,0,0,0,
###        0,0,1,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,1,1,0,0,0,0,0,0,0,0,0,
###        0,0,0,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,0,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,0,0,0,0,0,0,0,0,0,0,0,0
###    ), ncol=7
###)
###huit <- matrix(
###    c(
###        0,0,0,0,0,0,0,0,0,0,0,0,0,0,
###        0,0,1,1,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,1,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,0,1,0,0,0,0,0,0,0,0,0,
###        0,0,1,1,1,0,0,0,0,0,0,0,0,0,
###        0,0,0,0,0,0,0,0,0,0,0,0,0,0
###    ), ncol=7
###)
###
###img <- quatre # huit
###rs <- rowSums(img)
###cx <- crossprod(rs, 1:nrow(img))/sum(rs)
###cs <- colSums(img)
###cy <- crossprod(cs, 1:ncol(img))/sum(cs)
###tpx <- min(which(rs>0))
###tpy <- min(which(cs>0))
###
###n <- img
###n[round(cx),round(cy)]<-8
###n[round(tpx),round(tpy)]<-9
###print(n)
