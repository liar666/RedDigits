library("EBImage")

TRAIN_WIDTH <- 10
TRAIN_HEIGHT <- 14

set.seed (2016)

### blur, etc must be applied before thresholding!

p<-function(...) {
    return(paste(...,sep=""))
}

## Store image in TrainSet
addToTrainSet <- function(df, img, trueClass) {
    ## Rescale to very small image
    scaledImg <- resize(img, w=TRAIN_HEIGHT, h=TRAIN_HEIGHT); ## use keep-ratio?
    ## "flatten" image (2D df -> 1D vector)
    flatImg <- c(scaledImg, recursive=T);
    ## Add Class info
    flatImg <- c(Class=trueClass, flatImg);
    return(rbind(df, flatImg));
}

generateTrainSet <- function() {
    df <- data.frame()
    for (i in 0:9) {
        ## Read/Load original image
        origImg <- readImage(p("../images/preprocessed/",i,".png"));
        df <- addToTrainSet(df, origImg, i);

        ### TODO1: Add blur (tilt, rotation...) to image
        ## for(s in seq(.5,5,by=.5)) {
        ##     for (r in seq(1,5,by=2)) { ## must be an odd integer
        ##         img <- gblur(origImg, s, r);
        ##         df <- addToTrainSet(df, img, i);
        ##     }
        ## }
    }
    ## TODO2: Add non-number images
    ## ...
    col.names(df)[1] <- "Class"; # Why is it lost during addToTrainSet::rbind????
    return(df);
}



showImg <- function(trainSet, row) {
    flatImg <- trainSet[row,2:(TRAIN_WIDTH*TRAIN_HEIGHT+1)]
    img <- data.frame(matrix(flatImg, nrow=TRAIN_WIDTH));
    i <- as.Image(img);
    #colormode(i) <- "Grayscale"
    display(i)
}

trainset <- generateTrainSet();

library("neuralnet")
fit <- neuralnet(Class~., data=trainset, hidden=c(3,3), threshold=0.01)

library("deepnet")
fitB <- nn.train(x=as.matrix(trainset[,-1]), y=trainset[,"Class"],
                 initW=NULL,
                 initB=NULL,
                 hidden=c(10, 12, 20),
                 learningrate=0.58,
                 momentum=0.74,
                 learningrate_scale=1,
                 activationfun="sigm",
                 output="linear",  # softmax?
                 numepochs=970,
                 batchsize=60,
                 hidden_dropout=0,
                 visible_dropout=0)
preds <- nn.predict(fitB,trainset[,-1])
