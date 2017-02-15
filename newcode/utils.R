### DONE: make code work with classes as factors
### DONE: add loop to generate bigger trainset
### DONE 2a: remove useless files in same dir
### DONE 2b: split this one in Utils / genTrainSet / Train / Use
### TODO 3: use original images + norme L2
### TODO: verify places for images/trainset/models

library("EBImage")

TRAIN_WIDTH   <- 10;
TRAIN_HEIGHT  <- 14;
SIZE_THIRD    <- TRAIN_WIDTH*TRAIN_HEIGHT/3;
OUTDIR_MODELS <- "~/RedDigits/models/";
OUTDIR_IMAGES <- "~/RedDigits/images/trainset/";

CLASSES <- as.factor(c(0:9,"E","H"));

set.seed (2016)

### blur, etc must be applied before thresholding!

p<-function(...) {
    return(paste(...,sep=""))
}

removeExt <- function(filename) {
    gsub("(.*)[.].*", "\\1", filename, perl=T)
}
