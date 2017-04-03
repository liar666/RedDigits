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

library("EBImage")

### Main dir (changes from machine to machine)
WORKDIR <- "~/NEW_SAINTETIENNE/Perso/RedDigits/"

### Directories where to store outputs
##INDIR_IMAGES_NUM <- p(WORKDIR,"/images/preprocessed/");
##INDIR_IMAGES_NUM <- p(WORKDIR,"/images/numbers_orig/");
INDIR_IMAGES_NUM   <- p(WORKDIR,"/images/numbers_cleaned/");
INDIR_IMAGES_OTHER <- p(WORKDIR,"/images/non_numbers/");
OUTDIR_IMAGES      <- p(WORKDIR,"/images/trainset/");
OUTDIR_TRAINSET    <- p(WORKDIR,"/trainsets/");
OUTDIR_MODELS      <- p(WORKDIR,"/models/");

### Width and Height of the (reduced) images on which learning will occur
TRAIN_WIDTH   <- 10;
TRAIN_HEIGHT  <- 14;

### Third of the size/area of the image, to be used as rule of thumb for hidden layer size
SIZE_THIRD    <- TRAIN_WIDTH*TRAIN_HEIGHT/3;
SIZE_CUBE     <- TRAIN_WIDTH*TRAIN_HEIGHT*3;

### The names (factors) of the classes to be detected: numbers 0->9+E+H
CLASSES <- as.factor(c(0:9,"E","H","OTHER"));

# Columns names
COL_IMG_NAMES   <- pixel2col(1:(TRAIN_WIDTH*TRAIN_HEIGHT));
COL_CLASS_NAMES <- class2col(CLASSES);


### Removes the extension from a filename
removeExt <- function(filename) {
    return(gsub("(.*)[.].*", "\\1", filename, perl=T));
}

### Generates the full expression as a formula from the variable name (work around for a bug in NeuralNet lib)
generateFormula <- function(leftVars, rightVars) {
    formula <- as.formula(paste(paste(leftVars, collapse = "+"), "~", paste(rightVars, collapse="+")));
    return(formula);
}

normL2 <- function(x) { norm(x, type="2"); }
# normL2 <- function(x) { sqrt(sum(x^2)); }
