function [handles]=baselineHandling(hObject,handles)

handles.stimTime=str2double(get(handles.editStimTime,'String'));
set(handles.editBaseline,'String',num2str(round(handles.stimTime*0.95),2));
handles.baselineTime=str2double(get(handles.editBaseline,'String'));
if handles.stimTimeN>1,
   set(handles.editStartBaseline,'String',num2str(round(handles.baselineTime-0.5),2));
else
   set(handles.editStartBaseline,'String',num2str(0)); 
end
if handles.stimTimeN<length(handles.stimTimeVector)
   set(handles.editEndTime,'String',num2str(round(handles.stimTimeVector(handles.stimTimeN+1)-0.05,2)));
else
   set(handles.editEndTime,'String',num2str(handles.time(end))); 
end
handles.endTime=str2num(get(handles.editEndTime,'String'));
handles.baselineTimeStart=str2double(get(handles.editStartBaseline,'String'));
if handles.baselineTime-handles.baselineTimeStart<length(handles.time)*0.01*(handles.time(2)-handles.time(1)),
    handles.baselineTimeStart=handles.baselineTime-length(handles.time)*0.01*(handles.time(2)-handles.time(1));
    set(handles.editStartBaseline,'String',num2str(round(handles.baselineTimeStart,2)));
end

guidata(hObject,handles);
end