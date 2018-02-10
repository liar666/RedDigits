### DONE: make code work with classes as factors
### DONE: add loop to generate bigger trainset
### DONE 2a: remove useless files in same dir
### DONE 2b: split this one in Utils / genTrainSet / Train / Use
### DONE: verify places for images/trainset/models

### Set seed for reproducible experiments
set.seed (2016)


### Shorter name for simple String concatenation
p<-function(...) {
    return(paste(...,sep=""))
}

### Transforms a prefix + value into a colname by concatenating them as string with no sep
toColName <- function(prefix, value) {
    return(p(prefix, value));
}
### Uses toColName to generate a colname from a class factor
class2col <- function(trueClass) {
    return(toColName("c",trueClass));
}
### Uses toColName to generate a colname from a pixel number
pixel2col <- function(pixelNb) {
    return(toColName("i", pixelNb));
}

library("EBImage");

### Main dir (changes from machine to machine)
WORKDIR <- "~/Perso/RedDigits/";

### Directories where to store outputs
##INDIR_IMAGES_NUM <- p(WORKDIR,"/images/preprocessed/");
##INDIR_IMAGES_NUM <- p(WORKDIR,"/images/numbers_orig/");
INDIR_IMAGES_NUM   <- p(WORKDIR,"/images/numbers_cleaned/");
INDIR_IMAGES_OTHER <- p(WORKDIR,"/images/non_numbers/");
OUTDIR_IMAGES      <- p(WORKDIR,"/images/trainset/");
OUTDIR_TRAINSET    <- p(WORKDIR,"/trainsets/BlackAndRed/");
OUTDIR_MODELS      <- p(WORKDIR,"/models//BlackAndRed/");

### Width and Height of the (reduced) images on which learning will occur
TRAIN_WIDTH   <- 20;
TRAIN_HEIGHT  <- 28;
IMG_DEPTH     <- 3; # TODO: ensure RGB images!

### Third of the size/area of the image, to be used as rule of thumb for hidden layer size
SIZE_THIRD    <- TRAIN_WIDTH*TRAIN_HEIGHT/3;
SIZE_CUBE     <- TRAIN_WIDTH*TRAIN_HEIGHT*3;

### The names (factors) of the classes to be detected: numbers 0->9+E+H+OTHER
CLASSES <- as.factor(c(0:9,"E","H","OTHER"));

# Columns names
COL_IMG_NAMES   <- pixel2col(1:(TRAIN_WIDTH*TRAIN_HEIGHT*IMG_DEPTH));
COL_CLASS_NAMES <- class2col(CLASSES);


### Removes the extension from a filename
removeExt <- function(filename) {
    return(gsub("(.*)[.].*", "\\1", filename, perl=T));
}

### Removes the alpha channel (by reconstructing a new img with the
### red/green/blue channel of the current image)
### In case of error => returns input as is
###
### TODO: find a simpler/more efficient way to do that!
removeAlphaChannel <- function(img) {
    if (is.Image(img) && (colorMode(img)==2) && (dim(img)[3]>3)) {
        return(rgbImage(channel(img, 'red'),channel(img, 'green'),channel(img, 'blue')));
    } else {
        return(img);
    }
}

## Convert an image in an RGB image (= removes alpha channel or compose grey channels)
### In case of error => returns input as is
ensureImageDimensions <- function(img) {
    if (is.Image(img) && (colorMode(img)==0)) {
        return(rgbImage(img,img,img));
    }
    if (is.Image(img) && (colorMode(img)==2) && (dim(img)[3]>3)) {
        return(removeAlphaChannel(img));
    }
    ## TODO: treat cases where dim(img)[3]<3
    return(img);
}


### Generates the full expression as a formula from the variable name (work around for a bug in NeuralNet lib)
generateFormula <- function(leftVars, rightVars) {
    formula <- as.formula(paste(paste(leftVars, collapse = "+"), "~", paste(rightVars, collapse="+")));
    return(formula);
}

normL2 <- function(x) { norm(x, type="2"); }
# normL2 <- function(x) { sqrt(sum(x^2)); }

## NOT used: applies a threshold to obtain a boolean image
toBooleanImage <- function(img) {
     return(img>.5)
}

# Displays an image, for debugging purposes
showImg <- function(trainSet, row) {
    flatImg <- trainSet$data[row,];
    img <- matrix(flatImg, nrow=TRAIN_WIDTH);
    i <- Image(img, c(TRAIN_WIDTH,TRAIN_HEIGHT), "Grayscale");
    display(i);
}


## Returns a vector of all 0s, but at the position of the max, which is set to 1.
binarizeCol <- function(row) {
    a<-rep(0,length(row));
    a[which.max(row)]<-1;
    return(a);
}
## Returns a data.frame with 1 where the value was the max of the row, 0 elsewhere in the row
binarizePreds <- function(preds) {
    return(apply(X=preds, MARGIN=1, FUN=binarizeCol))
}

## Transforms a dataframe of probabilities for each class of each example/row into a column vector with the most probable class for each example/row
classesProbabilitesToClassNumber <- function(preds) {
    return(CLASSES[max.col(preds)]);
}
