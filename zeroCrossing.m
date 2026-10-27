function indexCrossing = zeroCrossing(trace,baseline,indexStartPoint)
%This function finds the index of the trace where the signal of the PSP
%reverts after the peak.

Ntrace=trace-baseline;
NFtrace=smooth(Ntrace,20); %important step to assure that the data is smoothed. It may introduce a slight delay. 

n=length(NFtrace);
indexCrossing=n; %last value set by default, in case vthere is no zero crossing after peak. 

for i=indexStartPoint:n-1
    if NFtrace(i)*NFtrace(i+1)<0
        indexCrossing=i;
    end
end

end