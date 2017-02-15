library("deepnet")

################################### Load dataset

trainSet <- list() # TODO: check
trainSet$data    <- read.csv2(file="trainSetData.csv", sep=",");    # TODO: check
trainSet$classes <- read.csv2(file="trainSetClasses.csv", sep=","); # TODO: check

###################################

fitDN1 <- nn.train(x=as.matrix(trainSet$data), y=as.matrix(trainSet$classes),
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
                   visible_dropout=0)
fitDN2 <- nn.train(x=as.matrix(trainSet$data), y=as.matrix(trainSet$classes),
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
                   visible_dropout=0)

save(fitDN1, file="MLP_DN.rda");
load("MLP_DN.rda");

preds <- nn.predict(fitDN1,trainSet$data)

