#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Sep 11 13:29:08 2022

@author: matthiasprigge
"""
import pandas as pd
import numpy as np
import math as math
import matplotlib.pyplot as plt
from scipy.spatial import distance
import sys
from scipy.spatial.distance import pdist 
#import deeplabcut as dlc

data = []
dist = []
temp_sq_x = []
temp_sq_y = []
temp = []

#np.array(stim_boutx)
#np.array(stim_bouty)

sampling_rate = 25 #frames per second
stim_on = 60 * sampling_rate # stimulation starts after 60s
stim_off = 240 * sampling_rate # stimulation stops after 235s


#File name container
file_path = '/Users/matthiasprigge/Dropbox/Matthias/Matthias/LIN/publication/2023/MsChR'
data_dir = '/Data/20220909/'
file_name_container = [
#'185_cont_2s_pulse_5s_pause_180secs_starting_at1mDLC_resnet_50_ChRs_134_135Sep10shuffle1_300000.csv',
#'185_20hz_2s_pulse_5s_pause_180secs_starting_at1mDLC_resnet_50_ChRs_134_135Sep10shuffle1_300000.csv',
#'184_cont_2s_pulse_5s_pause_180secs_starting_at1mDLC_resnet_50_ChRs_134_135Sep10shuffle1_300000',
#'184_20hz_2s_pulse_5s_pause_180secs_starting_at1mDLC_resnet_50_ChRs_134_135Sep10shuffle1_300000.csv'
]

file_path = '/Users/matthiasprigge/Dropbox/Matthias/Matthias/LIN/publication/2023/MsChR'
data_dir = '/Data/20230310/'
file_name_container = [
#'DAT_2209_TP185_2s_Blue_IIDLC_resnet50_ChRs_134_135Sep10shuffle1_300000.csv',
#'DAT 2209 TP185 2s BlueDLC_resnet50_ChRs_134_135Sep10shuffle1_300000.csv',
#'DAT 2209 TP185 2s RedIIDLC_resnet50_ChRs_134_135Sep10shuffle1_300000.csv',
'DAT 2209 TP185 2s RedIIIDLC_resnet50_ChRs_134_135Sep10shuffle1_300000.csv'
]

columns_names = ['bodyparts','coords']
for i in file_name_container:
    
    df = pd.read_csv(file_path + data_dir  + str(i),  header=[2])
    print(file_path+str(i))
    
    
    
    #experimental design add a cond columns to df
    #smapling rate - 25 FPS
    #60 sec 1500 samples: baseline
    #2s-stim ON; 5 sec stim OFF x 25 cycles
    #60 sec 1500 smaples: baseline 2
    
    #update experimental design 10032023
    #smapling rate - 25 FPS
    #60 sec 1500 samples: baseline
    #2s-stim ON; 10 sec stim OFF x 25 cycles
    #60 sec 1500 smaples: baseline 2
    condition=['baseline' for _ in range(df.shape[0])]
    cycle=np.zeros(df.shape[0])
    cycle[:]=np.nan
    ncycles=15
    cycle_len = 300 #in samples
    
    for icycle in range(ncycles):
        stim_on_idx=np.arange(1500+icycle*cycle_len,1500+icycle*cycle_len+50)
        stim_off_idx=np.arange(1500+icycle*cycle_len+50,1500+icycle*cycle_len+50+250)
        condition[stim_on_idx[0]:stim_on_idx[-1]+1] =['stimOn' for _ in 
                                                    range(len(stim_on_idx))]
        condition[stim_off_idx[0]:stim_off_idx[-1]+1]=['stimOff' for _ in 
                                                     range(len(stim_off_idx))]
        cycle[np.hstack((stim_on_idx,stim_off_idx))] = icycle
        print(len(condition))
    df['condition'] = condition
    df['cycle'] = cycle
    
    plt.figure()
    plt.plot(np.array(df['x.4'][1500:6000]),np.array(df['y.4'][1500:6000])) 
     #compute vecolcity on stimOn and stimOff per cycle
    v_on, v_off = np.zeros(ncycles),np.zeros(ncycles)
    for icycle in range(ncycles):
         idx_on = df[(df.condition=='stimOn') & (df.cycle==icycle)].index
         assert(len(idx_on)==50)
         x1_all=np.array(df['x.2'])[idx_on[:-1]]
         y1_all=np.array(df['y.2'])[idx_on[:-1]]
         x0_all=np.array(df['x.2'])[idx_on[1:]]
         y0_all=np.array(df['y.2'])[idx_on[1:]]
         d = np.array([pdist([[0,y0],[x1,y1]]) for x0,y0,x1,y1 in
                         zip(x0_all,y0_all,x1_all,y1_all)])
         v_on[icycle]=sum(d)/len(idx_on)
         if icycle < 15:
             plt.plot(x0_all,y0_all, color = 'red')
         
         idx_off = df[(df.condition=='stimOff') & (df.cycle==icycle)].index
         assert(len(idx_off)==250)
         x1_all=np.array(df['x.2'])[idx_off[:-1]]
         y1_all=np.array(df['y.2'])[idx_off[:-1]]
         x0_all=np.array(df['x.2'])[idx_off[1:]]
         y0_all=np.array(df['y.2'])[idx_off[1:]]
         d = np.array([pdist([[x0,y0],[x1,y1]]) for x0,y0,x1,y1 in
                         zip(x0_all,y0_all,x1_all,y1_all)])
         v_off[icycle]=sum(d)/len(idx_off)
     
   
       
     
    #plot
    plt.savefig(file_path + data_dir + 'trajector_first3.eps', format='eps')
    plt.figure()
    plt.boxplot([v_on,v_off])
    palette = ['r', 'g']
    xs =0.04
    for icycle in range(ncycles):
        plt.plot([1,2],[v_on[icycle],v_off[icycle]], color='k', linewidth = 1)
   
    plt.scatter(np.ones(len(v_on)),v_on, s = 80,alpha = 0.5)
    plt.scatter(np.ones(len(v_off))*2,v_off, s = 80, alpha = 0.5)
        
    plt.savefig(file_path + data_dir + 'box_plot.eps', format='eps')
        
    
    
    
  


