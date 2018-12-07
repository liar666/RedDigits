#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Class encapsulating Digits
"""

import matplotlib.pyplot as plt


class DigitModel:
    subImage = None
    position = None
    guessedValue = None
    
    def __init__(self, subImage, minRow, minCol, maxRow, maxCol):
        self.subImage = subImage
        self.position = { 'tl':(minCol, minRow), 'br':(maxCol, maxRow) }
        
    def display(self):
        plt.imshow(self.subImage)
        plt.show()