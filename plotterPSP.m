function [handles]=plotterPSP(hObject,handles)

[handles]=analPSP(hObject,handles);

figure(1)
lims = get(gca,{'xlim','ylim'});
cla;

%plots the original and the smoothed trace:
plot(handles.time,handles.trace2,'Color',[0.7 0.7 0.7]); %plots the original trace.
hold on;
plot(handles.time,handles.traceF,'b');

%plots the Peak.
if get(handles.checkPeak,'Value'),
    plot(handles.peakTime,handles.peakValue,'or');
end

%plots the Halfwidth.
if get(handles.checkHalfwidth,'Value') && ~isnan(handles.halfwidth),
   plot(handles.pre50Time,handles.pre50Value,'or');
   plot(handles.post50Time,handles.post50Value,'or');
end

%plots the Rise Time.
if get(handles.checkRiseTime,'Value') && ~isnan(handles.riseTime),
   plot(handles.preRiseTime,handles.preRiseValue,'or');
   plot(handles.postRiseTime,handles.postRiseValue,'or');
end

 %plots the Latency.
if get(handles.checkLatency,'Value') && ~isnan(handles.latency),
   plot(handles.preLatencyTime,handles.preLatencyValue,'or');
end 

%plots the time references:
YStim=get(gca,'YLim');
if ~isnan(handles.stimTime) && get(handles.checkStimulus,'Value'),...
        plot([handles.stimTime handles.stimTime],[YStim(1) YStim(2)],'g'), end;
if ~isnan(handles.endTime) && get(handles.checkEnd,'Value'),...
         plot([handles.endTime handles.endTime],[YStim(1) YStim(2)],'g'), end;

%plots the baseline.
if get(handles.checkBaseline,'Value'),
    plot([handles.baselineTimeStart handles.baselineTime],[handles.baseline handles.baseline],'g');
end

%plots the SD.
if get(handles.checkSD,'Value'),
    plot([handles.baselineTimeStart handles.baselineTime],[handles.baseline+handles.baselineSTD handles.baseline+handles.baselineSTD],'g');
    plot([handles.baselineTimeStart handles.baselineTime],[handles.baseline-handles.baselineSTD handles.baseline-handles.baselineSTD],'g');
end

%plots the artifact exclusion time. 
if get(handles.checkArtifact,'Value'),
    plot([handles.artifactTime+handles.stimTime handles.artifactTime+handles.stimTime],[YStim(1) YStim(2)],'g');
end

if lims{1}==[0 1] & lims{2}==[0 1]
else
    set(gca,{'xlim','ylim'},lims);
end

%plots the area under the curve.
if get(handles.checkArea,'Value')
    area(handles.areaTime,handles.areaLine);
end

%writes the axis units.
xlabel('Time (ms)');
if strcmp(handles.unitY,'V'),
    ylabel('Membrane Potential(mV)');
else
    ylabel('Membrane Current(pA)');
end

%% fills the result table.
set(handles.textPeakValue,'String',strcat('Peak Value:',num2str(round(handles.peakValue,2))));
set(handles.textAmplitude,'String',strcat('Amplitude:',num2str(round(handles.amplitude,2))));
set(handles.textZScore,'String',strcat('Z-Score:',num2str(round(handles.ZScore,2))));
set(handles.textLatencyPeak,'String',strcat('Lat Peak:',num2str(handles.latencyPeak)));
set(handles.textLatency,'String',strcat('Latency:',num2str(handles.latency)));
set(handles.textRiseTime,'String',strcat('Rise Time:',num2str(handles.riseTime)));
set(handles.textHalfwidth,'String',strcat('Halfwidth:',num2str(handles.halfwidth)));
set(handles.textBaseline,'String',strcat('Baseline:',num2str(round(handles.baseline,2))));
set(handles.textSD,'String',strcat('SD:',num2str(handles.baselineSTD)));
set(handles.textArea,'String',strcat('Area:',num2str(handles.area)));

guidata(hObject,handles);
end

