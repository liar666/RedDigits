#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
First attempt at building a induction cooking plate's digits detector in python
"""

import numpy as np

from skimage import feature, filters  # data, io,
from skimage.morphology import label
from skimage.measure import regionprops

import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

#image = data.coins()[0:95, 70:370]  # or any NumPy array!
image_src = mpimg.imread("/home/guillaume/dwhelper/Code/RedDigits/images/numbers_cleaned/1.png")
#image_src = mpimg.imread("/home/guillaume/dwhelper/Code/RedDigits/images/numbers_cleaned/3.png")
#image_src = mpimg.imread("/home/guillaume/dwhelper/Code/RedDigits/images/numbers_cleaned/7.png")
image = np.mean(image_src, -1) # trick to rgb2grey
image = filters.gaussian(image, sigma=1.04) # trying to merge parts of digit with bluring
image[image-.25 > 1e-15] = 1
image[image-.25 <= 1e-15] = 0
plt.imshow(image, cmap=plt.cm.gray)
plt.show()


edges = feature.canny(image, sigma=1, low_threshold=None, high_threshold=None)
plt.imshow(edges, cmap=plt.cm.gray)
plt.show()


label_image = label(edges)
currentAxis = plt.gca()
for region in regionprops(label_image):
    # Draw rectangle around segmented coins.
    minr, minc, maxr, maxc = region.bbox
    rect = mpatches.Rectangle((minc, minr), maxc-minc, maxr-minr,
                              fill=False, edgecolor='red', linewidth=2)
    currentAxis.add_patch(rect)
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
