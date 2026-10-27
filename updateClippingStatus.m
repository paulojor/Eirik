function updateClippingStatus(hObject,handles)
%updates the Clipping menu.

set(handles.editPreStart,'String',num2str(handles.protocol.preStart*1000));
set(handles.editDurBlock,'String',num2str(handles.protocol.durBlock*1000));
set(handles.editStimTime,'String',num2str(handles.protocol.stimTime*1000));
set(handles.editBaseline,'String',num2str(handles.protocol.baseline*1000));
set(handles.editNBlocks,'String',num2str(handles.protocol.N));

guidata(hObject,handles);
end