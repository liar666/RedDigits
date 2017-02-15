library("RSNNS")

source("TrainSet.R");  # Already load Utils.R

################################### Load dataset

trainSet <- loadTrainSetFromCSV("../trainsets/trainSet");
trainSetPlusClass <- mergeDataAndClasses(trainSet);

#######################################

fitMLP1 <- mlp(x=X, y=Y,
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
fitMLP2 <- mlp(x=X, y=Y,
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

save(fitMLP1, file="MLP_SNNS.rda");
load("MLP_SNNS.rda");
