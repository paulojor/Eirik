function [handles]=updateListboxEirik(hObject,handles)

%% Looks for the Group.

for i=1:size(handles.data,2),
    GroupName{i}=handles.data(i).groupname;
end

set(handles.listbox1,'String',GroupName);

handles.indexG=get(handles.listbox1,'Value');
if handles.indexG>length(GroupName),
    handles.indexG=1; 
end
set(handles.listbox1,'Value',handles.indexG);

%% Looks for the Protocol.

for i=1:size(handles.data(handles.indexG).group,2),
    listName{i}=handles.data(handles.indexG).group(i).name;
end

if isempty(listName),set(handles.listbox2,'String','...'), end;

set(handles.listbox2,'String',listName);

handles.indexP=get(handles.listbox2,'Value');
if handles.indexP>length(listName),
    handles.indexP=1; 
end
set(handles.listbox2,'Value',handles.indexP);


% %finds the number of the Channel for stimulation.
% handles.stimCh=NaN;
% if ~isempty(listName),
%     handles.stimCh=str2num(listName{handles.indexP}(end));
% end

%Writes how many sweeps there are. 
set(handles.textN,'String',strcat('n = ',num2str(size(handles.data(handles.indexG).group(handles.indexP).rawdata,1))));

%updates Inc Rast checkbox.
if handles.data(handles.indexG).group(handles.indexP).CS
    set(handles.checkIncRast,'Enable','Off');
else
    set(handles.checkIncRast,'Enable','On');
    if handles.data(handles.indexG).group(handles.indexP).rast
        set(handles.checkIncRast,'Value',1);
    else
        set(handles.checkIncRast,'Value',0);
    end
end


%% Looks for the Channel.

for i=1:size(handles.data(handles.indexG).group(handles.indexP).rawdata,3);
    handles.listCh{i}=num2str(handles.data(handles.indexG).group(handles.indexP).listCh(i));
end

if isempty(handles.listCh),set(handles.listbox3,'String','...'), end;

set(handles.listbox3,'String',handles.listCh);

handles.indexCh=get(handles.listbox3,'Value');
if handles.indexCh>length(handles.listCh),
    handles.indexCh=1; 
end
set(handles.listbox3,'Value',handles.indexCh);

%disp(handles.indexCh);

%sets the check box (only when all the chosen channels are checked on).
sumChCheck=0;
for i=1:length(handles.indexCh),
    sumChCheck=sumChCheck+handles.data(handles.indexG).group(handles.indexP).check(handles.indexCh(i));
end
if sumChCheck==length(handles.indexCh),
    set(handles.checkCheck,'Value',1);
else
    set(handles.checkCheck,'Value',0);
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

%% 
if get(handles.checkSelection,'Value'),
    [handles]=selectionModeEirik(hObject,handles);
else
    % Plots the graph.

    [handles]=avrTraceBuilder(hObject,handles); %extracts the average trace, ignoring NaN's and based on the list of included traces.
    time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX*1000; %in ms.
    unitY=handles.data(handles.indexG).group(handles.indexP).unitY;
    if strcmp(unitY,'V'),
        unitFactor=1000;
    else
        unitFactor=1000000000000;
    end
    
%     % handles the stimulation channel. 
%     if ~isnan(handles.stimCh),
%        traceStim=handles.avrTrace(1,:,handles.stimCh);
%        [tStim]=findStim(traceStim,time);
%     end

    axes(handles.axes1);
    cla;
    hold on;
    
    if get(handles.checkTraces,'Value'),
        if get(handles.checkNorm,'Value'),
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newnormdata,1),
                   if handles.data(handles.indexG).group(handles.indexP).CS
                       plot(time,handles.newnormdata(j,:,handles.indexCh(i))*unitFactor,'Color',colcode(i,:)); 
                   else
                       plot(time,handles.newnormdata(j,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
                   end
               end
           end 
        else
           for i=1:length(handles.indexCh),
               for j=1:size(handles.newdata,1),
                   if handles.data(handles.indexG).group(handles.indexP).CS
                       plot(time,handles.newdata(j,:,handles.indexCh(i))*unitFactor,'Color',colcode(i,:));
                   else
                       plot(time,handles.newdata(j,:,handles.indexCh(i))*unitFactor,'Color',lightCode(i,:));
                   end
               end
           end
        end
    end
    
    
    if ~handles.data(handles.indexG).group(handles.indexP).CS
        for i=1:length(handles.indexCh),
            if get(handles.checkNorm,'Value'),
                plot(time,handles.avrNormTrace(1,:,handles.indexCh(i))*unitFactor,'Color',colcode(i,:));
            else
                plot(time,handles.avrTrace(1,:,handles.indexCh(i))*unitFactor,'Color',colcode(i,:));
            end
        end
    end
    
%     %plots the stimulation lines, if requested. 
%     YStim=get(gca,'YLim');
%     if get(handles.checkStimTraces,'Value'),
%        for i=1:length(tStim),
%           plot([tStim(i) tStim(i)],[YStim(1) YStim(2)],'g');
%        end
%     end
%     
    xlabel('Time (ms)');
    if strcmp(unitY,'V'),
        ylabel('Membrane Potential (mV)');
    else
        ylabel('Membrane Current (pA)');
    end
end

guidata(hObject,handles);
        
end