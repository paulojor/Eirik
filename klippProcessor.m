function [handles]=klippProcessor(hObject,handles)

%%
%cuts the avrTrace into his constituent blocks and packs them in the
    %3D-array cutTrace.
for i=1:length(handles.listCh)
    if handles.cutType==1
        [newTrace,newTime,~,~]=sax(handles.trace(1,:,i),handles.time,handles.protocol);
    else
        %in case the rapp logs are used for cutting:
        [newTrace,newTime,~,~]=sax2(handles.trace(1,:,i),handles.time,handles.protocol2);
    end
    for k=1:size(newTrace,1)
        for j=1:size(newTrace,2)
            handles.cutTrace(k,j,i)=newTrace(k,j); % x:blocks; y:datapoints; z:channels. 
        end
    end
    %clear newTrace;
end

%% cuts the individual blocks in the original data. 
handles.cutData=cell(1,size(handles.data,1));
handles.preData=cell(1,size(handles.data,1));
handles.postData=cell(1,size(handles.data,1));
for n=1:size(handles.data,1)
    for i=1:length(handles.listCh)
        if handles.cutType==1
            [newTrace,newTime,preTrace0,postTrace0]=sax(handles.data(n,:,i),handles.time,handles.protocol);
        else
            %in case the rapp logs are used for cutting:
            [newTrace,newTime,preTrace0,postTrace0]=sax2(handles.data(n,:,i),handles.time,handles.protocol2);
        end
            
        for k=1:size(newTrace,1),
            for j=1:size(newTrace,2),
                cutTrace(k,j,i)=newTrace(k,j); % x:blocks; y:datapoints; z:channels. 
            end
        end
        preTrace(:,:,i)=preTrace0;
        postTrace(:,:,i)=postTrace0;
        clear preTrace0 postTrace0;
    end
    handles.cutData{n}=cutTrace; % n:individual traces
    handles.preData{n}=preTrace;
    handles.postData{n}=postTrace;
end

handles.newTime=newTime;

%% finds the AP's.

if strcmp(handles.unitY,'V'),
    unitFactor=1000;
else
    unitFactor=1000000000000;
end

handles.AP=zeros(size(handles.data,1),handles.protocol.N,length(handles.listCh)); %three dimmensions: number of traces/number of blocks/number of channels.
treshold=str2double(get(handles.editTreshold,'String'))/unitFactor;
for n=1:size(handles.data,1)
    for k=1:handles.protocol.N
       for i=1:length(handles.listCh)
           trace=handles.cutData{n}(k,:,i);
           [handles.AP(n,k,i)]=APdetectorHM(trace,treshold);
       end
    end
end

%%
handles.cut=1; %warns the rest of the program that the data has been cut at least once.
set(handles.pushBatchPSP,'Enable','on');

[handles]=includerFcn(hObject,handles);

guidata(hObject, handles)
end