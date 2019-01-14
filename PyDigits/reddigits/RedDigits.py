#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
First attempt at building a induction cooking plate's digits detector in python
3. Entry Point for Digit Position+Value Detection phase
"""

import sys    # To get commanline arguments

import pandas as pd # For DataFrames

#import matplotlib.pyplot as plt
#from sklearn import __version__                   # To keep track of current SkLearn version for unloading model

from DigitPositionDetector import DigitPositionDetector
from DigitValueDetector import DigitValueDetector
from PreProcessor import PreProcessor
from Utils import Utils

if __name__ == "__main__":
    if (len(sys.argv)!=3):
        print("USAGE: " + sys.argv[0] + " <image file> <model file>")
        sys.exit(1)
    else:
        #imageComplete = DigitPositionDetector.DigitPositionDetector.DETECT_DIR + "/example_3.png"
        imageCompleteFile = sys.argv[1]
        imageComplete = Utils.readImage(imageCompleteFile)
        posDect = DigitPositionDetector(imageComplete)
        posDect.detect()
        posDect.displayImage()
        digits = posDect.getDetectedDigits()

        valDect = DigitValueDetector()
        solver = 'lbfgs'
        hidden = (10, 5)
        #modelFilename = valDect.MODELS_DIR + "/sklearn_" + __version__ + "_mlp_" + solver + "_" + str(hidden) + ".joblib" # TODO argv[2]
        modelFilename = sys.argv[2]
        valDect.loadModel(modelFilename);

        for digit in digits:
            digitAsFeatures = pd.DataFrame(PreProcessor.imageToFeatures(digit.subImage))
            digit.guessedValue = valDect.convertProbas2Class(valDect.testSingleInstance(digitAsFeatures))
            digit.display()
            print("Seen a "+ str(valDect.convertValue2ClassName(digit.guessedValue)) + " at " + digit.fuzzyPosition + " " + str(digit.center))



## TODOs:
## 1. Preprocessing1
## Canny+ContourFinder + joindre les rectangles proches (<10% de la larg/haut?)
## 2a. Preprocessing2
## remove mean image from input image / reduce image to 28x28
## 2b. Preprocessing3
## GM: add [translation]/rotation/tilt/blur/resize?
## 3. Créer un modèle keras de forme suivante:
##  a - 5x5 convol ReLU  (=>8*28x28)
##  b - maxpool 2x2      (=>8*14x14)
##  d - 5x5 convol ReLU  (=>16*14x14)
##  e - maxpool 2x2      (=>16*7x7)
##  f - FC ReLU          (=>128)
##  f'- Dropout 50%
##  g - FC SoftMax       (probas classes: 10->12)
##  5 epochs? / batch size = 4->16

# https://machinelearningmastery.com/use-keras-deep-learning-models-scikit-learn-python/
# http://blog.fastforwardlabs.com/2016/02/24/hello-world-in-keras-or-scikit-learn-versus.html
