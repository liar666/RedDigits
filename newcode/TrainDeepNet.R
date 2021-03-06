library("deepnet");

source("TrainSet.R");  # Already loads Utils.R

################################### Load dataset

##filenameTrain <- p(OUTDIR_TRAINSET, "splitted/trainWhole.csv");
##filenameTest  <- p(OUTDIR_TRAINSET, "splitted/testWhole.csv");
##train <- read.csv(filenameTrain);
##test  <- read.csv(filenameTest);
load(p(OUTDIR_TRAINSET, "splitted/train+testWhole.RData"))
train <- train[,c(-1)];
test  <- test[,c(-1)];

dataCols  <- grep("^i",colnames(test));
classCols <- grep("^c",colnames(test));


### TODO Seb: compte norm L2 on images

###################################
print(paste(date(),"Fiting 1st NN..."));
fitDN1 <- nn.train(x=as.matrix(train[,dataCols]), y=as.matrix(train[,classCols]),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(SIZE_THIRD)),
                   learningrate=0.58,
                   momentum=0.74,
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="linear",  # softmax/tanh?
                   numepochs=970,
                   batchsize=60,
                   hidden_dropout=0,
                   visible_dropout=0);
save(fitDN1, file=p(OUTDIR_MODELS,"DeepNet1.rda"));
load(p(OUTDIR_MODELS,"DeepNet1.rda"));


print(paste(date(),"Fiting 2nd NN..."));
fitDN2 <- nn.train(x=as.matrix(train[,dataCols]), y=as.matrix(train[,classCols]),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(SIZE_THIRD*2, SIZE_THIRD, SIZE_THIRD*2)),
                   learningrate=0.58,
                   momentum=0.74,
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="linear",  # softmax/tanh?
                   numepochs=970,
                   batchsize=60,
                   hidden_dropout=0,
                   visible_dropout=0);
save(fitDN2, file=p(OUTDIR_MODELS,"DeepNet2.rda"));
load(p(OUTDIR_MODELS,"DeepNet2.rda"));



print(paste(date(),"Fiting 3rd NN..."));
fitDN3 <- nn.train(x=as.matrix(train[,dataCols]), y=as.matrix(train[,classCols]),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(SIZE_CUBE, SIZE_THIRD*2, SIZE_THIRD)), # TODO: play with architecture!
                   learningrate=0.8,       # default=.8
                   momentum=0.5,           # default=.5
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="softmax",       # default="sigm" , can be: sigm/softmax/tanh
                   numepochs=200,
                   batchsize=60,
                   hidden_dropout=0,       #  test with >0?
                   visible_dropout=0);
save(fitDN3, file=p(OUTDIR_MODELS,"DeepNet3.rda"));
load(p(OUTDIR_MODELS,"DeepNet3.rda"));

print(paste(date(),"Fiting 4th NN..."));
fitDN4 <- nn.train(x=as.matrix(train[,dataCols]), y=as.matrix(train[,classCols]),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(SIZE_CUBE, SIZE_THIRD*2, SIZE_THIRD)), # TODO: play with architecture!
                   learningrate=0.8,       # default=.8
                   momentum=0.5,           # default=.5
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="softmax",       # default="sigm" , can be: sigm/softmax/tanh
                   numepochs=100,
                   batchsize=60,
                   hidden_dropout=0.2,     #  test with >0?
                   visible_dropout=0);
save(fitDN4, file=p(OUTDIR_MODELS,"DeepNet4.rda"));
load(p(OUTDIR_MODELS,"DeepNet4.rda"));

print(paste(date(),"Fiting 5th NN..."));
fitDN5 <- nn.train(x=as.matrix(train[,dataCols]), y=as.matrix(train[,classCols]),
                   initW=NULL,
                   initB=NULL,
                   hidden=round(c(SIZE_CUBE, SIZE_THIRD*2, SIZE_THIRD)), # TODO: play with architecture!
                   learningrate=0.8,       # default=.8
                   momentum=0.5,           # default=.5
                   learningrate_scale=1,
                   activationfun="sigm",
                   output="softmax",       # default="sigm" , can be: sigm/softmax/tanh
                   numepochs=100,
                   batchsize=60,
                   hidden_dropout=0.01,     #  test with >0?
                   visible_dropout=0);
save(fitDN5, file=p(OUTDIR_MODELS,"DeepNet5.rda"));
load(p(OUTDIR_MODELS,"DeepNet5.rda"));


###################################" Evaluation
fitDN <- fitDN5

## predsTrain <- nn.predict(fitDN, train[,dataCols]); ### BOF: testing on learning data :{
predsTest  <- nn.predict(fitDN, test[,dataCols]);

out    <- classesProbabilitesToClassNumber(predsTest);
wanted <- classesProbabilitesToClassNumber(test[,classCols]);
table(out, wanted);
