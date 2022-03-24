function [spiketrain,spikeTime,frequencySoma, fi_SomaStart,fi_SomaMean, fi_SomaStable,SpikeTimeInterval, numSpikes] = analyseApFrequency(nNeurons,timeRange, vMembrane, dt)
lengthTimeRange = length(timeRange);
spiketrain =  zeros(nNeurons, lengthTimeRange);
    for iNeuron = 1:nNeurons
        [~, timeSIndx]=findpeaks(vMembrane(iNeuron,:),'MinPeakHeight',10);
        timeS = timeRange(timeSIndx);
         spikeTime{1,iNeuron} = timeS;
        SpikeTimeInterval{1,iNeuron} =(diff(timeS)); 
        frequencySoma{1,iNeuron} = 1./((diff(timeSIndx))*dt*10^(-3));
        numSpikes(1,iNeuron) = length(frequencySoma{1,iNeuron});
        spiketrain(iNeuron, timeSIndx) = 1 ;
        if ~isempty(frequencySoma{1, iNeuron})
            if  length(frequencySoma{1, iNeuron})>1
                fi_SomaStable(1,iNeuron) = (frequencySoma{1,iNeuron}(1,end));
            else 
                fi_SomaStable(1,iNeuron) = (frequencySoma{1,iNeuron}(1,1));
            end
             fi_SomaMean(1,iNeuron) = mean(frequencySoma{1,iNeuron});
            fi_SomaStart(1,iNeuron) = (frequencySoma{1,iNeuron}(1,1));
        else
            fi_SomaStable(1,iNeuron) = 0;
            fi_SomaStart(1,iNeuron) = 0;
            fi_SomaMean(1,iNeuron) = 0;
        end        
    end
end