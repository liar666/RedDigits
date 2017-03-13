library("neuralnet");

source("TrainSet.R");  # Already loads Utils.R

################################### Load dataset

###trainSet <- loadTrainSetFromCSV("../trainsets/trainSet");
###trainSetPlusClass <- mergeDataAndClasses(trainSet);
filenameTrain <- p(TRAINSET_DIR, "/splitted/trainWhole.csv");
filenameTest  <- p(TRAINSET_DIR, "/splitted/testWhole.csv");
train <- read.csv(filenameTrain);
train <- train[,c(-1)]
test  <- read.csv(filenameTest);
test  <- ttest[,c(-1)]


################################## Compute a few models
formula <- generateFormula(COL_CLASS_NAMES, COL_IMG_NAMES);

## Worked for simple digits in B&W
print(paste(date(),"Fiting 1st NN..."));
fitNN1 <- neuralnet(formula, data=train, hidden=c(SIZE_THIRD), threshold=0.01, lifesign='full'); # 'minimal'/'full'/'none'
save(fitNN1, file=p(OUTDIR_MODELS, "MLP_NN1.rda"));
load(p(OUTDIR_MODELS, "MLP_NN1.rda"));

print(paste(date(),"Fiting 2nd NN..."));
fitNN2 <- neuralnet(formula, data=train, hidden=c(SIZE_THIRD), linear.output=T, threshold=0.01);
save(fitNN2, file=p(OUTDIR_MODELS, "MLP_NN2.rda"));
load(p(OUTDIR_MODELS, "MLP_NN2.rda"));

print(paste(date(),"Fiting 3rd NN..."));
fitNN3 <- neuralnet(formula, data=train, hidden=c(SIZE_THIRD*2, SIZE_THIRD, SIZE_THIRD*2), threshold=0.01);
save(fitNN3, file=p(OUTDIR_MODELS, "MLP_NN3.rda"));
load(p(OUTDIR_MODELS, "MLP_NN3.rda"));

print(paste(date(),"Fiting 4th NN..."));
fitNN4 <- neuralnet(formula, data=train, hidden=c(SIZE_CUBE, SIZE_THIRD*2, SIZE_THIRD), threshold=0.01);
save(fitNN4, file=p(OUTDIR_MODELS, "MLP_NN4.rda"));
load(p(OUTDIR_MODELS, "MLP_NN4.rda"));


## predsTrain <- compute(fitNN1, train); ### BOF: testing on learning data :{
predsTest  <- compute(fitNN1, test);

out    <- classesProbabilitesToClassNumber(predsTest);
wanted <- classesProbabilitesToClassNumber(test$Classes);
table(out, wanted);
