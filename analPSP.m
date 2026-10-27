function [handles]=analPSP(hObject,handles)


[stimIndex]=findNearest(handles.time,handles.stimTime);
[endIndex]=findNearest(handles.time,handles.endTime);
[baselineIndex]=findNearest(handles.time,handles.baselineTime);
[baselineStartIndex]=findNearest(handles.time,handles.baselineTimeStart);
[artifactIndex]=findNearest(handles.time,handles.artifactTime+handles.stimTime);

%% calculating the baseline value. 
handles.baseline=mean(handles.trace(baselineStartIndex:baselineIndex),2);
handles.baselineSTD=std(handles.trace(baselineStartIndex:baselineIndex),0,2);

traceArea1=handles.trace-handles.baseline; %the line has to be baselined in order to get the right area under the curve. 

%% Normalization step.
if get(handles.checkNorm,'Value'),
   handles.trace2=handles.trace-handles.baseline; 
   handles.baseline=0;
else
   handles.trace2=handles.trace; 
end

%% filtering step.
if get(handles.radioFilterNone,'Value'),
    handles.traceF=handles.trace2;
elseif get(handles.radioFilterFlat,'Value'),
    handles.traceF=smooth(handles.trace2,str2double(get(handles.editWindow,'String')));
end

%% finding the peak and amplitude. 
[~,handles.peakIndex]=max(abs(handles.traceF(artifactIndex:endIndex)-handles.baseline));

handles.peakIndex=handles.peakIndex+artifactIndex-1;
handles.peakTime=handles.time(handles.peakIndex);
handles.peakValue=handles.traceF(handles.peakIndex);
handles.latencyPeak=handles.peakTime-handles.stimTime;

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
riseMin=str2double(get(handles.editRiseMin,'String'))/100;
riseMax=str2double(get(handles.editRiseMax,'String'))/100;

try
    [~,handles.preRiseTime,handles.preRiseValue]=pointFinderFcn(handles.traceF,handles.time,artifactIndex,handles.peakIndex,-1,handles.baseline,handles.amplitude,riseMin);
    [~,handles.postRiseTime,handles.postRiseValue]=pointFinderFcn(handles.traceF,handles.time,artifactIndex,handles.peakIndex,-1,handles.baseline,handles.amplitude,riseMax);
    handles.riseTime=handles.postRiseTime-handles.preRiseTime;
catch
    handles.riseTime=NaN;
end
%% Calculating Latency.
if get(handles.radioAmpMethod,'Value'),
    Fraction=str2double(get(handles.editAmpMethod,'String'))/100;
    try
        [~,handles.preLatencyTime,handles.preLatencyValue]=pointFinderFcn2(handles.traceF,handles.time,handles.peakIndex,artifactIndex,1,handles.baseline,handles.amplitude,Fraction);
        handles.latency=handles.preLatencyTime-handles.stimTime;
    catch
        handles.latency=NaN;
    end
elseif get(handles.radioSDMethod,'Value'),
    Fraction=str2double(get(handles.editSDMethod,'String'))*handles.baselineSTD/handles.amplitude;
    try
        [~,handles.preLatencyTime,handles.preLatencyValue]=pointFinderFcn2(handles.traceF,handles.time,handles.peakIndex,artifactIndex,1,handles.baseline,handles.amplitude,Fraction);
        handles.latency=handles.preLatencyTime-handles.stimTime;
    catch
        handles.latency=NaN;
    end
end
%% Calculating area under the curve after stimulus. 

%calculating the area under the curve:
handles.area=trapz(traceArea1(artifactIndex:endIndex));
handles.areaLine=handles.traceF(artifactIndex:endIndex);
handles.areaTime=handles.time(artifactIndex:endIndex);

%calculating area under the curve until first 0 crossing (until the end of
%the first wave)
handles.indexCrossing = zeroCrossing(handles.trace,handles.baseline,handles.peakIndex);
handles.area0cross=trapz(traceArea1(artifactIndex:handles.indexCrossing));
handles.area0Line=handles.traceF(artifactIndex:handles.indexCrossing);
handles.area0Time=handles.time(artifactIndex:handles.indexCrossing);

%%
guidata(hObject,handles);

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