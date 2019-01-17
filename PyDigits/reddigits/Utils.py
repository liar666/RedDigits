# -*- coding: utf-8 -*-

from skimage import io  ## for reading images from FS
#import matplotlib.image as mpimg   # for loading images from files


class Utils:

    @staticmethod
    def readImage(filename):
        return io.imread(filename);

    @staticmethod
    def writeImage(image, filename):
        io.imsave(filename, image);  # mpimg.imsave()

    @staticmethod
    def showImage(image):
        io.imshow(image);  # mpimg.imshow()
