import matplotlib.pyplot as plt
from matplotlib.collections import LineCollection
import numpy as np
import pandas as pd
from scipy.stats import mannwhitneyu


def makePlots(preprocessed,path=False):
    stimPattern = 0
    stimOn = []
    stimOff = []
    onTime = round(preprocessed[0].stimPattern[0])
    j = 0
    for i in preprocessed[0].stimTimes:
        while stimPattern<i:
            stimOn.append(stimPattern)
            stimPattern+=preprocessed[0].stimPattern[0]
            
            stimOff.append(stimPattern)
            stimPattern+=preprocessed[0].stimPattern[1]
        stimPattern = i
        
    dWhen = ['Before','During','After']
    stimOn = alignStimulation(preprocessed[0].cleanDLC.index,stimOn)
    stimOff = alignStimulation(preprocessed[0].cleanDLC.index,stimOff)
    
    trial = []
    whenChange = []
    second = 0
    for mouse in preprocessed:
        if path and mouse.mouse == 'ra1':
            if second==2:
                stimPath(mouse,stimOn)
                path=False
            second+=1
        moveCutoff = mouse.distanceThresh*mouse.frameRate
        j = 0
        i = 1
        while i < len(stimOn):
            if stimOn[i] >= mouse.shiftTimes[j]:
                whenChange.append((i)*3)
                j+=1
            before = np.median(mouse.speed[stimOn[i]-onTime:stimOn[i]])
            on = mouse.speed[stimOn[i]:stimOff[i]]
            offA = mouse.speed[stimOff[i]+onTime:stimOff[i]+(2*onTime)]
            if before > moveCutoff:
                trial.append(['Before',before,dWhen[j],mouse.group])
                trial.append(['On',np.median(on),dWhen[j],mouse.group])
                trial.append(['Off(A)',np.median(offA),dWhen[j],mouse.group])
            i+=1
        
    duringStim = pd.DataFrame(trial)
    duringStim.columns=['Stimulation','Speed Cm/Sec','Time','Group']
    duringStim = duringStim[duringStim['Time']=='During'].reset_index()
        
    xOrder = ['cont','msACR','raACR']    
    
    fig,ax = plt.subplots()
    ax.set_ylim(-0.4,20)
    ax.set_xlim(-0.5,2.5)
    ax.fill_between([0.1,0.3],-0.4,20,color='lightgray')
    ax.fill_between([1.1,1.3],-0.4,20,color='lightgray')
    ax.fill_between([2.1,2.3],-0.4,20,color='lightgray')
    ax.set_xticks([0,1,2])
    ax.set_xticklabels(xOrder)
        
        
    i = 0
    
    while i < len(duringStim):
        if duringStim['Group'][i]=='cont':
            xrange = np.linspace(-0.2,0.2,2)
        elif duringStim['Group'][i]=='msACR':
            xrange = np.linspace(.8,1.2,2)
        elif duringStim['Group'][i]=='raACR':
            xrange = np.linspace(1.8,2.2,2)
        ax.plot(xrange,duringStim['Speed Cm/Sec'][i:i+2],linestyle='--',linewidth=0.5,alpha=0.8,color='k')
        ax.scatter(xrange[0],duringStim['Speed Cm/Sec'][i],marker='o',color='gray',alpha=0.15)
        ax.scatter(xrange[0],duringStim['Speed Cm/Sec'][i],marker='o',facecolors='none',edgecolors='lightgray')
        ax.scatter(xrange[1],duringStim['Speed Cm/Sec'][i+1],marker='o',color='lightcoral',alpha=0.15)
        ax.scatter(xrange[1],duringStim['Speed Cm/Sec'][i+1],marker='o',facecolors='none',edgecolors='lightcoral')
        i+=3

    i = 0
    k= 0
    for group in xOrder:
        if group == 'raACR':
            k=1
        Ba = duringStim[duringStim['Group']==group][duringStim['Stimulation']=='Before'].mean(numeric_only=True)[1]
        Oa = duringStim[duringStim['Group']==group][duringStim['Stimulation']=='On'].mean(numeric_only=True)[1]
        Bs = duringStim[duringStim['Group']==group][duringStim['Stimulation']=='Before'].std(numeric_only=True)[1]/np.sqrt(2+k)
        Os = duringStim[duringStim['Group']==group][duringStim['Stimulation']=='On'].std(numeric_only=True)[1]/np.sqrt(2+k)
        
        ax.plot([-0.3+i,-0.1+i],[Ba,Ba],color='k',linewidth=2)
        ax.plot([0.1+i,0.3+i],[Oa,Oa],color='k',linewidth=2)
        ax.plot([-0.2+i,-0.2+i],[Ba-Bs,Ba+Bs],color='k',linewidth=2)
        ax.plot([0.2+i,0.2+i],[Oa-Os,Oa+Os],color='k',linewidth=2)
        
        p = mannwhitneyu(duringStim[duringStim['Group']==group][duringStim['Stimulation']=='Before']['Speed Cm/Sec'],\
                     duringStim[duringStim['Group']==group][duringStim['Stimulation']=='On']['Speed Cm/Sec'])[1]
        if p < 0.0001:
            ax.text(i,18,'****')
        elif p < 0.001:
            ax.text(i,18,'***')
        elif p < 0.01:
            ax.text(i,18,'**')
        elif p < 0.05: 
            ax.text(i,18,'*')
        else:
            ax.text(i,18,'ns')
        i+=1
    
    return fig

