function wakeSlider(hObject,handles)

if get(handles.toggleCut,'Value') || (handles.cut==1 && handles.cutType==2)
   set(handles.sliderBlock,'Enable','on');
   set(handles.sliderBlock,'Min',1,'Max',handles.protocol.N,'SliderStep',[1/(handles.protocol.N-1) 1/(handles.protocol.N-1)]);
   set(handles.sliderBlock,'Value',handles.block);
   set(handles.editBlockN,'Enable','on');
   set(handles.editBlockN,'String',num2str(handles.block));
   set(handles.toggleFinal,'Enable','on');
else
   set(handles.sliderBlock,'Enable','off');
   set(handles.editBlockN,'Enable','off'); 
end


guidata(hObject,handles);

end