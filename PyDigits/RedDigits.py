#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
First attempt at building a induction cooking plate's digits detector in python
"""

#import DigitModel as dimo
import DigitPositionDetector as dipo
import DigitValueDetector as dival

from sklearn import __version__                   # To keep track of current SkLearn version for unloading model


# TODO take te image name and model as arguments
def main():
    imageComplete3 = dipo.DigitPositionDetector.DETECT_DIR + "/example_3.png"
    posDect = dipo.DigitPositionDetector(imageComplete3)
    posDect.detect()
    digits = posDect.getDetectedDigits()
    
    valDect = dival.DigitValueDetector()
    solver = 'lbfgs'
    hidden = (100, 50)
    modelFilename = valDect.MODELS_DIR + "/sklearn_" + __version__ + "_mlp_" + solver + "_" + str(hidden) + ".joblib"
    valDect.loadModel(modelFilename);

    for digit in digits:
        digit.guessedValue = valDect.convertProbas2Class(valDect.testSingleInstance(valDect.imageToFeatures(digit.subImage)))
        ## TODO convert absolute pixel position to highlevel position
        print("Seen a "+ digit.guessedValue + " at " + digit.position)
    
if __name__ == "__main__":
    main()

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
