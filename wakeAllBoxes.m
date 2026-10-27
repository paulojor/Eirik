function wakeAllBoxes(hObject,handles)

if handles.loadStatus
    set(handles.checkNorm,'Enable','On');
    set(handles.checkSelection,'Enable','On');
    set(handles.checkSelection,'Value',0);
    set(handles.checkCheck,'Enable','On');
    set(handles.checkTraces,'Enable','On');
    set(handles.checkIncRast,'Enable','Off');
    set(handles.pushExpFig,'Enable','On');
    set(handles.pushExpTrace,'Enable','On');
    set(handles.pushSave,'Enable','On');
    set(handles.checkAPs,'Enable','On');
    set(handles.pushAnal,'Enable','On');
    set(handles.pushCut,'Enable','On');
    set(handles.pushRasterplot,'Enable','On');
    set(handles.pushRastExp,'Enable','On');
    wakeSelectionBoxEirik(hObject,handles);
else
    set(handles.checkNorm,'Enable','Off');
    set(handles.checkSelection,'Enable','Off');
    set(handles.checkSelection,'Value',0);
    set(handles.checkCheck,'Enable','Off');
    set(handles.checkTraces,'Enable','Off');
    set(handles.checkIncRast,'Enable','Off');
    set(handles.pushExpFig,'Enable','Off');
    set(handles.pushExpTrace,'Enable','Off');
    set(handles.pushSave,'Enable','Off');
    set(handles.checkAPs,'Enable','Off');
    set(handles.pushAnal,'Enable','Off');
    set(handles.pushCut,'Enable','Off');
    set(handles.pushRasterplot,'Enable','Off');
    set(handles.pushRastExp,'Enable','Off');
    wakeSelectionBoxEirik(hObject,handles);
end

guidata(hObject,handles);

end