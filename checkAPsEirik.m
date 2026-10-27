function checkAPsEirik(hObject,handles)

unitY=handles.data(handles.indexG).group(handles.indexP).unitY;
if strcmp(unitY,'V'),
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

if get(handles.checkAPs,'Value'),
    set(handles.editTreshAP,'Enable','On');
    tresh=str2double(get(handles.editTreshAP,'String'))/unitFactor; %converts from mV to V or pA to A.
    %loops for finding the traces containing APs:
    for i=1:length(handles.data),
        for j=1:length(handles.data(i).group),
            for k=1:size(handles.data(i).group(j).rawdata,1),
               for l=1:size(handles.data(i).group(j).rawdata,3), 
                   trace=handles.data(i).group(j).rawdata(k,:,l);
                   handles.data(i).group(j).AP(k,l)=APdetectorHM(trace,tresh);
%                    if handles.data(i).group(j).include(k,l), %it only inactivates the traces that were included to start with. 
%                        handles.data(i).group(j).include(k,l)=~APdetectorHM(trace,tresh); 
%                    end
                end
            end
        end
    end   
else 
    set(handles.editTreshAP,'Enable','Off');    
end

[handles]=updateListboxEirik(hObject,handles);

guidata(hObject,handles);

end