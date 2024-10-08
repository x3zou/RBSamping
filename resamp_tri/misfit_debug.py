#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Jul 21 14:41:24 2024

@author: x3zou
"""

import numpy as np
#disp=np.loadtxt('model1.txt')
x=np.loadtxt('x.txt',delimiter=',')
#y=np.loadtxt('y.txt',delimiter=',')
x1=x.flatten()
x2=x.flatten(order='F')
#y=y.flatten()

#x=np.reshape(x,(482,902))
#y=np.reshape(y,(482,902))

#x=x.flatten(order='F')
#y=y.flatten(order='F')

#x=np.reshape(x,(482,902))
#y=np.reshape(y,(482.902))
