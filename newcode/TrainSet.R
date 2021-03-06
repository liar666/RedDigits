source("Utils.R");

EMPTY_VECTOR <- rep(0, length(CLASSES))
names(EMPTY_VECTOR) <- COL_CLASS_NAMES;

## rbinds numSet to wholeSet, keeping colnames from numSet and
## reassigning fresh rownames and returns the result
mergeSets <- function(wholeSet, numSet) {
    ###print("--- rownames(wholeSet$data)") ; print(rownames(wholeSet$data));
    ###print("--- colnames(wholeSet$data)");  print(colnames(wholeSet$data));
    ###print("--- rownames(numSet$data)");    print(rownames(numSet$data));
    ###print("--- colnames(numSet$data)");    print(colnames(numSet$data));
    newData    <- rbind(wholeSet$data, numSet$data);
    colnames(newData) <- colnames(numSet$data);
    rownames(newData) <- 1:nrow(newData);
    ###print("+++ rownames(wholeSet$classes)");    print(rownames(wholeSet$classes));
    ###print("+++ colnames(wholeSet$classes)");    print(colnames(wholeSet$classes));
    ###print("+++ rownames(numSet$classes)");      print(rownames(numSet$classes));
    ###print("+++ colnames(numSet$classes)");      print(colnames(numSet$classes));
    newClasses <- rbind(wholeSet$classes,numSet$classes);
    colnames(newClasses) <- colnames(numSet$classes);
    rownames(newClasses) <- 1:nrow(newClasses);
    return(list(data=newData, classes=newClasses));
}

## Store image in TrainSet
addToTrainSet <- function(trainSet, img, trueClass) {
    ## Rescale to very small image
    scaledImg <- resize(img, w=TRAIN_WIDTH, h=TRAIN_HEIGHT); ## auto keep-ratio? / filter="none"/"bilinear"?
    ## "flatten" image (2D df -> 1D vector)
    flatImg <- c(scaledImg, recursive=T);
    names(flatImg) <- COL_IMG_NAMES;
      ###print(">>>addToTrainSet::names(flatImg)");      print(names(flatImg));
    ## Add Class info
    class <- EMPTY_VECTOR
    class[class2col(trueClass)] <- 1
      ###print(">>>addToTrainSet::names(class)");      print(names(class));

    newData    <- rbind(trainSet$data, flatImg);
    colnames(newData) <- names(flatImg);
    rownames(newData) <- 1:nrow(newData);
      ###print("***addToTrainSet::rownames(newData)");      print(rownames(newData));
      ###print("***addToTrainSet::colnames(newData)");      print(colnames(newData));
    newClasses <- rbind(trainSet$classes, class);
    colnames(newClasses) <- names(class);
    rownames(newClasses) <- 1:nrow(newClasses);
      ###print("***addToTrainSet::rownames(newClasses)");      print(rownames(newClasses));
      ###print("***addToTrainSet::colnames(newClasses)");      print(colnames(newClasses));
    return(list(data=newData, classes=newClasses));
}

