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
        self.position = { 'tl':(minCol, minRow), 'br':(maxCol, maxRow) }
        self.fuzzyPosition = self.computeFuzzyPosition(originalImageShape[0], originalImageShape[1], minRow, minCol, maxRow, maxCol)
        self.guessedValue = None
        
    def computeFuzzyPosition(self, originalImageWidth, originalImageHeight, minRow, minCol, maxRow, maxCol):
        """Position relative to the big picture : (Top/Bottom, Left/Right)"""
        fPos = "NO FUZZY POSITION"
        xCenter = maxCol-minCol
        yCenter = maxRow-minRow
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