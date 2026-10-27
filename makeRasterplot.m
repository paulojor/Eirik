function makeRasterplot(hObject,handles)

%finds the piece of data:
data=handles.data(handles.indexG).group(handles.indexP).rawdata(:,:,handles.indexCh);
%checks for which trials are included or not.
includeArray=handles.data(handles.indexG).group(handles.indexP).include(:,handles.indexCh);
includeArray=logical(includeArray); 
data=data(includeArray,:);
time=1:size(data,2);
time=time*handles.data(handles.indexG).group(handles.indexP).intX*1000; %multiplied by 1000 because it is in ms.

Ntrials=size(data,1);
APtimes=cell(1,Ntrials);
for i=1:Ntrials
    [~,APlocs]=findpeaks(data(i,:),'MinPeakProminence',0.02);
    if ~isempty(APlocs)
        APtimes{i}=APlocs*handles.data(handles.indexG).group(handles.indexP).intX*1000; %multiplied by 1000 because it is in ms.
    end
end

figure;
hold on;
axis([time(1) time(end) 0 Ntrials])

for i=1:Ntrials
    for j=1:length(APtimes{i})
        plot([APtimes{i}(j) APtimes{i}(j)],[i-1 i],'k');
    end
end

end