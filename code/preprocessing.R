library("EBImage")
options("EBImage.display"="browser")

# Personal utility functions
source("utils.R")
source("detectPosition.R")
source("pick.R")
source("count.R")

FOREGROUND <- c(1.0,0.0,0.0)
FOREGROUND_MARGINS <- c(0.3,0.2,0.2)
FOREGROUND_THRESHOLD <- .85
BG_SIZE <- c(60,120)
BACKGROUND <- EBImage::Image(0, BG_SIZE,0);
SHARPEN_FORCE <- 5

NB_DIVISIONS <- 4


mexicanHat77 <- function(image) {
    fhi <- matrix(
        c( 0, 0,-1,-1,-1, 0, 0 ,
           0,-1,-3,-3,-3,-1, 0 ,
          -1,-3, 0, 7, 0,-3,-1 ,
          -1,-3, 7,24, 7,-3,-1 ,
          -1,-3, 0, 7, 0,-3,-1 ,
           0,-1,-3,-3,-3,-1, 0 ,
           0, 0,-1,-1,-1, 0, 0),
        nrow=7, ncol=7)
    return(filter2(image, fhi))
}
# img <- readImage("../images/trainset/3_t-0.2_r-30_t-6_-5.75_b0.6_s0.6.png")
# display(mexicanHat77(img))

### Detects the edges the image (= applies laplacian)
edges <- function(image, force) {
    fhi <- matrix(1, nrow=3, ncol=3)
    fhi[2,2] <- -force  ## force was 8 in docs
    return(filter2(image, fhi))
}
# img <- readImage("../images/trainset/3_t-0.2_r-30_t-6_-5.75_b0.6_s0.6.png")
# display(edges(img, 8))

### Erodes the borders
sharpenImage <- function(image, force) {
    kern <- makeBrush(force, shape='disc') # force was 5 in docs
    return(erode(image, kern));
}
# img <- readImage("../images/trainset/3_t-0.2_r-30_t-6_-5.75_b0.6_s0.6.png")
# display(sharpenImage(img, 3))

### Computes various attributes for image in file "filename"
### filename: the name of the file to be treated
preprocessFile <- function(filename) {
    origImg <- readImage(filename)
    return(preprocessImage(origImg))
}

### Computes various attributes for image "image"
### image: an EBImage::Image
preprocessImage <- function(image) {
    ## Get only red elements
    redImg <- pickColor(image, FOREGROUND, FOREGROUND_MARGINS)
    redChan <- channel(redImg,"red") > FOREGROUND_THRESHOLD
    if (any(redChan)) {
        ### TODO: here, find a way to sharpen image
        ## That would make the computation of bwlabel() more constant over similar images
        digit <- getDigit(redChan)
        ##digit2 <- putOnBackground(digit, BACKGROUND);
        digit2 <- resize(digit, BG_SIZE[[1]], BG_SIZE[[2]]);
        ##print(digit2)
        ##display(digit2)
    } else {
        print("===> not enough red pixels found in the image!!!")
        digit2 <- BACKGROUND
    }

    ## Compute image attributes
    ## #white pixels in the whole picture
    attributesWhole  <- splitAndCount("whole", digit2, 1)
    ## #white pixels in each NB_DIVISIONS*NB_DIVISIONS pieces
    attributesPieces <- splitAndCount("pieces16", digit2, NB_DIVISIONS)

    ## Compute # segments
    segs <- bwlabel(digit2)
    ##display(colorLabels(segs))

    attributes <- list("pieces"=c(attributesWhole$pieces, attributesPieces$pieces, attributesWhole$pieces),
                       "counts"=c(attributesWhole$counts, attributesPieces$counts, nbSegs=max(segs)))

    ##print(attributes$counts)
    return(attributes)
}

### Computes the attributes for each image (following a given naming scheme) in a directory
### imageDir: the directory where to look for images
### pattern: the pattern for (image) files to consider
preprocessDir <- function(imageDir, pattern="*.png") {
    outDF <- data.frame()
    files <- list.files(imageDir, pattern=pattern)
    for(filename in files) {
        path <- paste(imageDir, filename, sep="/")
        print(paste('Treating file: ', path))
        attributes <- preprocessFile(path)
        outDF <- rbind(outDF, attributes$counts)
    }
    rownames(outDF) <- files
    return(outDF)
}

## outDF <- preprocessDir("~/Downloads/RedDigits/images/numbers/", "*.png")
outDF <- preprocessDir("~/Downloads/RedDigits/images/trainset/", "*.png")

write.csv(x=outDF, file="../trainset.csv", row.names = TRUE)
