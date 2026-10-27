function [handles]=includerFcn(hObject,handles)

%% activates the ffTrace button.
set(handles.toggleFinal,'Enable','on');
set(handles.pushSave,'Enable','on');
set(handles.pushExportBlock,'Enable','on');
set(handles.pushExportAvr,'Enable','on');
set(handles.pushPSPone,'Enable','on');

%% builds the blocksets individually.
handles.finalData=cell(1,length(handles.cutData));
for i=1:length(handles.cutData),
    [x,y,z]=size(handles.cutData{i});
    finalTrace=nan(x,y,z);
    for j=1:x
        for k=1:z
            if handles.include(i,j,k) %decides if a trace should be included or not. 
                if get(handles.checkExcAPs,'Value') 
                    if ~handles.AP(i,j,k), %in case the AP detector is 'on'.
                        finalTrace(j,:,k)=handles.cutData{i}(j,:,k);
                    end
                else
                    finalTrace(j,:,k)=handles.cutData{i}(j,:,k);
                end
            end
        end
    end
    handles.finalData{i}=finalTrace;
    clear finalTrace;
end

%% reconstructs the average traces in each block. 
nBlocks=handles.protocol.N;
nPoints=length(handles.newTime);
[Ntrials,~,nCh]=size(handles.data);
handles.finalTrace=nan(nBlocks,nPoints,nCh);
for i=1:nBlocks
    datablock=nan(Ntrials,nPoints,nCh);
    for j=1:Ntrials
        for k=1:nCh
            datablock(j,:,k)=handles.finalData{j}(i,:,k);
        end
    end
    avrDatablock=nanmean(datablock,1);
    handles.finalTrace(i,:,:)=avrDatablock;
    clear avrDatablock;
end

%% calculates the average trace of all included blocks.
finalFinalTrace=nanmean(handles.finalTrace,1);
handles.ffTrace=nan(size(finalFinalTrace,2),size(finalFinalTrace,3));
for i=1:size(finalFinalTrace,3)
    handles.ffTrace(:,i)=finalFinalTrace(1,:,i);
end

%% reconstructs the "shoulder" blocks (pre- and post- trace).

nPointsPre=size(handles.preData{1},2);
nPointsPost=size(handles.postData{1},2);
handles.preFinalData=nan(Ntrials,nPointsPre,nCh);
handles.postFinalData=nan(Ntrials,nPointsPost,nCh);
for i=1:Ntrials
    for k=1:nCh
        if handles.includeShoulders(i,1,k)
            handles.preFinalData(i,:,k)=handles.preData{i}(:,:,k);
        end
        if handles.includeShoulders(i,2,k)
            handles.postFinalData(i,:,k)=handles.postData{i}(:,:,k);
        end
    end       
end
handles.avrPreFinalData=nanmean(handles.preFinalData,1);
handles.avrPostFinalData=nanmean(handles.postFinalData,1);

guidata(hObject,handles);
end