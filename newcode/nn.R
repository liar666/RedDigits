### DONE: make code work with classes as factors
### TODO 1: add loop to generate bigger trainset
### TODO 2: remove useless files in same dir + split this one in Utils / genTrainSet / Train / Use
### TODO 3: use original images + norme L2
library("EBImage")

TRAIN_WIDTH  <- 10
TRAIN_HEIGHT <- 14
thirdSize    <- TRAIN_WIDTH*TRAIN_HEIGHT/3

CLASSES <- as.factor(c(0:9,"E","H"));

set.seed (2016)

### blur, etc must be applied before thresholding!

p<-function(...) {
    return(paste(...,sep=""))
}

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
    for (i in CLASSES) {
        ## Read/Load original image
        origImg <- readImage(p("../images/preprocessed/",i,".png"));
        trainSet <- addToTrainSet(trainSet, origImg, i);

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

###################################

library("deepnet")
fitDN1 <- nn.train(x=as.matrix(trainSet$data), y=as.matrix(trainSet$classes),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(thirdSize)),
                   learningrate=0.58,
                   momentum=0.74,
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="linear",  # softmax/tanh?
                   numepochs=970,
                   batchsize=60,
                   hidden_dropout=0,
                   visible_dropout=0)
fitDN2 <- nn.train(x=as.matrix(trainSet$data), y=as.matrix(trainSet$classes),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(thirdSize*2, thirdSize, thirdSize*2)),
                   learningrate=0.58,
                   momentum=0.74,
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="linear",  # softmax/tanh?
                   numepochs=970,
                   batchsize=60,
                   hidden_dropout=0,
                   visible_dropout=0)

save(fitDN1, file="MLP_DN.rda");
load("MLP_DN.rda");

preds <- nn.predict(fitDN1,trainSet$data)

##################################

mergeDataAndClasses <- function(trainSet) {
    trainSetPlusClass <- cbind(trainSet$data, trainSet$classes);
    inames <- paste("i", 1:TRAIN_WIDTH*TRAIN_HEIGHT, sep="");
    cnames <- paste("c", CLASSES, sep="");
    colnames(trainSetPlusClass) <- c(inames,cnames);
    return(trainSetPlusClass);
}
trainSetPlusClass <- mergeDataAndClasses(trainSet); ## TODO: check

library("neuralnet")
formula <- as.formula(paste(paste(cnames, collapse = "+"), "~", paste(inames, collapse="+")))
fitNN1 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(thirdSize), threshold=0.01) # Works?
fitNN2 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(thirdSize), linear.output=T, threshold=0.01)
fitNN3 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(thirdSize*2, thirdSize, thirdSize*2), threshold=0.01)

preds <- compute(fitNN1, trainSet$data)

save(fitNN1, file="MLP_NN.rda");
load("MLP_NN.rda");


binarizeCol <- function(row) {
    a<-rep(0,length(row));
    a[which.max(row)]<-1;
    return(a);
}
binarizePreds <- function(preds) {
    return(apply(X=preds, MARGIN=1, FUN=binarizeCol))
}
toClass <- function(preds) {
    return(CLASSES[max.col(preds)]);
}

#######################################
library("RSNNS")

fitMLP1 <- mlp(x=X, y=Y,
               size = c(thirdSize),
               maxit = 1000,
               initFunc = "Randomize_Weights",
               initFuncParams = c(-0.3 , 0.3),
               learnFunc = "Std_Backpropagation",
               learnFuncParams = c(0.2 , 0),
               updateFunc = "Topological_Order",
               updateFuncParams = c(0),
               hiddenActFunc = "Act_Logistic",
               shufflePatterns = TRUE,
               linOut = TRUE);
fitMLP2 <- mlp(x=X, y=Y,
               size = c(thirdSize*2, thirdSize, thirdSize*2),
               maxit = 1000,
               initFunc = "Randomize_Weights",
               initFuncParams = c(-0.3 , 0.3),
               learnFunc = "Std_Backpropagation",
               learnFuncParams = c(0.2 , 0),
               updateFunc = "Topological_Order",
               updateFuncParams = c(0),
               hiddenActFunc = "Act_Logistic",
               shufflePatterns = TRUE,
               linOut = TRUE);

save(fitMLP1, file="MLP_SNNS.rda");
load("MLP_SNNS.rda");
