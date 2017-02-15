library("neuralnet")

################################### Load dataset

trainSet <- list() # TODO: check
trainSet$data    <- read.csv2(file="trainSetData.csv", sep=",");    # TODO: check
trainSet$classes <- read.csv2(file="trainSetClasses.csv", sep=","); # TODO: check

################################## Re-arrange trainSet

mergeDataAndClasses <- function(trainSet) {
    trainSetPlusClass <- cbind(trainSet$data, trainSet$classes);
    inames <- paste("i", 1:TRAIN_WIDTH*TRAIN_HEIGHT, sep="");
    cnames <- paste("c", CLASSES, sep="");
    colnames(trainSetPlusClass) <- c(inames,cnames);
    return(trainSetPlusClass);
}
trainSetPlusClass <- mergeDataAndClasses(trainSet); ## TODO: check

##################################

formula <- as.formula(paste(paste(cnames, collapse = "+"), "~", paste(inames, collapse="+")))
fitNN1 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(SIZE_THIRD), threshold=0.01) # Works?
fitNN2 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(SIZE_THIRD), linear.output=T, threshold=0.01)
fitNN3 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(SIZE_THIRD*2, SIZE_THIRD, SIZE_THIRD*2), threshold=0.01)

preds <- compute(fitNN1, trainSet$data)

save(fitNN1, file="MLP_NN.rda");
load("MLP_NN.rda");

################################## Re-arrange and check results

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

