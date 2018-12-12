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

from sklearn.neural_network import MLPClassifier         # To train a MLP
from sklearn.metrics import confusion_matrix, f1_score   # To evaluate the fitted model
from sklearn import __version__                          # To keep track of current SkLearn version for unloading model

from skimage.transform import resize  # To resize images to feature size

from joblib import dump, load  # To store the model

class DigitValueDetector:
    
    """Trains a Classifier (ScikitLearn::MLP/Keras::DeepNet) to recognize single digits"""
    
    HOME = "/home/guigui/GMCodes/RedDigits/"
    TRAINSETS_DIR = HOME + "/trainsets/"
    MODELS_DIR = HOME + "/models/BlackAndRed/"
    TRAIN_TEST_SETS_FILENAME = TRAINSETS_DIR + "/BlackAndRed/splitted/train+testWhole.RData"

    TRAIN_WIDTH  = 10
    TRAIN_HEIGHT = 42

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
        rawOutput = self.classifier.predict_proba(instanceData.values.reshape(1,-1))
        dfOutput = pd.DataFrame(rawOutput, columns=self.classColumns)
        return(dfOutput)

    def testMultipleInstances(self, testSetData):
        rawOutput = self.classifier.predict_proba(testSetData)
        dfOutput = pd.DataFrame(rawOutput, columns=self.classColumns)
        return(dfOutput)
        
    def convertProbas2Class(self, setClasses):
        return(setClasses.values.argmax(axis=1))
        
    def evaluate(self, testSet):
        groundTruth = self.convertProbas2Class(self.getClassesPart(testSet))
        preds = self.convertProbas2Class(self.testMultipleInstances(self.getDataPart(testSet)))
        confMatrix = confusion_matrix(groundTruth, preds)
        f1Score = f1_score(groundTruth, preds, average='weighted')
        mlpScore = self.classifier.score(self.getDataPart(testSet), self.getClassesPart(testSet))
        return({ "ConfusionMatrix": confMatrix, "F1Score": f1Score, "MLPScore": mlpScore })

    def saveModel(self, filename):
        dump(self.classifier, filename) 

    def loadModel(self, filename):
        self.classifier = load(filename) 

    def imageToFeatures(self, image):
        resized = resize(image, (DigitValueDetector.TRAIN_HEIGHT, DigitValueDetector.TRAIN_WIDTH), mode='constant', anti_aliasing=True);
        bandw = resized[:,:,0]
        return(bandw.flatten())



if __name__== "__main__":
    solver = 'lbfgs'
    hidden = (100, 50)

    valueDetector = DigitValueDetector()

    modelFilename = valueDetector.MODELS_DIR + "/sklearn_" + __version__ + "_mlp_" + solver + "_" + str(hidden) + ".joblib"

    ## Load the data
    valueDetector.loadDataSet(valueDetector.TRAIN_TEST_SETS_FILENAME)
    print(">>> Data Set loaded")
    
    ## Get/Train+Save Model
    if os.path.isfile(modelFilename):
        valueDetector.loadModel(modelFilename)
        print(">>> Model (re)loaded from file ("+modelFilename+")")
    else:
        valueDetector.buildClassifier(solver, hidden)
        print(">>> Training model...")
        valueDetector.trainClassifier(valueDetector.trainSet)
        valueDetector.saveModel(modelFilename)
        print(">>> Model trained and saved")

    ## Test / Evaluate model
    print(">>> Testing single instance")
    siRes = valueDetector.testSingleInstance(valueDetector.testSet.loc[1,valueDetector.dataColumns])
    print(siRes)
    print(">>> Testing whole testSet")
    miRes = valueDetector.testMultipleInstances(valueDetector.getDataPart(valueDetector.testSet))
    print(miRes)
    print(">>> Evaluating model")
    print("*** TRAINSET EVALUATION ***")
    evalsTrain = valueDetector.evaluate(valueDetector.trainSet)
    print(evalsTrain['ConfusionMatrix'])
    print("train-set F1-score : " + evalsTrain['F1Score'])
    print("train-set MLP-score : " + evalsTrain['MLPScore'])
    print("*** TESTSET EVALUATION ***")
    evalsTest = valueDetector.evaluate(valueDetector.testSet)
    print(evalsTest['ConfusionMatrix'])
    print("test-set F1-score : " + evalsTest['F1Score'])
    print("test-set MLP-score : " + evalsTest['MLPScore'])
