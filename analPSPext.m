function [handles]=analPSPext(handles,PSPsettings)


[stimIndex]=findNearest(handles.time,PSPsettings.stimTime);
[endIndex]=findNearest(handles.time,PSPsettings.endTime);
[baselineIndex]=findNearest(handles.time,PSPsettings.baselineTime);
[baselineStartIndex]=findNearest(handles.time,PSPsettings.baselineTimeStart);
[artifactIndex]=findNearest(handles.time,PSPsettings.artifactTime+PSPsettings.stimTime);

%% calculating the baseline value. 
handles.baseline=mean(handles.trace(baselineStartIndex:baselineIndex),2);
handles.baselineSTD=std(handles.trace(baselineStartIndex:baselineIndex),0,2);

traceArea1=handles.trace-handles.baseline; %the line has to be baselined in order to get the right area under the curve. 

%% Normalization step.
if PSPsettings.checkNorm
   handles.trace2=handles.trace-handles.baseline; 
   handles.baseline=0;
else
   handles.trace2=handles.trace; 
end

%% filtering step.
if PSPsettings.radioFilterNone
    handles.traceF=handles.trace2;
elseif PSPsettings.radioFilterFlat
    handles.traceF=smooth(handles.trace2,str2double(PSPsettings.editWindow));
end

%% finding the peak and amplitude. 
[~,handles.peakIndex]=max(abs(handles.traceF(artifactIndex:endIndex)-handles.baseline));

handles.peakIndex=handles.peakIndex+artifactIndex-1;
handles.peakTime=handles.time(handles.peakIndex);
handles.peakValue=handles.traceF(handles.peakIndex);
handles.latencyPeak=handles.peakTime-PSPsettings.stimTime;

handles.amplitude=handles.peakValue-handles.baseline;
handles.ZScore=handles.amplitude/handles.baselineSTD;

%% finding Halfwidth.

try
    [~,handles.pre50Time,handles.pre50Value]=pointFinderFcn(handles.traceF,handles.time,artifactIndex,handles.peakIndex,-1,handles.baseline,handles.amplitude,0.5);
    [~,handles.post50Time,handles.post50Value]=pointFinderFcn(handles.traceF,handles.time,endIndex,handles.peakIndex,1,handles.baseline,handles.amplitude,0.5);
    handles.halfwidth=handles.post50Time-handles.pre50Time;
catch
    handles.halfwidth=NaN;
end

%% finding rise time.
riseMin=str2double(PSPsettings.editRiseMin)/100;
riseMax=str2double(PSPsettings.editRiseMax)/100;

try
    [~,handles.preRiseTime,handles.preRiseValue]=pointFinderFcn(handles.traceF,handles.time,artifactIndex,handles.peakIndex,-1,handles.baseline,handles.amplitude,riseMin);
    [~,handles.postRiseTime,handles.postRiseValue]=pointFinderFcn(handles.traceF,handles.time,artifactIndex,handles.peakIndex,-1,handles.baseline,handles.amplitude,riseMax);
    handles.riseTime=handles.postRiseTime-handles.preRiseTime;
catch
    handles.riseTime=NaN;
end
%% Calculating Latency.
if PSPsettings.radioAmpMethod
    Fraction=str2double(PSPsettings.editAmpMethod)/100;
    try
        [~,handles.preLatencyTime,handles.preLatencyValue]=pointFinderFcn2(handles.traceF,handles.time,handles.peakIndex,artifactIndex,1,handles.baseline,handles.amplitude,Fraction);
        handles.latency=handles.preLatencyTime-PSPsettings.stimTime;
    catch
        handles.latency=NaN;
    end
elseif PSPsettings.radioSDMethod
    Fraction=str2double(PSPsettings.editSDMethod)*handles.baselineSTD/handles.amplitude;
    try
        [~,handles.preLatencyTime,handles.preLatencyValue]=pointFinderFcn2(handles.traceF,handles.time,handles.peakIndex,artifactIndex,1,handles.baseline,handles.amplitude,Fraction);
        handles.latency=handles.preLatencyTime-PSPsettings.stimTime;
    catch
        handles.latency=NaN;
    end
end
%% Calculating area under the curve after stimulus. 

%calculating the area under the curve:
handles.area=trapz(traceArea1(artifactIndex:endIndex));
handles.areaLine=handles.traceF(artifactIndex:endIndex);
handles.areaTime=handles.time(artifactIndex:endIndex);

end

function [index,indexTime,indexValue]=pointFinderFcn(trace,time,goal,peak,direction,baseline,amplitude,fraction)

for i=peak:direction:goal,
    if abs(trace(i)-baseline)-abs(amplitude*fraction)<0,
        index=i+goal-1;
        indexTime=time(i);
        indexValue=trace(i);
        break
    end
end

end

function [index,indexTime,indexValue]=pointFinderFcn2(trace,time,goal,peak,direction,baseline,amplitude,fraction)

for i=peak:direction:goal,
    if abs(trace(i)-baseline)-abs(amplitude*fraction)>0,
        index=i+goal-1;
        indexTime=time(i);
        indexValue=trace(i);
        break
    end
end

end

function [index]=findNearest(time,timepoint)
%fining the nearest point in the time vector.

vector=abs(time-timepoint);
[~,index]=min(vector);

end