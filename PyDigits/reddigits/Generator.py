#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tools to generate the training/test dataset
1. Entry Point for dataset Generation phase
"""

##import sys    # To access commandline arguments
import os       # To "walk" (=list files) & create directories

import pandas as pd # For DataFrames

from skimage.transform import AffineTransform, warp, rotate  ## to modify images (tilt/rotate...) 
from skimage.filters import gaussian  ## for filtering (blur...) images

from PreProcessor import PreProcessor
from Utils import Utils

import numpy as np

class Generator:

    """Generates the dataset from the simple digit images using data augmentation (tilt, rotate, translate, blur, zoom)"""

    HOME = "/home/guigui/GMCodes/RedDigits/"
    IMG_DIR = HOME + "/images/"
    DIGITS_SRCDIR = IMG_DIR + "/numbers_cleaned/"
    DIGITS_OUTDIR = IMG_DIR + "/numbers_transformed/"
    TRAINSET_OUTDIR = HOME + "/trainsetsPy/"

    tiltRange  = [t/10 for t in range(-4, 6+1, 2)]
    angleRange = range(-30, 30+1, 15)
    xTranslRange = [(x*PreProcessor.TRAIN_WIDTH)/10 for x in range(-4, 4+1, 2)]
    yTranslRange = [(y*PreProcessor.TRAIN_HEIGHT)/10 for y in range(-4, 4+1, 2)]
    blurRange = [s/10 for s in range(1, 21+1, 5)]
    zoomRange = [z/10 for z in range(6, 10+1, 1)]

#    #### For testing
#    tiltRange  = [-.6]
#    angleRange = [-15]
#    xTranslRange = [-2]
#    yTranslRange = [-2*42/10]
#    blurRange = [.6]
#    zoomRange = [.7]

    def die(self):
        print("Generator destroyed")

    def __init__(self):
        self._dataSet = None
        self._dataColumns = ["i"+str(i) for i in range(0, PreProcessor.TRAIN_WIDTH*PreProcessor.TRAIN_HEIGHT)]
        self._classColumns = ["class"] #["c"+str(c) for c in range(0,9)] + ["cE", "cH"]

    @staticmethod
    def listFiles(dirname):
        files = []
        for (dirpath, dirnames, filenames) in os.walk(dirname):
            files = files + filenames # list(map(lambda x: dirpath+x, filenames))
        return(files)
    
    @staticmethod
    def extractNumber(filename):
        return filename[0]

    def generate(self):
        if self._dataSet == None:
            
            # Create outdirs
            if not os.path.exists(Generator.DIGITS_OUTDIR):
                os.makedirs(Generator.DIGITS_OUTDIR)
            if not os.path.exists(Generator.TRAINSET_OUTDIR):
                os.makedirs(Generator.TRAINSET_OUTDIR)
                
            # Treat all digit images found in source dir
            files = Generator.listFiles(Generator.DIGITS_SRCDIR)
            outDF = pd.DataFrame(data=[], columns=self._dataColumns+self._classColumns)
            for imgFile in files:
                outDF1Nb = pd.DataFrame(data=[], columns=self._dataColumns+self._classColumns)
                number = Generator.extractNumber(imgFile)
                img =  Utils.readImage(Generator.DIGITS_SRCDIR + "/" + imgFile);
                # double image canvas and center digit
                transform = AffineTransform(scale=(2,2), translation=(-img.shape[1]/2,-img.shape[0]/2))
                img = warp(img, transform, output_shape=img.shape, mode='edge')
                #imgSize = img.shape
               
                # Apply the modifications/augmentations on the digit image
                for tilt in Generator.tiltRange:
                    tiltTform = AffineTransform(shear=tilt, translation=(215*tilt/4, 0))
                    for angle in Generator.angleRange:
                        for xtransl in Generator.xTranslRange:
                            for ytransl in Generator.yTranslRange:
                                transTform= AffineTransform(translation=(xtransl,ytransl))
                                for sigma in Generator.blurRange:
                                    for ratio in Generator.zoomRange:
                                        #print(np.mean(img))
                                        zoomTform = AffineTransform(scale=(ratio,ratio), translation=(img.shape[1]/ratio/3-img.shape[1]/3,img.shape[0]/ratio/3-img.shape[0]/3))
                                        tilted   = warp(img, tiltTform, output_shape=img.shape, mode='edge')
                                        #print(np.mean(tilted))
                                        rotated  = rotate(tilted, angle, mode='edge');
                                        #print(np.mean(rotated))
                                        transtd  = warp(rotated, transTform, output_shape=img.shape, mode='edge')
                                        #print(np.mean(transtd))
                                        blured   = transtd.copy()
                                        blured[:, :, 0] = gaussian(blured[:, :, 0], sigma, preserve_range = True)
                                        #print(np.mean(blured))
                                        resized  =- warp(blured, zoomTform, output_shape=img.shape, mode='edge')
                                        print("resized="+str(np.mean(resized)))
                                        resized = -1*resized ## TODO: why does resize invert all the values?
                                        
                                        # Save the new image
                                        newFile = Generator.DIGITS_OUTDIR + "/" + str(number) + \
                                         "_t" + str(tilt)  + "_r" + str(angle) + "_t" + str(xtransl) + "_" + str(ytransl) + \
                                         "_b" + str(sigma) + "_s" + str(ratio) + ".png"
                                        print("Writing image file: " + newFile)
                                        #Utils.showImage(resized);
                                        Utils.writeImage(resized, newFile)

                                        print("Treating file: " + newFile)
                                        attributes = pd.DataFrame(PreProcessor.preprocessImage(resized).reshape(1,PreProcessor.TRAIN_WIDTH*PreProcessor.TRAIN_HEIGHT))
                                        attributes["class"] = number
#                                        print(attributes)
#                                        print(type(attributes))
#                                        print(attributes.shape)
                                        attributes.columns=outDF1Nb.columns
                                        outDF1Nb = outDF1Nb.append(attributes) # , ignore_index=True
                # Save the partial dataframe for the current digits (in case of crash, allows to restarts only on untreated digits)
                outDF1Nb.to_csv(Generator.TRAINSET_OUTDIR + "/trainset_" + number + ".csv");
                outDF = outDF.append(outDF1Nb, ignore_index=True)
            # Save the whole dataframe for all digits
            outDF.to_csv(Generator.TRAINSET_OUTDIR + "/trainset_full.csv")
            self._dataSet = outDF

if __name__ == "__main__":
    g = Generator()
    g.generate()