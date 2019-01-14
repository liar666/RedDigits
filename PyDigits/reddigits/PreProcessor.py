#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Preprocessing of images
"""

from skimage.transform import resize  # To resize images to feature size

import matplotlib.pyplot as plt    # for displaying images

from DigitPositionDetector import DigitPositionDetector
from Utils import Utils

class PreProcessor:

    TRAIN_WIDTH  = 10
    TRAIN_HEIGHT = 42

    def die(self):
        print("PreProcessor destroyed")

    def __init__(self):
        return

    @staticmethod
    def preprocessImage(image):
        """Finds the digit in the image (error if no/more-than-one) and returns the corresponding 1D array of features"""
        dpd = DigitPositionDetector(image)
        dpd.detect()
        detectedDigits = dpd.getDetectedDigits()
        if len(detectedDigits)<1:
            raise Exception("ERROR: could not find digits in image")
        elif len(detectedDigits)>1:
            print("WARNING: More than 1 digit detected => considering only the first")
        digitImage = detectedDigits[0].subImage
        return PreProcessor.imageToFeatures(digitImage)

    @staticmethod
    def imageToFeatures(image):
        """Resizes the image to PreProcessor.TRAIN_WIDTH/HEIGHT and returns the flattened (1D) array"""
        resized = resize(image, (PreProcessor.TRAIN_HEIGHT, PreProcessor.TRAIN_WIDTH),
                         mode='reflect', anti_aliasing=True)
        bandw = resized[:,:,0]
        return(bandw.flatten())


if __name__ == "__main__":
    HOME = "/home/guigui/GMCodes/RedDigits/"
    IMAGE_DIR = HOME + "/images/"
    ## Single digit image => expected result : feats + size(420)
    img = Utils.readImage(IMAGE_DIR + "/numbers_cleaned/0.png")
    feats = PreProcessor.imageToFeatures(img)
    print(feats)
    print(len(feats))
    ## Complete image => expected result : error multiple digits + feats + size(420)
    img = Utils.readImage(IMAGE_DIR + "/detectPosition/example_3.png")
    feats = PreProcessor.preprocessImage(img)
    plt.imshow(feats.reshape(PreProcessor.TRAIN_HEIGHT,PreProcessor.TRAIN_WIDTH), cmap= 'gray')
    plt.show()
    print(feats)
    print(len(feats))