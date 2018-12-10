#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Trains a DeepNN to recognize digits
"""

import os.path       # Check if (model) file already exists

##import numpy as np   # To manage data(frames)
import pandas as pd

from rpy2.robjects import pandas2ri         # To get data from R(Data files)
from rpy2.robjects.packages import importr

from sklearn.neural_network import MLPClassifier  # To train a MLP
from sklearn.metrics import confusion_matrix      # To evaluate the fitted model
from sklearn import __version__                   # To keep track of current SkLearn version for unloading model

from joblib import dump, load  # To store the model

class DigitValueDetector:
    
    """Trains a Classifier (ScikitLearn::MLP/Keras::DeepNet) to recognize single digits"""
    
    HOME = "/home/guigui/GMCodes/RedDigits/"
    TRAINSETS_DIR = HOME + "/trainsets/"
    MODELS_DIR = HOME + "/models/BlackAndRed/"
    TRAIN_TEST_SETS_FILENAME = TRAINSETS_DIR + "/BlackAndRed/splitted/train+testWhole.RData"

    def die(self):
        print("Trainer destroyed")
    
    def __init__(self):
        self.trainSet = None
        self.testSet  = None
        self.dataColumns  = None  # ("i1", ...., "i420")
        self.classColumns = None  # ("c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "cE", "cH", "cOTHER")
        self.classifier = None
        
    def loadDataSet(self, rDataFilename):
        pandas2ri.activate()
        base = importr('base')
        base.load(rDataFilename)
        self.trainSet = pandas2ri.ri2py_dataframe(base.mget('train')[0])
        self.testSet  = pandas2ri.ri2py_dataframe(base.mget('test')[0])
        self.dataColumns = [x for x in list(self.trainSet.columns) if x[0]=='i']
        self.classColumns = [x for x in list(self.trainSet.columns) if x[0]=='c']

    def getDataPart(self, dataSet):
        return(dataSet.loc[:, self.dataColumns])

    def getClassesPart(self, dataSet):
        return(dataSet.loc[:, self.classColumns])
        
    def buildClassifier(self, solvr, hidden):
        self.classifier = MLPClassifier(solver=solvr, alpha = 1e-5, hidden_layer_sizes = hidden, random_state = 1)

    def trainClassifier(self, trainSet):
        self.classifier.fit(self.getDataPart(trainSet), self.getClassesPart(trainSet))

    def testSingleInstance(self, instanceData):
        return(self.classifier.predict(instanceData.values.reshape(1,-1)))

    def testMultipleInstances(self, testSetData):
        return(pd.DataFrame(self.classifier.predict(testSetData), columns=self.classColumns))
        
    def convertProbas2Class(self, setClasses):
        return(setClasses.values.argmax(axis=1))
        
    def evaluate(self, testSet):
        preds = self.convertProbas2Class(self.testMultipleInstances(self.getDataPart(testSet)))
        groundTruth = self.convertProbas2Class(self.getClassesPart(testSet))
        return(confusion_matrix(groundTruth, preds))

    def saveModel(self, filename):
        dump(self.classifier, filename) 

    def loadModel(self, filename):
        self.classifier = load(filename) 

    def imageToFeatures(self, image):
        return(image.flatten) # TODO flatten matrix

def main():
    solver = 'lbfgs'
    hidden = (100, 50)

    t = DigitValueDetector()

    modelFilename = t.MODELS_DIR + "/sklearn_" + __version__ + "_mlp_" + solver + "_" + str(hidden) + ".joblib"

    ## Load the data
    t.loadDataSet(t.TRAIN_TEST_SETS_FILENAME)
    
    ## Get/Train+Save Model
    if os.path.isfile(modelFilename):
        t.loadModel(modelFilename)
    else:
        t.buildClassifier(solver, hidden)
        t.trainClassifier(t.trainSet)
        t.saveModel(modelFilename)

    ## Test / Evaluate model
    t.testSingleInstance(t.testSet.loc[1,t.dataColumns])
    t.testMultipleInstances(t.getDataPart(t.testSet))
    confMatrice = t.evaluate(t.testSet)
    print(confMatrice)


if __name__== "__main__":
       main()
