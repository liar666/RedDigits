source("Utils.R");

## Store image in TrainSet
addToTrainSet <- function(trainSet, img, trueClass) {
    ## Rescale to very small image
    scaledImg <- resize(img, w=TRAIN_WIDTH, h=TRAIN_HEIGHT); ## auto keep-ratio? / filter="none"/"bilinear"?
    ## "flatten" image (2D df -> 1D vector)
    flatImg <- c(scaledImg, recursive=T);
    ## Add Class info
    class <- rep(0, length(CLASSES))
    names(class) <- CLASSES
    class[trueClass] <- 1  # vec are 1-based
    return(list(data=rbind(trainSet$data,flatImg), classes=rbind(trainSet$classes,class)));
}

generateTrainSet <- function() {
    trainSet <- list(data=data.frame(), classes=data.frame())
    for (cl in CLASSES) {
        ## Read/Load original image
        origImg <- readImage(p(INDIR_IMAGES,cl,".png"));
        imgSize <- dim(origImg);

        for(tilt in seq(from=-.4,to=.4,by=.2)) {
            ##for(tilt in seq(from=-.4,to=.4,length.out=5)) {
            mconvol <- matrix(c(1,tilt,-tilt*imgSize[[1]],0,1,0), ncol=2)
            for(angle in seq(from=-30, to=30, by=15)) {
                ##for(angle in seq(from=-30, to=30, length.out=5)) {
                for(x in seq(-10,10,by=5)*imgSize[[1]]/100) {
                    ##for(x in seq(-10,10,length.out=5)*imgSize[[1]]/100) {
                    for(y in seq(-10,10,by=5)*imgSize[[2]]/100) {
                        ##for(y in seq(-10,10,length.out=5)*imgSize[[2]]/100) {
                        for(sigma in seq(from=0.1, to=2.1, by=.5)) {
                            ##for(sigma in seq(from=0.1, to=2.1, length.out=5)) {
                            for(ratio in seq(from=.6, to=1.0, by=.1)) {
                                ##for(ratio in seq(from=0.6, to=1.0, length.out=5)) {
                                tilted   <- affine(x=origImg, m=mconvol);
                                rotated  <- rotate(tilted, angle);
                                transtd  <- translate(rotated, c(x,y));
                                blured   <- gblur(transtd, sigma);
                                resized  <- resize(blured, w=ratio*imgSize[[1]]);

                                newFile <- p(OUTDIR_IMAGES, cl,
                                             "_t", tilt,
                                             "_r", angle,
                                             "_t", x,"_", y,
                                             "_b", sigma,
                                             "_s", ratio, ".png");

                                ## To debug/speed up next iterations
                                ##print(paste("Writing file: ", newFile));
                                ##writeImage(resized, newFile);

                                print(paste("Treating file: ", newFile));
                                trainSet <- addToTrainSet(trainSet, resized, cl);
                                print(paste("New trainSet size: ", object.size(trainSet)));
                            } # size
                        } # blur
                    } # translate y
                } # translate x
            } # rotate
        } # titlt
    } # classes/"numbers"

    return(trainSet);
}


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


# saves "trainSet" to Data+Classes files starting with "prefix"
saveTrainSetToCSV <- function(trainSet, prefix) {
    write.csv2(x=trainSet$data, p(prefix,"Data.csv"), sep=",");       # TODO: check
    write.csv2(x=trainSet$classes, p(prefix,"Classes.csv"), sep=","); # TODO: check
}

# reloads "trainSet" from Data+Classes files starting with "prefix"
loadTrainSetFromCSV <- function(prefix) {
    trainSet <- list(); # TODO: check
    trainSet$data    <- read.csv2(file=p(prefix,"Data.csv"), sep=",");    # TODO: check
    trainSet$classes <- read.csv2(file=p(prefix,"Classes.csv"), sep=","); # TODO: check
    return(trainSet);
}

## Re-arrange trainSet by concatenating Data+Classes, particularly for NeuralNet lib
mergeDataAndClasses <- function(trainSet) {
    trainSetPlusClass <- cbind(trainSet$data, trainSet$classes);
    inames <- paste("i", 1:TRAIN_WIDTH*TRAIN_HEIGHT, sep="");
    cnames <- paste("c", CLASSES, sep="");
    colnames(trainSetPlusClass) <- c(inames,cnames);
    return(trainSetPlusClass);
}

################################## Re-arrange and check results

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

## Main method. Call this to check methods in this file & generate to trainsSet CSV files
main <- function() {
    filename <- p(OUTDIR_TRAINSET,"trainSet");
    trainSet <- generateTrainSet();
    saveTrainSetToCSV(trainSet, filename);
    trainSet2 <- loadTrainSetFromCSV(filename);
    trainSetPlusClass <- mergeDataAndClasses(trainSet); ## TODO: check
}
