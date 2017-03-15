library("RSNNS")

source("TrainSet.R");  # Already load Utils.R

################################### Load dataset

###trainSet <- loadTrainSetFromCSV("../trainsets/trainSet");
###trainSetPlusClass <- mergeDataAndClasses(trainSet);
filenameTrain <- p(TRAINSET_DIR, "/splitted/trainWhole.csv");
filenameTest  <- p(TRAINSET_DIR, "/splitted/testWhole.csv");
train <- read.csv(filenameTrain);
train <- train[,c(-1)];
test  <- read.csv(filenameTest);
test  <- ttest[,c(-1)];

#######################################
print(paste(date(),"Fiting 1st NN..."));
fitRSNNS1 <- mlp(x=train[,dataCols], y=train[,classCols],
               size = c(SIZE_THIRD),
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
save(fitRSNNS1, file=p(OUTDIR_MODELS,"RSNNS1.rda"));
load(p(OUTDIR_MODELS,"RSNNS1.rda"));


print(paste(date(),"Fiting 2nd NN..."));
fitRSNNS2 <- mlp(x=train[,dataCols], y=train[,classCols],
               size = c(SIZE_THIRD*2, SIZE_THIRD, SIZE_THIRD*2),
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
save(fitRSNNS2, file="RSNNS2.rda");
load("RSNNS2.rda");

print(paste(date(),"Fiting 3rd NN..."));
fitRSNNS3 <- mlp(x=train[,dataCols], y=train[,classCols],
               size = c(SIZE_CUBE, SIZE_THIRD*2, SIZE_THIRD),
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
save(fitRSNNS3, file="RSNNS3.rda");
load("RSNNS3.rda");


###################################" Evaluation
fitRSNNS <- fitRSNNS3

## predsTrain <- nn.predict(fitDN, train[,dataCols]); ### BOF: testing on learning data :{
predsTest  <- nn.predict(fitRSNNS, test[,dataCols]);

out    <- classesProbabilitesToClassNumber(predsTest);
wanted <- classesProbabilitesToClassNumber(test[,classCols]);
table(out, wanted);
