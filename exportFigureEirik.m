function exportFigureEirik(hObject,handles)

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

%% 
[handles]=avrTraceBuilder(hObject,handles); %extracts the average trace, ignoring NaN's and based on the list of included traces.
time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX;

% % handles the stimulation channel. 
%     if ~isnan(handles.stimCh),
%        traceStim=handles.avrTrace(1,:,handles.stimCh);
%        [tStim]=findStim(traceStim,time);
%     end

figure;
hold on;

if get(handles.checkSelection,'Value'),
    if get(handles.checkTraces,'Value'),
        if get(handles.checkNorm,'Value'),
           for i=1:length(handles.indexCh),
               plot(time,handles.avrNormTrace(1,:,handles.indexCh(i))*1000,'Color',lightCode(i,:));
           end 
        else
           for i=1:length(handles.indexCh),
               plot(time,handles.avrTrace(1,:,handles.indexCh(i))*1000,'Color',lightCode(i,:));
           end
        end
    end

    for i=1:length(handles.indexCh),
        if get(handles.checkNorm,'Value'),
            plot(time,handles.normdata(handles.indexTrace,:,handles.indexCh(i))*1000);
        else
            plot(time,handles.data(handles.indexG).group(handles.indexP).rawdata(handles.indexTrace,:,handles.indexCh(i))*1000);
        end
    end
else
    if get(handles.checkTraces,'Value'),
        if get(handles.checkNorm,'Value'),
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newnormdata,1),
                   plot(time,handles.newnormdata(j,:,handles.indexCh(i))*1000,'Color',lightCode(i,:));
               end
           end 
        else
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newdata,1),
                   plot(time,handles.newdata(j,:,handles.indexCh(i))*1000,'Color',lightCode(i,:));
               end
           end
        end
    end

    for i=1:length(handles.indexCh),
        if get(handles.checkNorm,'Value'),
            plot(time,handles.avrNormTrace(1,:,handles.indexCh(i))*1000,'Color',colcode(i,:));
        else
            plot(time,handles.avrTrace(1,:,handles.indexCh(i))*1000,'Color',colcode(i,:));
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

xlabel('Time (s)');
ylabel('Membrane potential (mV)');

end
