library("EBImage")


### Load image
f <- "~/Downloads/RedDigits/images/numbers/4.png"
origImg <- readImage(f)
imgSize <- dim(origImg)
display(origImg)


############### GLOBAL TREATMENTS

### Version1: problem: white color as some red component => will be kept
### Get only red channel
redImg <- channel(origImg, "red")
display(redImg)
### Eliminate non-truly-red pixels => binary image
threshold <- .9
##threshold <- otsu(redImg) ## Find threshold value dynamically (=> too low!!)
threshImg <- (redImg > threshold)
display(threshImg)

############### CENTER IMAGE & SPLIT INTO PIECES

### Focus on THE wanted digit
## TODO:  (here, remove only borders) => adapt dynamically
## 1. Simply center on median of red points?
## 2. Find rightmost red pixels?
cropX <- 0:dim[[1]]
cropY <- (dim[[2]]/4):(dim[[2]]/4*3)
cropImg <- threshImg[cropX, cropY]
display(cropImg)


### Version2
transp <- t(threshImg)
sumCols <- colSums(transp)
meanCols <- colMeans(transp)
meanRows <- rowMeans(transp)
maxCol <- which.max(sums)
rightmostPos <- maxCol+.1*(ncol(threshImg)-maxCol)

cropImg2 <- threshImg[0:rightmostPos, 0:ncol(threshImg)]
display(cropImg2)


############### TREATMENTS ON PIECES

### Find/Count segments
### 1. Erode regions
#kern <- makeBrush(3, shape='diamond')
#display(kern, interpolate=FALSE)
#erodImg <- erode(cropImg, kern)
### 2. Find edges
#fhi <- matrix(1, nrow = 3, ncol = 3)
#fhi[2, 2] <- -8
#edgesImg = filter2(erodImg, fhi)
#display(edgesImg)
#

### Segment the image
segments <- bwlabel(cropImg)
table(segments)
display(normalize(segments))
display(colorLabels(segments))
