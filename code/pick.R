library("EBImage")

##options("EBImage.display"="browser")
##
##### Load image
##f <- "~/Downloads/RedDigits/images/numbers/4.png"
##origImg <- readImage(f)
##imgSize <- dim(origImg)
##display(origImg)



### Computes the range of colors accepted
### color: the color of reference we want to keep (vector of 3 components: RGB, each in [0.0,1.0])
### tolerence: the margin of tolerence around each component of the color [each in [0.0,1.0]]
computeRange <- function(color, tolerance) {

    if(!(length(color)==3 && length(tolerance)==3)) {
        stop("Argument 'color' or 'tolerence' is not a 3-uple");
    }
    min <- color-tolerance
    min[min<0.0] <- 0.0
    min[min>1.0] <- 1.0
    max <- color+tolerance
    max[max<0.0] <- 0.0
    max[max>1.0] <- 1.0
    return(list(min=min,max=max))
}

## img: EBImage image
## color: vector of 3-values in [0.0,1.0]
## tolerance: vector of 3-values: percentage of tolerence on each color channel (RGB), in [0.0,1.0]
## Expects a multi-channel image (RGB => at least 3)
pickColor <- function(img, color, tolerance) {

    ### DEBUG:
    ## print(is.Image(img));
    ## print(colorMode(img));
    ## print(length(color));
    ## print(length(tolerance));

    ## Verify that img as 3 channels and color&tolerance 3 values
    if(!(is.Image(img) && colorMode(img)==2 && length(color)==3 && length(tolerance)==3)) {
        stop("Argument 'image' is not an image or 'color' or 'tolerence' is not a 3-uple");
    }

    outImg <- img
    range <- computeRange(color, tolerance);
    goodPositions <- ( (outImg[,,1]>=range$min[[1]] & outImg[,,1]<=range$max[[1]]) &
                       (outImg[,,2]>=range$min[[2]] & outImg[,,2]<=range$max[[2]]) &
                       (outImg[,,3]>=range$min[[3]] & outImg[,,3]<=range$max[[3]]) )
    outImg[!goodPositions] <- 0.0

    return(outImg)
}


##redImg <- pickColor(origImg, c(0.0,0.0,1.0), c(0.1,0.1,.2))
##display(redImg)
##redImg <- pickColor(origImg, c(0.0,0.0,1.0), c(0.4,0.4,.1))
##display(redImg)
