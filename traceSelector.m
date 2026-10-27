function [handles]=traceSelector(hObject,handles)

%% constructs a cell that only contains that data that is included. 
handles.newData=cell(1,size(handles.data,1));
[blocks,points,Ch]=size(handles.cutData{1});

for n=1:size(handles.data,1)
    newTrace=nan(blocks,points,Ch);
    for k=1:blocks,
       for i=1:Ch,
           if handles.include(n,k,i),
               if get(handles.checkAPs,'Value'),
                    if ~handles.AP(n,k,i),
                        newTrace(k,:,i)=handles.cutData{n}(k,:,i);
                    end
               else
                    newTrace(k,:,i)=handles.cutData{n}(k,:,i);
               end
           end
       end
    end
    handles.newData{n}=newTrace;
    clear newTrace
end

%% calculates the avrTrace of the newData.

handles.cutTrace=nan(blocks,points,Ch);% x:blocks; y:datapoints; z:channels.
for k=1:blocks
        for i=1:Ch
            newTrace=nan(length(handles.newData),points);
            for n=1:length(handles.newData)
                newTrace(n,:)=handles.cutData{n}(k,:,i);
            end
            handles.cutTrace(k,:,i)=nanmean(newTrace,1);
        end    
end
    


guidata(hObject, handles)
end