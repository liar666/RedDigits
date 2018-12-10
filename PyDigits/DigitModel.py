#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Class encapsulating Digits
"""

import matplotlib.pyplot as plt


class DigitModel:   
    
    """Models a single digit with its position in the larger image and its subImage"""
    
    def die(self):
        print("DigitModel destroyed")
    
    def __init__(self, subImage, minRow, minCol, maxRow, maxCol):
        """Initialize the position of the digit and its subImage"""
        self.subImage = subImage
        self.position = { 'tl':(minCol, minRow), 'br':(maxCol, maxRow) }
        self.guessedValue = None
        
    def display(self):
        plt.imshow(self.subImage)
        plt.show()