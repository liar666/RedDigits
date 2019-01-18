# -*- coding: utf-8 -*-

import numpy as np

from skimage import io  ## for reading images from FS
#import matplotlib.image as mpimg   # for loading images from files
#import matplotlib.pyplot as plt    # for displaying images

class Utils:

    @staticmethod
    def readImage(filename):
        return io.imread(filename);
        #return mpimg.imread(filename);

    @staticmethod
    def writeImage(image, filename):
        io.imsave(filename, image);
        #mpimg.imsave(filename, image)

    @staticmethod
    def showImage(image):
        io.imshow(image);
        #plt.imshow(image)
        #plt.show()

    @staticmethod
    def imageMean(image):
        return(np.mean(image[:,:,0:3]))
