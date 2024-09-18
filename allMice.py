# -*- coding: utf-8 -*-
"""
Created on Wed Mar 27 08:11:52 2024

@author: rafiparker
"""
from PreProcess_Below import PreProcess_Below
import suppFig9
import os


path = ###### Path to Data ##########

relevantLabels = ['Snout','Center','TB'] # Labels to be used for angle calculation
arenaPixels = 800 #Single side of the box measured in pixels
arenaCm = 50 #Single side of the box measured in Cm
frameRate = 20 #Video framerate
cutoffProb = 0.7 #Labels without this confidence will be discarded
distanceThresh = 0.075 #Distance a mouse is required to move in one frame to count as moving
smoothingFactor = 3 #For smoothing over spurious frames of angle change
stimTimes = [1,4,5] #[stimulation on (min), stimulation off (min),totalvideolength (min)]
stimPattern = [2,5] #[light on (sec),light off(sec)]


#Changes these measures to frames
stimTimes = [i*60*frameRate for i in stimTimes]
stimPattern = [i*frameRate for i in stimPattern]
pixelLength = arenaCm/arenaPixels
groups = ['cont','msACR','raACR']

mice = []
for group in groups:
    allFiles = [i for i in os.listdir(path+group+'/') if i[-1]=='v']
    for file in allFiles:
        mouse = file.split('_')[0]
        dataPath = path+group+'/'+file
        
        single = PreProcess_Below(pixelLength,frameRate,cutoffProb,relevantLabels,stimTimes,\
                                         distanceThresh,mouse,stimPattern,smoothingFactor,group)
        single.importDLC(dataPath)
        single.cleanOutliers()
        single.distanceTraveled()
        single.turnAngle()
        single.alignOutliers()
        mice.append(single)

suppFig9.makePlots(mice,path=True)