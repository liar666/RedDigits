#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd

from skimage.transform import SimilarityTransform, AffineTransform, warp, rotate, resize
from skimage.filters import gaussian

from Utils import Utils
from PreProcessor import PreProcessor

TRAIN_WIDTH = 10
TRAIN_HEIGHT = 42

tilt=-45
angle=45
xtransl=25
ytransl=10
sigma=.1
ratio = 1.4

number=2
newFile="/home/guigui/GMCodes/RedDigits/images/numbers_cleaned/"+str(number)+".png"
img = Utils.readImage(newFile)
Utils.showImage(img)

# quadruple image canvas size and center digit
scale=4
img2 = np.full((scale*img.shape[0],scale*img.shape[1],img.shape[2]), 0)
img2[:,:,3] = 255
imh, iml, imd = img.shape
im2h, im2l, im2d = img2.shape
midl, midh = int(iml/2), int(imh/2)
mid2l, mid2h = int(im2l/2), int(im2h/2)
img2[mid2h-midh:mid2h+midh, mid2l-midl:mid2l+midl, :] = img[0:midh*2, 0:midl*2, :]
print("orig="+str(np.mean(img2[:,:,0:3])))
Utils.showImage(img2)


tiltTform1 = SimilarityTransform(translation=(0, mid2h-midh))
#tiltTform2 = AffineTransform(shear=np.deg2rad(tilt))
tiltTform2 = AffineTransform(shear=np.deg2rad(20))
tiltTform3 = SimilarityTransform(translation=(-tilt/45*mid2l, -mid2h+midh))
tiltTform = tiltTform1 + tiltTform2 + tiltTform3
tilted = warp(img2, tiltTform, output_shape=img2.shape,
              mode='edge', #mode='constant', cval = 0,  ## TODO: 'constant'+cval, does not work!!!!
              preserve_range = True)
print("tilted="+str(np.mean(tilted[:,:,0:3])))
#Utils.showImage(tilted)

rotated = rotate(tilted, np.deg2rad(angle), 
                 mode='edge', # mode='constant',  cval = 0,
                 preserve_range = True);
print("rotated="+str(np.mean(rotated[:,:,0:3])))
#Utils.showImage(rotated)

transTform= AffineTransform(translation=(xtransl,ytransl))
transtd = warp(rotated, transTform, output_shape=rotated.shape,
               mode='edge', # mode='constant', cval = 0,
               preserve_range = True)
print("transl="+str(np.mean(transtd[:,:,0:3])))
#Utils.showImage(transtd)

blurred = transtd.copy()
blurred[:, :, 0] = gaussian(blurred[:, :, 0], sigma, preserve_range = True)
print("blurred="+str(np.mean(blurred[:,:,0:3])))
#Utils.showImage(blurred)

resized = resize(blurred, (ratio*blurred.shape[0],ratio*blurred.shape[1]),
                 anti_aliasing=True, preserve_range = True)
print("resized="+str(np.mean(resized[:,:,0:3])))
#Utils.showImage(resized)


print("Treating file: " + newFile)
attributes = pd.DataFrame(PreProcessor.preprocessImage(resized).reshape(1,TRAIN_WIDTH*TRAIN_HEIGHT))
attributes["class"] = number
print(type(attributes))
print(attributes.shape)
print(attributes)


###################

from DigitPositionDetector import DigitPositionDetector

dpd = DigitPositionDetector(resized)
dpd.detect()
detectedDigits = dpd.getDetectedDigits()
for dd in detectedDigits:
        dd.display()

###################

import numpy as np
def all_at_once(img, rotation, translation, scale, shear):
    allLinTransf = AffineTransform(scale=(scale,scale), rotation=np.deg2rad(rotation), translation=translation, shear=np.deg2rad(shear))
    #tf = tf_center + tf_augment + tf_uncenter
    img2 = warp(img, allLinTransf, order=1, preserve_range=True, mode='edge')
    return img2

Utils.showImage(img)
Utils.showImage(img2)
Utils.showImage(all_at_once(img2, angle, (xtransl,ytransl), ratio, tilt))

####################

from skimage import data, color
image = color.rgb2gray(data.astronaut())
print("orig="+str(np.mean(image[:,:])))
Utils.showImage(image)


tiltTform = AffineTransform(shear=np.deg2rad(tilt)) # , translation=(215*tilt/4, 0)
tilted = warp(image, tiltTform, output_shape=image.shape, mode='edge', preserve_range = True)
print("tilted="+str(np.mean(tilted[:,:])))
Utils.showImage(tilted)


transTform= AffineTransform(translation=(20,20))
transl = warp(image, transTform, output_shape=image.shape, mode='edge', preserve_range = True)
print("transl="+str(np.mean(transl[:,:])))
Utils.showImage(transl)





