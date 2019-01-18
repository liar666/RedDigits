#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Class encapsulating Digits
"""

import matplotlib.pyplot as plt    # for displaying images

import numpy as np    # ªor arrays

from PIL import Image      # To tag the images
from PIL import ImageDraw 

from Utils import Utils

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
        self.fuzzyPosition = DigitModel.computeFuzzyPosition(originalImageShape, self.center)
        self.guessedValue = None

    def __str__(self):
        self.display()
        print("bbox = (" + str(self.bbox.tl) + ") -> (" + str(self.bbox.br) + ")")
        print("center = (" + str(self.center) + ")")
        print("fuzzyPos=" + self.fuzzyPosition)
        print("value=" + self.guessedValue)

    @staticmethod
    def tagImage(imgNP, tag, position, color=(255,255,255)):
        imgNP = np.uint8(imgNP*255)
        imgPIL = Image.fromarray(imgNP)
        draw = ImageDraw.Draw(imgPIL)
        draw.text(position, tag, color)
        return(np.array(imgPIL))

    @staticmethod
    def computeFuzzyPosition(originalImageShape, center):
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

    def getTaggedImage(self):
        img = self.subImage
        if self.guessedValue != None:
            img = DigitModel.tagImage(img, str(self.guessedValue), (self.subImage.shape[1]/2, 0))
        return(img)

    def display(self):
        plt.imshow(self.getTaggedImage())
        plt.show()


if __name__ == "__main__":
    HOME = "/home/guigui/GMCodes/RedDigits/"
    DIGIT_IMAGE_DIR = HOME + "/images/numbers_cleaned/"
    img = Utils.readImage(DIGIT_IMAGE_DIR + "0.png")
    digit = DigitModel((200,200), img, 10, 20 , 10+img.shape[1], 20+img.shape[0])
    digit.guessedValue = 0
    digit.display()
    plt.show()