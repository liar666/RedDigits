library("EBImage")

## TODO: Be ware that numbers should all go through 0, so that normal
## images are also generated/treated


source("preprocessing.R")

## tilt: +/-.4/.2
## rotate: +/-30/1°
## translate: +/-10% en x/y
## blur: 0.2->2.0/.1
## resize: -/+ 30%

### TODO: Add images that have nothing to do with numbers

INDIR  <- "~/RedDigits/images/numbers/"
OUTDIR <- "~/RedDigits/images/trainset/"
## x <- readImage(system.file("images", "sample.png", package="EBImage"))

p <- function(...) {
    paste(..., sep="")
}

removeExt <- function(filename) {
    gsub("(.*)[.].*", "\\1", filename, perl=T)
}


outDF <- data.frame()
###files <- list.files(INDIR, pattern="*.png")
##files <- c("E.png", "H.png")
##files <- paste(seq(0,4),".png",sep="")
files <- paste(seq(5,9),".png",sep="")
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
write.csv(x=outDF, file="../trainset_full.csv", row.names = TRUE)
