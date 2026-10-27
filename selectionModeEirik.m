function [handles]=selectionModeEirik(hObject,handles)

%% activates/deactivates the </> buttons.
if handles.indexTrace==1,
    set(handles.pushMinus,'Enable','Off');
 else
    set(handles.pushMinus,'Enable','On');
end 

if handles.indexTrace==size(handles.data(handles.indexG).group(handles.indexP).rawdata,1)
    set(handles.pushPlus,'Enable','Off');
elseif handles.indexTrace>size(handles.data(handles.indexG).group(handles.indexP).rawdata,1)
    handles.indexTrace=1;
    set(handles.pushMinus,'Enable','Off');
else
    set(handles.pushPlus,'Enable','On');
end

%% updates the counters.
set(handles.editNselected,'String',num2str(handles.indexTrace));
set(handles.textNTraces,'String',strcat('/',num2str(size(handles.data(handles.indexG).group(handles.indexP).rawdata,1))));

%% checks the include/exclude status. 
sumChInc=0;
for i=1:length(handles.indexCh),
    sumChInc=sumChInc+handles.data(handles.indexG).group(handles.indexP).include(handles.indexTrace,handles.indexCh(i));
end

if sumChInc==length(handles.indexCh),
    set(handles.radioInclude,'Value',1);
    set(handles.radioExclude,'Value',0);
else
    set(handles.radioInclude,'Value',0);
    set(handles.radioExclude,'Value',1);
end

%% color codes

Red=[1 0 0];
RedLight=[1 0.5 0.5];
Blue=[0 0 1];
BlueLight=[0.5 0.9 1];
Green=[0 0.5 0];
GreenLight=[0.2 0.8 0.2];
Black=[0 0 0];
Grey=[0.7 0.7 0.7];
colcode1=vertcat(Blue,Red,Green,Black); colcodeLight=vertcat(BlueLight,RedLight,GreenLight,Grey);
if length(handles.indexCh)>1,
    colcode=colcode1;
    lightCode=colcodeLight;
else 
    colcode=Blue;
    lightCode=Grey;
end


%% plots the line.
axes(handles.axes1);
cla;
hold on;
[handles]=avrTraceBuilder(hObject,handles); %extracts the average trace, ignoring NaN's and based on the list of included traces.
time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX*1000; %in ms.
unitY=handles.data(handles.indexG).group(handles.indexP).unitY;
if strcmp(unitY,'V'),
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

% % handles the stimulation channel. 
%     if ~isnan(handles.stimCh),
%        traceStim=handles.avrTrace(1,:,handles.stimCh);
%        [tStim]=findStim(traceStim,time);
%     end

if handles.data(handles.indexG).group(handles.indexP).CS
    if get(handles.checkNorm,'Value'),
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newnormdata,1),
                   plot(time,handles.newnormdata(j,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
               end
           end 
    else
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newdata,1),
                   plot(time,handles.newdata(j,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
               end
           end
    end
    
    for i=1:length(handles.indexCh),
        if get(handles.checkNorm,'Value'),
            plot(time,handles.normdata(handles.indexTrace,:,handles.indexCh(i))*unitFactor);
        else
            plot(time,handles.data(handles.indexG).group(handles.indexP).rawdata(handles.indexTrace,:,handles.indexCh(i))*unitFactor);
        end
    end
        
else
    if get(handles.checkTraces,'Value'),
        if get(handles.checkNorm,'Value'),
           for i=1:length(handles.indexCh),
               plot(time,handles.avrNormTrace(1,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
           end 
        else
           for i=1:length(handles.indexCh),
               plot(time,handles.avrTrace(1,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
           end
        end
    end
    
    for i=1:length(handles.indexCh),
        if get(handles.checkNorm,'Value'),
            plot(time,handles.normdata(handles.indexTrace,:,handles.indexCh(i))*unitFactor);
        else
            plot(time,handles.data(handles.indexG).group(handles.indexP).rawdata(handles.indexTrace,:,handles.indexCh(i))*unitFactor);
        end
    end
end




% %plots the stimulation lines, if requested. 
%     YStim=get(gca,'YLim');
%     if get(handles.checkStimTraces,'Value'),
%        for i=1:length(tStim),
%           plot([tStim(i) tStim(i)],[YStim(1) YStim(2)],'g');
%        end
%     end

xlabel('Time (ms)');
if strcmp(unitY,'V'),
    ylabel('Membrane Potential (mV)');
else
    ylabel('Membrane Current(pA)');
end


guidata(hObject,handles);
end