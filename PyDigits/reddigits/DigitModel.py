#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Class encapsulating Digits
"""

import matplotlib.pyplot as plt


class DigitModel:
    RIGHT  = "RIGHT"
    LEFT   = "LEFT"
    TOP    = "TOP"
    BOTTOM = "BOTTOM"

    """Models a single digit with its position in the larger image and its subImage"""

    def die(self):
        print("DigitModel destroyed")

    def __init__(self, originalImageShape, subImage, minRow, minCol, maxRow, maxCol):
        """Initialize the position of the digit and its subImage"""
        self.subImage = subImage
        self.bbox = { 'tl':(minCol, minRow), 'br':(maxCol, maxRow) }
        self.center = (minCol+(maxCol-minCol)/2, minRow+(maxRow-minRow)/2)
        self.fuzzyPosition = self.computeFuzzyPosition(originalImageShape, self.center)
        self.guessedValue = None

    def computeFuzzyPosition(self, originalImageShape, center):
        """Position relative to the big picture : (Top/Bottom, Left/Right)"""
        fPos = "NO FUZZY POSITION"
        originalImageWidth  = originalImageShape[1]
        originalImageHeight = originalImageShape[0]
        xCenter = center[0]
        yCenter = center[1]
        if yCenter > originalImageHeight/2:
            fPos = DigitModel.BOTTOM
        else:
            fPos = DigitModel.TOP

        if xCenter > originalImageWidth/2:
            fPos += " " + DigitModel.RIGHT
        else:
            fPos += " " + DigitModel.LEFT
        return fPos

    def display(self):
        plt.imshow(self.subImage)
        plt.show()