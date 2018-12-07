#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
The module that has utilities to detect the positions of the digits
"""

import numpy as np

from skimage import feature, filters  # data, io,
from skimage.morphology import label
from skimage.measure import regionprops

import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


import DigitModel as dimo

class Detector:
    
    """Represents a digit detector."""
    
    imageFilename = "NO IMAGE FILENAME GIVEN"
    imageOriginal = None
    imageProcessed = None
    detectedDigits = []

    def die(self):
        print("Detector destroyed")
    
    def __init__(self, filename):
        """Initializes the detector with the filename of the image where to look for digits"""
        self.imageFilename = filename
        self.imageOriginal = mpimg.imread(self.imageFilename)
    
    def detect(self):
        self.imageProcessed = np.mean(self.imageOriginal, -1)                   # trick to rgb2grey
        self.imageProcessed = filters.gaussian(self.imageProcessed, sigma=1.04) # trying to merge parts of the digits by bluring
        mean = np.mean(self.imageProcessed)                                     # making image strict B&W
        self.imageProcessed[self.imageProcessed-mean >  1e-15] = 1
        self.imageProcessed[self.imageProcessed-mean <= 1e-15] = 0
        edges = feature.canny(self.imageProcessed, sigma=1, low_threshold=None, high_threshold=None)
        labels = label(edges)
        for region in regionprops(labels):
            minrow, mincol, maxrow, maxcol = region.bbox
            subImage = self.imageOriginal[minrow:maxrow][mincol:maxcol]
            self.detectedDigits.append(dimo.DigitModel(subImage, minrow, mincol, maxrow, maxcol))

    def displayImage(self):
        plt.imshow(self.imageOriginal)
        plt.show()
        
    def displayDetectedPositions(self):
        fig, ax = plt.subplots(1)
        plt.imshow(self.imageOriginal)
        for digit in self.detectedDigits:
            minx = digit.position["tl"][0]
            maxx = digit.position["br"][0]
            miny = digit.position["tl"][1]
            maxy = digit.position["br"][1]
            rect = mpatches.Rectangle((minx, miny), maxx-minx, maxy-miny,
                                      fill=False, edgecolor='red', linewidth=2)
            ax.add_patch(rect)
        plt.show()
