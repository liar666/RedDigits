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
        origImg <- readImage(p("../images/preprocessed/",cl,".png"));
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
                            } # size
                        } # blur
                    } # translate y
                } # translate x
            } # rotate
        } # titlt
    } # classes/"numbers"

    return(trainSet);
}


## toBool <- function(img) {
##     return(img>.5)
## }


showImg <- function(trainSet, row) {
    flatImg <- trainSet$data[row,];
    img <- matrix(flatImg, nrow=TRAIN_WIDTH);
    i <- Image(img, c(TRAIN_WIDTH,TRAIN_HEIGHT), "Grayscale");
    display(i);
}


trainSet <- generateTrainSet();
write.csv2(x=trainSet$data, "trainSetData.csv", sep=",");       # TODO: check
write.csv2(x=trainSet$classes, "trainSetClasses.csv", sep=","); # TODO: check

### Reload with:
trainSet <- list() # TODO: check
trainSet$data    <- read.csv2(file="trainSetData.csv", sep=",");    # TODO: check
trainSet$classes <- read.csv2(file="trainSetClasses.csv", sep=","); # TODO: check