##  Based on 0-9+E+H original images, use
##  tilt+rotation+transl+blur+resize, generates 12 * .8/.2 * 60/15 *
##  20/5 * 20/5 * 2/.5 * .4/.1 =49152 images to learn on.
generateTrainSet <- function() {
    trainSet <- list(data=data.frame(), classes=data.frame())

    ## Treating examples of numbers
    for (cl in CLASSES[c(-length(CLASSES))]) {
        ## Read/Load original image
        origImg <- readImage(p(INDIR_IMAGES_NUM, cl, ".png"));
        origImg <- ensureImageDimensions(origImg);
        imgSize <- dim(origImg);

        print(paste(date(), "Treating Class: ", cl));

        trainSetAux <- list(data=data.frame(), classes=data.frame())  ## to split in smallest set => speedup?
        ### TODO: OPTIMIZE BY MOVING EACH OPERATION IN ITS LOOP!!!
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

                                ## newFile <- p(OUTDIR_IMAGES, cl,
                                ## "_t", tilt,
                                ## "_r", angle,
                                ## "_t", x,"_", y,
                                ## "_b", sigma,
                                ## "_s", ratio, ".png");

                                ## To debug/speed up next iterations
                                ##print(paste("Writing file: ", newFile));
                                ##writeImage(resized, newFile);

                                ##print(paste("Treating file: ", newFile));
                                trainSetAux <- addToTrainSet(trainSetAux, resized, cl);
                                ##print(trainSetAux);
                                ##print(paste("New trainSetAux size: ", object.size(trainSetAux)));
                            } # size
                        } # blur
                    } # translate y
                } # translate x
            } # rotate
        } # tilt
        trainSet <- mergeSets(trainSet,trainSetAux);
        rm(trainSetAux); # cleans up memory
        print(paste("New trainSet size: ", object.size(trainSet)));
    } # classes/"numbers"

    ## Treating counter examples
    trainSetAux <- list(data=data.frame(), classes=data.frame())  ## to split in smallest set => speedup?
    for (ce in list.files(INDIR_IMAGES_OTHER)) {
        ceImg <- readImage(p(INDIR_IMAGES_OTHER, ce));
        ceImg <- ensureImageDimensions(ceImg);
        print(paste(date(), "Treating Counter-Example: ", ce));
        trainSetAux <- addToTrainSet(trainSetAux, ceImg, CLASSES[length(CLASSES)]);
    }
    trainSet <- mergeSets(trainSet,trainSetAux);
    rm(trainSetAux); # cleans up memory
    print(paste("New trainSet size: ", object.size(trainSet)));

    return(trainSet);
}


# saves "trainSet" to Data+Classes files starting with "prefix"
saveTrainSet <- function(trainSet, prefix) {
    write.csv(x=trainSet$data, p(prefix,"Data.csv"));
    write.csv(x=trainSet$classes, p(prefix,"Classes.csv"));
    save(trainSet, file=p(prefix,"Data+Classes.RData"));
}

# reloads "trainSet" from Data+Classes files starting with "prefix"
loadTrainSetFromCSV <- function(prefix) {
    trainSet <- list();
    trainSet$data    <- read.csv(file=p(prefix,"Data.csv"));
    trainSet$classes <- read.csv(file=p(prefix,"Classes.csv"));
    return(trainSet);
}

## Re-arrange trainSet by concatenating Data+Classes, particularly for NeuralNet lib
mergeDataAndClasses <- function(trainSet) {
    trainSetPlusClass <- cbind(trainSet$data, trainSet$classes);
    colnames(trainSetPlusClass) <- c(COL_IMG_NAMES, COL_CLASS_NAMES);
    return(trainSetPlusClass);
}

## Main method. Call this to check methods in this file & generate to trainsSet CSV files
main <- function() {
    filename <- p(OUTDIR_TRAINSET,"trainSet");
    trainSet <- generateTrainSet();
    ## Save full trainSet in 2 separate files: data / classes
    saveTrainSet(trainSet, filename);
    #trainSet2 <- loadTrainSetFromCSV(filename);
    ## Save full trainSet in 1 single file
    trainSetPlusClass <- mergeDataAndClasses(trainSet);
    write.csv(trainSetPlusClass, p(filename,"Whole.csv"));

    ## Save trainSet cols names in environment
    dataCols  <<- grep("i[0-9]*",  colnames(trainSetPlusClass));
    classCols <<- grep("c[0-9]*", colnames(trainSetPlusClass));

    ## Split into Train/Test sets
    sampleIdx <<- sample.int(nrow(trainSetPlusClass), round(.9*nrow(trainSetPlusClass)), replace=FALSE);
    train <- trainSetPlusClass[sampleIdx,];
    test  <- trainSetPlusClass[-sampleIdx,];
    ## Save Train & Test sets in single data+classes files
    write.csv(x=train, p(OUTDIR_TRAINSET,"trainWhole.csv"));
    write.csv(x=test, p(OUTDIR_TRAINSET,"testWhole.csv"));
    save(train, test, file=p(OUTDIR_TRAINSET,"train+test.RData"));
}
