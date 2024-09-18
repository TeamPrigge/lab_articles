import pandas as pd
import numpy as np

class PreProcess_Below:
    
    def __init__(self,pixelLength,frameRate,cutoffProb,relevantLabels,stimTimes,distanceThresh,mouse,stimPattern,smoothingFactor,group):
        self.pixelLength = pixelLength
        self.frameRate = frameRate
        self.cutoffProb = cutoffProb
        self.relevantLabels = relevantLabels
        self.stimTimes = stimTimes
        self.distanceThresh = distanceThresh
        self.mouse = mouse
        self.stimPattern = stimPattern
        self.smoothingFactor = smoothingFactor +1
        self.group = group
        
    def importDLC(self,path):
        DLCfile = pd.read_csv(path,skiprows=[0,2]).drop(['bodyparts'],axis=1)
        for col in DLCfile.columns:
            if col[-1] == '2':
                DLCfile = DLCfile.rename(columns={col:col[:-2]+'_prob'})
            elif col[-1] == '1':
                DLCfile = DLCfile.rename(columns={col:col[:-2]+'_y'})
            else:
                DLCfile = DLCfile.rename(columns={col:col+'_x'})
        self.DLCfile = DLCfile
    
    def cleanOutliers(self,broadcast=False):
        DLCfile=self.DLCfile
        relevantLabels = self.relevantLabels
        cutoffProb = self.cutoffProb
        
        allOutliers = []
        numOutliers = []
        cleanedDLC = DLCfile
        
        for label in relevantLabels:
            prob = np.array(DLCfile[label+'_prob'])
            outliers = np.where(prob<cutoffProb)[0]
            outliers = np.delete(outliers, np.where(outliers == 0))
            if len(outliers)>0:
                cleanedDLC[label+'_x'] = smoothOver(cleanedDLC[label+'_x'],outliers)
                cleanedDLC[label+'_y'] = smoothOver(cleanedDLC[label+'_y'],outliers)
            allOutliers = allOutliers + list(outliers)
            numOutliers.append(np.round(len(outliers)/len(prob),4)*100)
        
        snout = np.where(np.array(DLCfile['Snout_prob'])<cutoffProb)[0]
        lF = np.where(np.array(DLCfile['LF_prob'])<cutoffProb)[0]
        rF = np.where(np.array(DLCfile['RF_prob'])<cutoffProb)[0]
        rear = [g for g in snout if g in lF or g in rF]
        
        self.rear = rear
        self.cleanDLC = cleanedDLC
        self.allOutliers = allOutliers
        self.numOutliers = numOutliers
        if broadcast:
            return numOutliers
        else:
            return
    
    def distanceTraveled(self,broadcast=False):
        cleanedDLC = self.cleanDLC
        pixelLength = self.pixelLength
        frameRate = self.frameRate
        
        delta = []
        for frame in range(len(cleanedDLC.index)-1):
            if frame in self.rear:
                delta.append(0)
                continue
            xR = cleanedDLC['RH_x'].iloc[frame+1] - cleanedDLC['RH_x'].iloc[frame]
            yR = cleanedDLC['RH_y'].iloc[frame+1] - cleanedDLC['RH_y'].iloc[frame]
            xL = cleanedDLC['LH_x'].iloc[frame+1] - cleanedDLC['LH_x'].iloc[frame]
            yL = cleanedDLC['LH_y'].iloc[frame+1] - cleanedDLC['LH_y'].iloc[frame]
            
            rightHind = np.sqrt( np.power(xR,2) + np.power(yR,2))/(frame+1-frame)
            leftHind = np.sqrt( np.power(xL,2) + np.power(yL,2))/(frame+1-frame)
            
            if rightHind < 0.1 and leftHind <0.1:
                delta.append(0)
                continue
            deltaX = cleanedDLC['Center_x'].iloc[frame+1] - cleanedDLC['Center_x'].iloc[frame]
            deltaY = cleanedDLC['Center_y'].iloc[frame+1] - cleanedDLC['Center_y'].iloc[frame]
            delta.append( np.sqrt( np.power(deltaX,2) + np.power(deltaY,2))/(frame+1-frame))
        
        deltaCm = np.array(delta)*pixelLength

        outliersDist = np.where(deltaCm > (np.mean(deltaCm)+(3*np.std(deltaCm))))[0]
        deltaCm = smoothOver(deltaCm,outliersDist)
        deltaCm = np.append(deltaCm,deltaCm[-1])
        speedSec = deltaCm*frameRate
        
        self.distance = deltaCm
        self.speed = speedSec
        
        removed = [self.cleanDLC.index[i] for i in outliersDist]
        for column in [i for i in self.cleanDLC.columns if i[-1]!='b']:
            self.cleanDLC[column] = smoothOver(self.cleanDLC[column],removed)
        self.allOutliers = self.allOutliers +removed
        if broadcast:
            return deltaCm,speedSec
        else:
            return
    
    def turnAngle(self,broadcast=False):
        cleanedDLC = self.cleanDLC
        distanceCm = self.distance
        relevantLabels = self.relevantLabels
        distanceThresh = self.distanceThresh
    
        bodyparts = []
        for label in relevantLabels:
            bodyparts.append([cleanedDLC[label+'_x'],cleanedDLC[label+'_y']])
            
        left = [cleanedDLC['LH_x'],cleanedDLC['LH_y']]
        right = [cleanedDLC['RH_x'],cleanedDLC['RH_y']]
            
        theta,midPoint = getAngle(bodyparts[0],bodyparts[1],bodyparts[2])
        turnLeft,directionTurn = direction(midPoint,left,right)
        
        
        onlyMove = np.where(np.array(distanceCm) > distanceThresh)[0]
        thetaMove = np.array(theta)[onlyMove]
        if min(thetaMove)<90:
            minAngle = 90
        else:
            minAngle = min(thetaMove)
        sharpAngle = 175 - (175-minAngle)*0.65 #sharpest 35%
        mediumAngle = 175 - (175-minAngle)*0.25 #medium 40%
        
        angles = {'Sharp':sharpAngle,'Medium':mediumAngle,'Broad':175,'Minimum':minAngle}
        
        angleJudgements = [qualifyAngle(theta[i],turnLeft[i],\
                           distanceCm[i],sharpAngle,mediumAngle,distanceThresh)\
                           for i in range(len(theta))]
        
        angleJudgements = smoothAngle(angleJudgements,self.smoothingFactor,'Left')
        angleJudgements = smoothAngle(angleJudgements,self.smoothingFactor,'Right')
        
        self.theta = theta
        self.midPoint = midPoint
        self.direction = directionTurn
        self.angleJudgements = angleJudgements
        self.angleCategories = angles
        if broadcast:
            return angleJudgements
        else:
            return
        
    def alignOutliers(self,broadcast=False):
        index = self.cleanDLC.index
        stimTimes = self.stimTimes
        shiftTimes = []
        for time in stimTimes:
            diff = np.array(index)-time
            shiftTimes.append(np.where(abs(diff)==min(abs(diff)))[0][0])
        self.shiftTimes = shiftTimes
        if broadcast:
            return shiftTimes
        else:
                return
    
    
