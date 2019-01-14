#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
    Scratch pad
"""

#import os
import math    # for pi

import matplotlib.pyplot as plt   # For displaying images
from Utils import Utils

from skimage.transform import AffineTransform, rotate, warp  # For tilt-ing images
from skimage.filters import median, gaussian          # For blur-ing images

#import numpy as np
#import pandas as pd

TRAIN_WIDTH  = 10
TRAIN_HEIGHT = 42
    
HOME = "/home/guigui/GMCodes/RedDigits/"
DIGIT_IMAGE_DIR = HOME + "/images/numbers_cleaned/"

img = Utils.readImage(DIGIT_IMAGE_DIR + "0.png")
transform = AffineTransform(scale=(2,2), translation=(-img.shape[1]/2,-img.shape[0]/2))
img = warp(img, transform, output_shape=img.shape, mode='edge')
plt.imshow(img)
plt.show()


tiltRange  = [t/10 for t in range(-4, 6+1, 2)]
for tilt in tiltRange:
    transform = AffineTransform(shear=tilt, translation=(215*tilt/4, 0))
    img2 = warp(img, transform, output_shape=img.shape, mode='edge')
    plt.imshow(img2)
    plt.show()

#angleRange = range(-30, 30+1, 15)
#for angle in angleRange:
#    img3 = rotate(img, angle, mode='edge')
#    plt.imshow(img3)
#    plt.show()

#xTranslRange = [(x*TRAIN_WIDTH)/10 for x in range(-4, 4+1, 2)]
#yTranslRange = [(y*TRAIN_HEIGHT)/10 for y in range(-4, 4+1, 2)]
#for x in xTranslRange:
#    for y in yTranslRange:
#        transform = AffineTransform(translation=(x,y))
#        img4 = warp(img, transform, output_shape=img.shape, mode='edge')
#        plt.imshow(img4)
#        plt.show()

zoomRange = [z/10 for z in range(6, 10+1, 1)]
for z in zoomRange:
    transform = AffineTransform(scale=(z,z), translation=(img.shape[1]/z/3-img.shape[1]/3,img.shape[0]/z/3-img.shape[0]/3))
    img5 = warp(img, transform, output_shape=img.shape, mode='edge')
    plt.imshow(img5)
    plt.show()

blurRange = [s/10 for s in range(1, 21+1, 5)]
for b in blurRange:
    #img6 = median(img, b)
    im6 = img.copy()
    im6[:, :, 0] = gaussian(img[:, :, 0], b, preserve_range = True)
    plt.imshow(im6)
    plt.show()
