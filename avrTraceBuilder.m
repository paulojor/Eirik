function [handles]=avrTraceBuilder(hObject,handles)
%extracts the average trace, ignoring NaN's and based on the list of included traces.

%%
rawdata=handles.data(handles.indexG).group(handles.indexP).rawdata;
include=handles.data(handles.indexG).group(handles.indexP).include;
AP=handles.data(handles.indexG).group(handles.indexP).AP;

[x,y,z]=size(rawdata);
newdata=nan(x,y,z);

for i=1:x,
    for j=1:z,
        if include(i,j),
            if get(handles.checkAPs,'Value'),
                    if ~AP(i,j),
                        newdata(i,:,j)=rawdata(i,:,j);
                    end
            else
                newdata(i,:,j)=rawdata(i,:,j);
            end
        end  
    end
end

handles.avrTrace=nanmean(newdata,1);
handles.newdata=newdata;

%% adjusts the baseline time according to the length of the trace. 

%if the total trace time is less than 1.5 seconds, than it sets the baseline
%periode to 200 ms. If longerm, than it is 0.95 seconds. 
if ~handles.normFlag %only makes this assumption if the baseline time was never changed. 
    totalTime=y*handles.data(handles.indexG).group(handles.indexP).intX;
    if totalTime<1.5
        handles.normTime=0.2;
        set(handles.editNorm,'String',num2str(handles.normTime*1000));
    else
        handles.normTime=0.95;
        set(handles.editNorm,'String',num2str(handles.normTime*1000));
    end
end


%% calculates the data for normalization. 
baseEnd=round(handles.normTime/handles.data(handles.indexG).group(handles.indexP).intX);

for k=1:size(rawdata,3),
    for i=1:size(rawdata,1),
       baseline=nanmean(nanmean(newdata(i,1:baseEnd,k))); 
       for j=1:size(rawdata,2),
           normdata(i,j,k)=rawdata(i,j,k)-baseline;
       end
    end
end

for k=1:size(newdata,3),
    for i=1:size(newdata,1),
       baseline=nanmean(nanmean(newdata(i,1:baseEnd,k))); 
       for j=1:size(newdata,2),
           newnormdata(i,j,k)=newdata(i,j,k)-baseline;
       end
    end
end

handles.normdata=normdata;
handles.newnormdata=newnormdata;
handles.avrNormTrace=nanmean(newnormdata,1);

guidata(hObject,handles);

end