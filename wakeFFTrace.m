function [handles]=wakeFFTrace(hObject,handles)

if get(handles.toggleFinal,'Value')
    set(handles.toggleCut,'Enable','off');
    if get(handles.checkSelection,'Value')
        set(handles.sliderBlock,'Enable','on');
        set(handles.sliderBlock,'Min',1,'Max',handles.protocol.N,'SliderStep',[1/handles.protocol.N 0.10]);
        set(handles.editBlockN,'Enable','on');
        set(handles.editBlockN,'String',num2str(handles.block));
        set(handles.editNTrace,'Enable','off');
        set(handles.pushDown,'Enable','off');
        set(handles.pushUp,'Enable','off');
        set(handles.radioInc,'Enable','On');
        set(handles.radioExc,'Enable','On');
    else
        set(handles.sliderBlock,'Enable','off');
        set(handles.editBlockN,'Enable','off');
        set(handles.radioInc,'Enable','Off');
        set(handles.radioExc,'Enable','Off');
        set(handles.pushDown,'Enable','off');
        set(handles.pushUp,'Enable','off');
    end
else
    if get(handles.checkSelection,'Value')
        set(handles.toggleCut,'Enable','on');
        wakeSelectionBox(hObject,handles);
    else
        set(handles.toggleCut,'Enable','on');
        wakeSlider(hObject,handles); 
    end
end


guidata(hObject,handles);
end