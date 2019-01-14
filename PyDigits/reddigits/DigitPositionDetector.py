#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
The module that has utilities to detect the positions of the digits
Entry Point for Position Detection
"""

import sys   # To get commanline arguments

import numpy as np

from skimage import feature, filters  # data, io,
from skimage.morphology import label
from skimage.measure import regionprops

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


from DigitModel import DigitModel
from Utils import Utils

class DigitPositionDetector:

    """Detects multiple digits in a large image."""

    BASE_DIR    = "/home/guigui/GMCodes/RedDigits/"
    IMAGE_DIR   = BASE_DIR + "/images/"
    CLEANED_DIR = IMAGE_DIR + "/numbers_cleaned/"
    DETECT_DIR  = IMAGE_DIR + "/detectPosition/"

    def die(self):
        print("DigitDetector destroyed")

    def __init__(self, image):
        """Initializes the detector by loading the image (where to look for digits)"""
        self._imageOriginal = image
        self._imageProcessed = None
        self._detectedDigits = []

    def detect(self):
        self._imageProcessed = np.mean(self._imageOriginal, -1)                   # trick to rgb2grey
        self._imageProcessed = filters.gaussian(self._imageProcessed, sigma=1.04) # trying to merge parts of the digits by bluring
        mean = np.mean(self._imageProcessed)                                     # making image strict B&W
        self._imageProcessed[self._imageProcessed-mean >  1e-15] = 1
        self._imageProcessed[self._imageProcessed-mean <= 1e-15] = 0
        edges = feature.canny(self._imageProcessed, sigma=1, low_threshold=None, high_threshold=None)
        labels = label(edges)
        for region in regionprops(labels):
            minrow, mincol, maxrow, maxcol = region.bbox
            subImage = self._imageOriginal[minrow:maxrow, mincol:maxcol]
            self._detectedDigits.append(DigitModel(self._imageOriginal.shape, subImage, minrow, mincol, maxrow, maxcol))

    def displayImage(self):
        plt.imshow(self._imageOriginal)
        plt.show()

    def displayDetectedPositions(self):
        fig, ax = plt.subplots(1)
        plt.imshow(self._imageOriginal)
        for digit in self._detectedDigits:
            minx = digit.bbox["tl"][0]
            maxx = digit.bbox["br"][0]
            miny = digit.bbox["tl"][1]
            maxy = digit.bbox["br"][1]
            rect = mpatches.Rectangle((minx, miny), maxx-minx, maxy-miny,
                                      fill=False, edgecolor='blue', linewidth=2)
            ax.add_patch(rect)
        plt.show()

    def getDetectedDigits(self):
        return(self._detectedDigits)


if __name__ == "__main__":
    #image1 = CLEANED_DIR + "1.png"
    #image3 = CLEANED_DIR + "3.png"
    #image7 = CLEANED_DIR + "7.png"
    #imageComplete = DigitPositionDetector.DETECT_DIR + "/example_3.png"
    if len(sys.argv) != 2:
        print("USAGE: "+sys.argv[0]+" <image file where to look for digits>")
    else:
        imageCompleteFile = DigitPositionDetector.DETECT_DIR + "/example_3.png"
        imageComplete = Utils.readImage(imageCompleteFile)
        print("Loaded image ("+imageCompleteFile+")")
        positionDetector = DigitPositionDetector(imageComplete)
        positionDetector.displayImage()
        print("Detecting digits positions...")
        positionDetector.detect()
        positionDetector.displayDetectedPositions()

        print("Original image:")
        plt.imshow(positionDetector._imageOriginal)
        plt.show()

        print("Digit positions detected:")
        positionDetector.displayDetectedPositions()
        plt.show()
    
        print("Extracted digit subImage:")
        for digit in positionDetector.getDetectedDigits():
            plt.imshow(digit.subImage)
            plt.show()
