#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
HDF5 tests
"""

import numpy as np
arr = np.random.randn(1000)


import h5py

##### HDF5 write
with h5py.File('random.hdf5', 'w') as f:
    dset = f.create_dataset("default", data=arr)
    
##### HDF5 read
with h5py.File('random.hdf5', 'r') as f:
    data = f['default']