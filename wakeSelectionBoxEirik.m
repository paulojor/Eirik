function wakeSelectionBoxEirik(hObject,handles)

statusSelection=get(handles.checkSelection,'Value');

if statusSelection,
    set(handles.editNselected,'Enable','On');
    set(handles.pushMinus,'Enable','On');
    set(handles.pushPlus,'Enable','On');
    set(handles.radioInclude,'Enable','On');
    set(handles.radioExclude,'Enable','On');
else
    set(handles.editNselected,'Enable','Off');
    set(handles.pushMinus,'Enable','Off');
    set(handles.pushPlus,'Enable','Off');
    set(handles.radioInclude,'Enable','Off');
    set(handles.radioExclude,'Enable','Off');
end

guidata(hObject,handles);

end