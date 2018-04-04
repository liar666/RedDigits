#!/usr/bin/env python

import numpy as np

from skimage import data, io, feature, filters
from skimage.morphology import label
from skimage.measure import regionprops

import matplotlib.image as mpimg
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

#image = data.coins()[0:95, 70:370]  # or any NumPy array!
image_src = mpimg.imread("/home/guillaume/dwhelper/Code/RedDigits/images/numbers_cleaned/1.png");
image = np.mean(image_src, -1); # trick to rgb2grey
image = filters.gaussian(image, sigma=2); # trying to merge parts of digit with bluring
image[image>.25] = 1;
image[image<.25] = 0;
plt.imshow(image, cmap=plt.cm.gray);
plt.show();


edges = feature.canny(image, sigma=1, low_threshold=None, high_threshold=None);
plt.imshow(edges, cmap=plt.cm.gray);
plt.show();


label_image = label(edges);
currentAxis = plt.gca();
for region in regionprops(label_image):
    # Draw rectangle around segmented coins.
    minr, minc, maxr, maxc = region.bbox;
    rect = mpatches.Rectangle((minc, minr), maxc-minc, maxr-minr,
                              fill=False, edgecolor='red', linewidth=2);
    currentAxis.add_patch(rect);

plt.show();
