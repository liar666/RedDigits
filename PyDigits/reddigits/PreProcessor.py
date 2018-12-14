#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preprocessing of images
"""

from skimage.transform import resize  # To resize images to feature size

import matplotlib.image as mpimg

class PreProcessor:

    TRAIN_WIDTH  = 10
    TRAIN_HEIGHT = 42

    def xxx():
        return
    
    @staticmethod
    def imageToFeatures(image):
        resized = resize(image, (PreProcessor.TRAIN_HEIGHT, PreProcessor.TRAIN_WIDTH),
                         mode='reflect', anti_aliasing=True)
        bandw = resized[:,:,0]
        return(bandw.flatten())
        
        
if __name__ == "__main__":
    HOME = "/home/guigui/GMCodes/RedDigits/"
    DIGIT_IMAGE_DIR = HOME + "/images/numbers_cleaned/"
    img = mpimg.imread(DIGIT_IMAGE_DIR + "0.png")
    feats = PreProcessor.imageToFeatures(img)
    print(feats)