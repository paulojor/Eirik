function exportTraceHM(hObject,handles)

[handles]=avrTraceBuilder(hObject,handles); %extracts the average trace, ignoring NaN's and based on the list of included traces.

time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX;

if get(handles.checkSelection,'Value'),
    if get(handles.checkNorm,'Value'), 
        for i=1:length(handles.indexCh),
            vector(1,:,i)=handles.normdata(handles.indexTrace,:,handles.indexCh(i));
        end
    else
        for i=1:length(handles.indexCh),
            vector(1,:,i)=handles.data(handles.indexG).group(handles.indexP).rawdata(handles.indexTrace,:,handles.indexCh(i));
        end 
    end
    listCh=handles.listCh(handles.indexCh);
    uisave({'time','vector','listCh'},'trace'); 
else
    if get(handles.checkTraces,'Value'),
        if get(handles.checkNorm,'Value'),
            for i=1:length(handles.indexCh),
                data(:,:,i)=handles.newnormdata(:,:,handles.indexCh(i));
                vector(1,:,i)=handles.avrNormTrace(1,:,handles.indexCh(i));
            end
        else
            for i=1:length(handles.indexCh),
                data(:,:,i)=handles.newdata(:,:,handles.indexCh(i));
                vector(1,:,i)=handles.avrTrace(1,:,handles.indexCh(i));
            end
        end
        
        includeList=NaN(size(data,1),size(data,3));
        APList=NaN(size(data,1),size(data,3));
        for i=1:length(handles.indexCh),
            includeList(:,i)=handles.data(handles.indexG).group(handles.indexP).include(:,handles.indexCh(i));
            APList(:,i)=handles.data(handles.indexG).group(handles.indexP).AP(:,handles.indexCh(i));
        end
        if get(handles.checkAPs,'Value'),
            included=includeList&APList;
        else
            included=includeList;
        end
            
        listCh=handles.listCh(handles.indexCh);
        uisave({'time','vector','data','listCh','included'},'trace');
    else
       if get(handles.checkNorm,'Value'),
            for i=1:length(handles.indexCh),
                vector(1,:,i)=handles.avrNormTrace(1,:,handles.indexCh(i));
            end
        else
            for i=1:length(handles.indexCh),
                vector(1,:,i)=handles.avrTrace(1,:,handles.indexCh(i));
            end
        end
        listCh=handles.listCh(handles.indexCh);
        uisave({'time','vector','listCh'},'trace'); 
    end
end

end


