#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
   Tools to generate the training/test dataset
"""

import sys    # To access commandline arguments

import pandas as pd # For DataFrames

import PreProcessor

class Generator:
    """Generates the dataset from the simple digit images using data augmentation (blur, tilt, zoom, rotate)"""
    HOME = "/home/guigui/GMCodes/RedDigits/"
    DIGIT_IMAGE_DIR = HOME + "/images/numbers_cleaned/"
    OUTDIR = HOME + "/trainset/"

    tiltRange  = [t/10 for t in range(4, 4+1, 2)]
    angleRange = range(-30, 30+1, 15)
    xTranslRange = [x*PreProcessor.TRAIN_WIDTH for x in range(-10, 10+1, 5)]
    yTranslRange = [y*PreProcessor.TRAIN_HEIGHT for y in range(-10, 10+1, 5)]
    blurRange = [s/10 for s in range(1, 21+1, 5)]
    zoomRange = [z/10 for z in range(6, 10+1, 1)]

    def die(self):
        print("Generator destroyed")

    def __init__(self):
        dataSet = None
    
    @staticmethod
    def listFiles(dirname):
        files = []
        for (dirpath, dirnames, filenames) in walk(DIGIT_IMAGE_DIR):
            files = files + filenames # list(map(lambda x: dirpath+x, filenames))
        return(files)
    
    @staticmethod
    def extractNumber(filename):
        return filename[0]

    def generate(self, sourceDirectory):
        if dataSet == None:
            files = Generator.listFiles(self.DIGIT_IMAGE_DIR)
            for imgFile in files:
                outDF1Nb = pd.DataFrame()
                number =- extractNumber(imgFile)
                img =  mpimg.imread(sourceDirectory + "/" + imgFile);
                imgSize <- img.shape
                
                ## TODO TO FINISH
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


skimage.filters.median(image[, selem, out, …])
skimage.filters.gaussian(image[, sigma, …])


if __name__ == "__main__":
    print "hello"