function wakeSelectionBox(hObject,handles)

statusSelection=get(handles.checkSelection,'Value');

if get(handles.toggleFinal,'Value')
    [handles]=wakeFFTrace(hObject,handles); 
else
    if statusSelection,
        set(handles.editNTrace,'Enable','On');
        set(handles.pushDown,'Enable','On');
        set(handles.pushUp,'Enable','On');
        set(handles.radioInc,'Enable','On');
        set(handles.radioExc,'Enable','On');
        wakeSlider(hObject,handles);
    else
        set(handles.editNTrace,'Enable','Off');
        set(handles.pushDown,'Enable','Off');
        set(handles.pushUp,'Enable','Off');
        set(handles.radioInc,'Enable','Off');
        set(handles.radioExc,'Enable','Off');
    end
end

guidata(hObject,handles);

end