def smoothOver(coordinate,outliers):
    if len(outliers)==0:
        return coordinate
    go = True
    base = outliers[0]
    frames = 0
    while go:
        nextIn = base+1
        howMany = 1
        frames+=1
        if nextIn == len(coordinate):
            go = False
            break
        while nextIn in outliers and nextIn < len(coordinate)-1:
            frames+=1
            nextIn+=1
            howMany+=1
            
        before = coordinate[base-1]
        after = coordinate[nextIn]
        coordinate[base:nextIn] = np.linspace(before,after,howMany)
        
        if frames == len(outliers):
            go = False
            break
        else:
            base = outliers[frames]
    
    return coordinate

def getAngle(bodypart1:list,bodypart2:list,bodypart3:list):
    v1 = np.subtract(bodypart3,bodypart2)
    v2 = np.subtract(bodypart1,bodypart2)
    
    theta = []
    for frame in range(len(v1[0])):
        dot = np.dot(v2[:,frame],v1[:,frame])
        norm = np.linalg.norm(v2[:,frame])*np.linalg.norm(v1[:,frame])
        cosTheta = dot/norm
        theta.append(np.rad2deg(np.arccos(cosTheta)))
        
    midPoint = np.divide( np.add(bodypart1,bodypart3),2)
    return theta, midPoint

def direction(midPoint,left:list,right:list):
    
    turnLeft,turnRight = distance(midPoint,left,right)
    turnLeft,turnRight = distance(midPoint,left,right)
    moveLeft, moveRight = distance(midPoint[:,10:],np.array(left)[:,:-10],np.array(right)[:,:-10])
    
    moveLeft = np.append(moveLeft,turnLeft[-10:])
    moveRight = np.append(moveRight,turnRight[-10:])
    
    turnLeft = (turnLeft & moveLeft)
    turnRight = (turnRight & moveRight)
    
    directionTurn = ['Left' if i else 'Straight' for i in turnLeft]
    for i in range(len(turnRight)):
        if turnRight[i]:
            directionTurn[i] = 'Right'
    for i in range(len(directionTurn)-5):
        directionTurn
    
    return turnLeft, directionTurn

def distance(midpoint,leftList,rightList):
    diffLeft = np.subtract(midpoint,np.array(leftList))
    diffRight = np.subtract(midpoint,np.array(rightList))
    
    distLeft = np.sqrt(np.add(np.power(diffLeft[0],2),np.power(diffLeft[1],2)))
    distRight = np.sqrt(np.add(np.power(diffRight[0],2),np.power(diffRight[1],2)))
    
    turnLeft = (distLeft<distRight)
    turnRight = (distRight<distLeft)
    
    return turnLeft, turnRight

def qualifyAngle(theta,Left,distance,sharpAngle,mediumAngle,distanceThresh):
    if Left:
        direction = 'Left_'
    else:
        direction = 'Right_'
    if theta>175 or distance<distanceThresh:
        return 'Straight'
    elif theta > mediumAngle:
        return direction+'Broad'
    elif theta > sharpAngle:
        return direction+'Medium'
    else:
        return direction+'Sharp'
    
def smoothAngle(angleJudgements,smoothingFactor,direction):
    angleJudgements = np.array(angleJudgements)
    for judge in range(len(angleJudgements)-(smoothingFactor+1)):
        if angleJudgements[judge][:len(direction)] == direction and angleJudgements[judge+1]=='Straight':
            nextFew = angleJudgements[judge+1:judge+smoothingFactor]
            nextFew = [i[:len(direction)] for i in nextFew]
            if direction in nextFew:
                nextOne = np.where(np.array(nextFew)==direction)[0][-1]
                angleJudgements[judge+1:judge+nextOne+1] = angleJudgements[judge]
                judge+=nextOne
    return angleJudgements.tolist()
