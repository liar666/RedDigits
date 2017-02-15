library("neuralnet");

source("TrainSet.R");  # Already load Utils.R

################################### Load dataset

trainSet <- loadTrainSetFromCSV("../trainsets/trainSet");
trainSetPlusClass <- mergeDataAndClasses(trainSet);

# TODO: use these vectors below, not trainSetPlusClass
idx <- sample.int(nrow(trainSetPlusClass), round(.9*nrow(trainSetPlusClass)), replace=FALSE);
train <- trainSetPlusClass[idx,];
test  <- trainSetPlusClass[-idx,];

################################## Compute a few models

formula <- generateFormula(cnames, inames);

## Worked for simple digits in B&W
fitNN1 <- neuralnet(formula, data=train, hidden=c(SIZE_THIRD), threshold=0.01);
##fitNN2 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(SIZE_THIRD), linear.output=T, threshold=0.01)
##fitNN3 <- neuralnet(formula, data=trainSetPlusClass, hidden=c(SIZE_THIRD*2, SIZE_THIRD, SIZE_THIRD*2), threshold=0.01)

save(fitNN1, file=p(OUTDIR_MODELS, "MLP_NN.rda"));
fitNN12 <- load(p(OUTDIR_MODELS, "MLP_NN.rda"));

predsTrain <- compute(fitNN1, train); ### BOF: testing on learning data :{
predsTest  <- compute(fitNN1, test);

out    <- classesProbabilitesToClassNumber(predsTest);
wanted <- classesProbabilitesToClassNumber(test$Classes);
table(out, wanted);
