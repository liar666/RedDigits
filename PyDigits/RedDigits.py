#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
First attempt at building a induction cooking plate's digits detector in python
"""

import matplotlib.pyplot as plt


import Detector as dt

BASE_DIR    = "/home/guigui/GMCodes/RedDigits/"
IMAGE_DIR   = BASE_DIR + "/images/"
CLEANED_DIR = IMAGE_DIR + "/numbers_cleaned/"
DETECT_DIR  = IMAGE_DIR + "/detectPosition/"

#image1 = CLEANED_DIR + "1.png"
#image3 = CLEANED_DIR + "3.png"
#image7 = CLEANED_DIR + "7.png"
imageComplete3 = DETECT_DIR + "/example_3.png"

detector1 = dt.Detector(imageComplete3)
detector1.displayImage()
detector1.detect()
detector1.displayDetectedPositions()

plt.imshow(detector1.imageOriginal)
plt.show()

detector1.displayDetectedPositions()
plt.show()

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
