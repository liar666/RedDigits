##library("EBImage")
##options("EBImage.display"="raster")

##### Load basic image
##f <- "~/Downloads/RedDigits/images/numbers/4.png"
##origImg <- readImage(f)
##imgSize <- dim(origImg)
##display(origImg)
##threshImg <- channel(origImg, "red")>.8
##display(threshImg)

### Splits the images in sub-images, counting nbDivs divisions in each
### direction and counts ratio of pixels 'on'.
### prefix: an identifier for this cutting of the image (allows to cut same image in different splits)
### image: the EBimage to split
### nbDivs: the number of divisions on both x&y axis
## Expects a binary (TRUE/FALSE image)
splitAndCount <- function(prefix, image, nbDivs=3) {

    ## Debug
    ##show(image);

    ## Verify that image is binary
    if (!(is.Image(image) && colorMode(image)==0)) {
        stop(p("'image' (", prefix, ") is not a binary image"))
    }

    imgSize <- dim(image)
    pSize <- round(imgSize/nbDivs)
    pieces <- list()
    for(col in (1:nbDivs)-1) {
        for(row in (1:nbDivs)-1) {
            x1 <- col*pSize[[1]]
            x2 <- ((col+1)*pSize[[1]]-1)
            y1 <- row*pSize[[2]]
            y2 <- ((row+1)*pSize[[2]]-1)
            ##print(paste(x1, x2, y1, y2))
            pieces[[p(prefix,"_",col,"_",row)]] <- image[x1:x2,y1:y2]
        }
    }

    ## Debug
    ##    for(i in 1:(nbDivs*nbDivs)) {
    ##       display(pieces[[i]])
    ##    }

    ## normalizing #pixelsOn/#pixelsInRegion
    ## Works to get rid of input image size, but not if digits are +/- bold...

    ## TODO : count only by multiple of 100 or using log10(nb) ???
    ## This would create less variation between similar images
    sz <- imgSize[[1]]*imgSize[[2]]
    counts <- lapply(pieces, function(..., size=sz) { sum(...)/size })
    ## Debug
    ##print(paste(counts))

    return(list(pieces=pieces, counts=counts))
}

##sac <- splitAndCount(thresh, 3);