def stimPath(preprocessed,stimOn):
    start = preprocessed.shiftTimes[0]+(140*5)
    finish = stimOn[np.where(np.array(stimOn)==start)[0][0]+5]
    stims = stimOn[np.where(np.array(stimOn)==start)[0][0]:np.where(np.array(stimOn)==finish)[0][0]]
    stims = np.array(stims)-start
    
    
    mini = min(preprocessed.speed[start:finish])
    ran = max(preprocessed.speed[start:finish]) - mini
    
    
    speed = np.convolve((preprocessed.speed[start:finish]-mini)/ran, np.ones(5)/5, mode='full')
    
    colorMap = plt.cm.plasma(speed)
    
    pathX = list(preprocessed.cleanDLC['Center_x'][start:finish])
    pathY = list(preprocessed.cleanDLC['Center_y'][start:finish])
    pathY = [0-coor for coor in pathY]
    segs = [[(pathX[i],pathY[i]),(pathX[i+1],pathY[i+1])] for i in range(len(pathX)-1)]
    line_segments = LineCollection(segs,linestyles='solid',colors=colorMap[:-1])
    
    ylen = np.linspace(-800,-50,256)
    cbsegs = [[(820,i),(870,i)] for i in ylen]
    gradient = np.linspace(0, 1, 256)
    cb_segments = LineCollection(cbsegs,linestyles='solid', colors =plt.cm.plasma(gradient))
    
    
    fig,ax = plt.subplots()
    ax.set_xlim(120,940)
    ax.set_ylim(-840, -10)
    ax.add_collection(line_segments)
    ax.add_collection(cb_segments)
    ax.axis('off')
    for stim in stims:
        xrange = np.array(pathX[stim:stim+30])
        yrange = np.array(pathY[stim:stim+30])
        ax.fill_between(xrange,yrange,yrange+25,color='r',alpha=0.3)
        ax.fill_between(xrange,yrange,yrange-25,color='r',alpha=0.3)
    ax.text(880,-80,str(int(max(preprocessed.speed[start:finish]))))
    ax.text(880,-800,str(int(min(preprocessed.speed[start:finish]))))
    ax.text(890,-560,'Speed (Cm/Sec)',rotation=270)
    return fig

def alignStimulation(index,stimTimes):
    shiftTimes = []
    for time in stimTimes:
        diff = np.array(index)-time
        shiftTimes.append(np.where(abs(diff)==min(abs(diff)))[0][0])
    return shiftTimes