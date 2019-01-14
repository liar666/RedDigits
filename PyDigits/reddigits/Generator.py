#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tools to generate the training/test dataset
1. Entry Point for dataset Generation phase
"""

import sys    # To access commandline arguments

import pandas as pd # For DataFrames

from skimage.transform import AffineTransform, warp  ## for tilt-ing images

from PreProcessor import PreProcessor
from Utils import Utils

class Generator:

    """Generates the dataset from the simple digit images using data augmentation (tilt, rotate, translate, blur, zoom)"""

    HOME = "/home/guigui/GMCodes/RedDigits/"
    IMG_DIR = HOME + "/images/"
    DIGITS_SRCDIR = IMG_DIR + "/numbers_cleaned/"
    DIGITS_OUTDIR = IMG_DIR + "/numbers_transformed/"
    TRAINSET_OUTDIR = HOME + "/trainset/"

    tiltRange  = [t/10 for t in range(-4, 6+1, 2)]
    angleRange = range(-30, 30+1, 15)
    xTranslRange = [(x*PreProcessor.TRAIN_WIDTH)/10 for x in range(-4, 4+1, 2)]
    yTranslRange = [(y*PreProcessor.TRAIN_HEIGHT)/10 for y in range(-4, 4+1, 2)]
    blurRange = [s/10 for s in range(1, 21+1, 5)]
    zoomRange = [z/10 for z in range(6, 10+1, 1)]

    def die(self):
        print("Generator destroyed")

    def __init__(self):
        _dataSet = None
    
    @staticmethod
    def listFiles(dirname):
        files = []
        for (dirpath, dirnames, filenames) in walk(dirname):
            files = files + filenames # list(map(lambda x: dirpath+x, filenames))
        return(files)
    
    @staticmethod
    def extractNumber(filename):
        return filename[0]

    def generate(self, sourceDirectory):
        if dataSet == None:
            files = Generator.listFiles(self.DIGITS_SRCDIR)
            outDF = pd.DataFrame()
            for imgFile in files:
                outDF1Nb = pd.DataFrame()
                number = extractNumber(imgFile)
                img =  Utils.readImage(sourceDirectory + "/" + imgFile);
                # double image canvas and center digit
                transform = AffineTransform(scale=(2,2), translation=(-img.shape[1]/2,-img.shape[0]/2))
                img = warp(img, transform, output_shape=img.shape, mode='edge')
                imgSize = img.shape
                
                for tilt in Generator.tiltRange:
                    tiltTform = AffineTransform(shear=tilt, translation=(215*tilt/4, 0))
                    for angle in Generator.angleRange:
                        for xtransl in Generator.xTranslRange:
                            for ytransl in Generator.yTranslRange:
                                transTform= AffineTransform(translation=(xtransl,ytransl))
                                for sigma in Generator.blurRange:
                                    for ratio in Generator.zoomRange:
                                        zoomTform = AffineTransform(scale=(ratio,ratio), translation=(img.shape[1]/z/3-img.shape[1]/3,img.shape[0]/z/3-img.shape[0]/3))
                                        tilted   = warp(img, tiltTform, output_shape=img.shape, mode='edge')
                                        rotated  = rotate(tilted, angle, output_shape=img.shape, mode='edge');
                                        transtd  = warp(rotated, transTform, output_shape=img.shape, mode='edge')
                                        blured   = transtd.copy()
                                        blured[:, :, 0] = filters.gaussian(blured[:, :, 0], sigma, preserve_range = True)
                                        resized  =- warp(blured, zoomTform, output_shape=img.shape, mode='edge')
                                        
                                        newFile = Generator.DIGITS_OUTDIR + "/" + str(number) + \
                                         "_t" + str(tilt)  + "_r" + str(angle) + "_t" + str(xtransl) + "_" + str(ytransl) + \
                                         "_b" + str(sigma) + "_s" + str(ratio) + ".png")

                                        print("Writing image file: " + newFile)
                                        Utils.writeImage(resized, newFile)

                                        print("Treating file: " + newFile)
                                        attributes = PreProcessor.preprocessImage(resized)
                                        outDF1Nb = outDF1Nb.append(attributes, ignore_index=True)
                                        outDF1Nb["class"] = number
                write.csv(x=outDF1Nb, file=Generator.TRAINSET_OUTDIR + "/trainset_",number,".csv"), row.names = TRUE)
                outDF <- outDF.append(outDF1Nb, ignore_index=True)
            write.csv(x=outDF, file=Generator.TRAINSET_OUTDIR + "/trainset_full.csv", row.names = TRUE)
            self._dataSet = outDF

if __name__ == "__main__":
    print "hello"