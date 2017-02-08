library("EBImage")
library("RSNNS")

set.seed(2016)
source("preprocessing.R")

## TODO: Be ware that numbers should all go through 0, so that normal
## images are also generated/treated

## tilt: +/-.4/.2
## rotate: +/-30/1°
## translate: +/-10% en x/y
## blur: 0.2->2.0/.1
## resize: -/+ 30%

### TODO: Add images that have nothing to do with numbers

#INDIR  <- "~/RedDigits/images/numbers/"
INDIR  <- "~/RedDigits/images/preprocessed/"
OUTDIR <- "~/RedDigits/model/"

p <- function(...) {
    paste(..., sep="")
}

removeExt <- function(filename) {
    gsub("(.*)[.].*", "\\1", filename, perl=T)
}


outDF <- data.frame()
files <- paste(c(seq(0,9),"E","H"),".png",sep="")
for(imgFile in files) {
    outDF1Nb <- data.frame()
    number <- removeExt(imgFile)
    img <- readImage(paste(INDIR,imgFile,sep="/"));
    imgSize <- dim(img)
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
                            tilted   <- affine(x=img, m=mconvol)
                            rotated  <- rotate(tilted, angle);
                            transtd  <- translate(rotated, c(x,y))
                            blured   <- gblur(transtd, sigma);
                            resized  <- resize(blured, w=ratio*imgSize[[1]])

                            newFile <- p(OUTDIR, number,
                                         "_t", tilt,
                                         "_r",angle,
                                         "_t",x,"_",y,
                                         "_b",sigma,
                                         "_s",ratio,".png")

                            print(paste('Writing file: ', newFile))
                            writeImage(resized, newFile)

                            print(paste('Treating file: ', newFile))
                            attributes <- preprocessImage(resized)
                            outDF1Nb <- rbind(outDF1Nb, attributes$counts)
                        }
                    }
                }
            }
        }
    }
    outDF1Nb["class"] <- number
    write.csv(x=outDF1Nb, file=p("../trainset_",number,".csv"), row.names = TRUE)
    outDF <- rbind(outDF, outDF1Nb)
}

fitMLP <- mlp (x=X, y=Y ,
               size = c (12 ,8) ,
               maxit = 1000 ,
               initFunc = " Randomize _ Weights " ,
               initFuncParams = c ( -0.3 , 0.3) ,
               learnFunc = " Std _ Backpropagation " ,
               learnFuncParams = c (0.2 , 0) ,
               updateFunc = " Topological _ Order " ,
               updateFuncParams = c (0) ,
               hiddenActFunc = " Act _ Logistic " ,
               shufflePatterns = TRUE ,
               linOut = TRUE)

save(m1, file="MLP_SNNS1.rda")


#load("my_model1.rda")
