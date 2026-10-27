function [data,fullname,loadStatus]=dataBuilderEirik

[FileName,PathName]= uigetfile({'*.dat;*.mat'},'Select the data file');
fullname=fullfile(PathName,FileName);
termination=FileName(end-2:end);
if strcmp(termination,'dat')
    [filetree,infotree,endian,~,~]=Vespucio(FileName,PathName);

    %% Looks for the Group.
    disp('Looking for experiment groups');
    counterG=0;
    GroupInd=[];
    for i=1:size(filetree,1),
        if ~isempty(filetree{i,1}),
            counterG=counterG+1;
            GroupInd=[GroupInd i];
        end
    end

    GroupIndEnd=[];
    if counterG>1,
        for i=1:counterG-1,
            GroupIndEnd=[GroupIndEnd GroupInd(i+1)-1];
        end
    end
    GroupIndEnd=[GroupIndEnd size(filetree,1)];

    GroupName=cell(1,counterG);
    for i=1:counterG
        GroupName{i}=filetree{GroupInd(i),1}; %lists the name of the experiment groups;
    end

    %% Loads the traces into structures (called 'group').
    for i=1:counterG
        disp(strcat('Building group_',num2str(i)));
        data(i).groupname=GroupName{i};
        disp('Building single sweep data');
        [ProtInd,listName]=groupLister(filetree,infotree,GroupInd(i),GroupIndEnd(i));
        [group]=groupAssembler(ProtInd,listName,filetree,infotree,endian,fullname);
        data(i).group=group;
        disp('Building current steps data');
        [groupCS]=CSGroupBuilder(filetree,infotree,GroupInd(i),GroupIndEnd(i),endian,fullname);
        data(i).CurrentSteps=groupCS;
        clear group ProtInd listName groupCS;
    end
    [data]=fusionGroups(data);
    loadStatus=1;
else
   load(fullname); 
   loadStatus=1;
end



end

function [ProtInd,listName]=groupLister(filetree,infotree,Beginning,Ending)

% Looks for the Protocol.

%this part of the function finds the experiments where there was only one
%sweep (so it excludes the current step experiments, for example). The
%variable 'counter' gives you the number of one-sweep experiments, while
%'ExpInd' gives the list of the positions of where they are in the tree. 
ExpInd=[];
counter=0;
for i=Beginning:Ending,
    if ~isempty(filetree{i,2}) && infotree{i,2}.SeNumbersw==1, %important: only takes the experiments with only one sweep.
        counter=counter+1;
        ExpInd=[ExpInd i];
    end
end

if counter>0,
    %this part of the function creates a list of names for the one sweep
    %experiments. The length of the 'ExpName' is equal to the value of the
    %'counter'.
    ExpName=cell(1,counter);
    for i=1:counter
        ExpName{i}=filetree{ExpInd(i),2};
    end

    %this part of the function creates a list 'listName' with the individual
    %names of the experiments. 
    listName{1}=ExpName{1};
    k=2;
    for i=2:counter
        nName=1;
        for j=1:length(listName)
            if strcmp(ExpName{i},listName{j})
                nName=0;
            end
        end
        if nName
            listName{k}=ExpName{i};
            k=k+1;
        end
    end

    %this part of the program looks for protocols that share the same name and
    %groups them. 

    ProtInd=cell(1,length(listName)); %in each element of the cell there will be a list of ExpInd.
    for i=1:length(listName)
        tempList=[];
       for j=1:length(ExpName),
          if strcmp(listName{i},ExpName{j}), %if there is a match between the protocol name and the experience name.
              tempList=[tempList ExpInd(j)];
          end
       end
        ProtInd{i}=tempList;
    end
else
   listName=[];
   ProtInd=[];
end

end

function [group]=groupAssembler(ProtInd,listName,filetree,infotree,endian,fullname)

if ~isempty(ProtInd) && ~isempty(listName),
    fh=fopen(fullname, 'r', endian); %opens the file.

    for i=1:length(ProtInd),
        listProt=ProtInd{i};
        [rawdata]=protocolSizeChecker(listProt,filetree,infotree); %creates the empty array.
        include=ones(size(rawdata,1),size(rawdata,3)); %rows = sweeps; columns = channels.
        AP=zeros(size(rawdata,1),size(rawdata,3)); %rows = sweeps; columns = channels.
        APtimes=cell(size(rawdata,1),size(rawdata,3)); %creates a cell structure that will contain the AP times.
        for j=1:length(listProt),
           index=listProt(j);
           listCh=[];
           intX=infotree{index,4}.TrXInterval;
           unitY=infotree{index,4}.TrYUnit;
           for k=1:size(rawdata,3),
               traceID=index+k-1;
               [trace]=traceLoader(infotree,4,traceID,fh);
               for l=1:length(trace),
                    rawdata(j,l,k)=trace(l);
               end
               if APdetectorHM(trace,0.02), %initial treshold set at 20 mV.
                   AP(j,k)=1;
               else
                   AP(j,k)=0;
               end
               listCh=[listCh infotree{traceID,4}.TrAmplIndex];
               %checks for AP's:
               [~,APlocs]=findpeaks(trace,'MinPeakProminence',0.02);
               if ~isempty(APlocs)
                   APtimes{j,k}=APlocs*intX; %in s.
               end
               clear trace;
           end   
        end
        group(i).name=listName{i}; %name of the group
        group(i).rawdata=rawdata; % the raw data
        group(i).intX=intX; %the minimal interval of the time axis.
        group(i).unitY=unitY; %Y axis unit.
        group(i).listCh=listCh; %the list of channels
        group(i).include=include; %the traces included (all by default)
        group(i).AP=AP; %which ones have APs or anomalies in them.
        group(i).APtimes=APtimes; %the times of the APs. 
        group(i).check=zeros(1,length(listCh));
        group(i).CS=0; %marks the group as not being a Current Steps protocol. 
        group(i).rast=0; %by default, this group will not be included as being exportabel for rast analysis. 
        clear rawdata;
        
        [group(i)] = checkActiveCh(group(i)); %this function cleans away the inactive channels.
    end

    fclose(fh); %closes the file.
else
    group=[];
end

end

function [rawdata]=protocolSizeChecker(listProt,filetree,infotree)

maxCh=0;
maxDataPoints=0;
for i=1:length(listProt)
   index=listProt(i);
   [nDataPoints,nCh]=sweepSizeChecker(index,filetree,infotree);
   if nDataPoints>maxDataPoints,
       maxDataPoints=nDataPoints;
   end
   if nCh>maxCh,
       maxCh=nCh;
   end
end

%creates an empty tridimensional array. 
rawdata=NaN(length(listProt),maxDataPoints,maxCh);

end

function [nDataPoints,nCh]=sweepSizeChecker(index,filetree,infotree)

%the first routine finds the number of channels.
i=index+1;
nCh=1;
while i<=size(filetree,1) && isempty(filetree{i,2}),
        i=i+1; nCh=nCh+1;
end

%finding the number of data points.
nDataPoints=infotree{index,4}.TrDataPoints;

end

function [AP]=APdetectorHM(trace,treshold)
%This function will give the output 0 if there is no AP's and 1 if there
%is. 

AP=0;
if max(trace)-min(trace)>treshold, %the absolute treshold is set to a 20 mV change.
    AP=1;
end

end

function [group] = checkActiveCh(group)
%this function eliminates the tracers from inactive channels. 

i=length(group.listCh);

%the algorithm works backwards.
while i>0,
    if group.listCh(i)==0
       group.rawdata(:,:,i)=[];
       group.listCh(i)=[];
       group.include(:,i)=[];
       group.AP(:,i)=[];
       group.check(i)=[];
    end
    i=i-1;
end

end

function [trace]=traceLoader(infotree,tracecol,traceID,fh)

% Disc format
    fmt=LocalFormatToString(infotree{traceID,tracecol}.TrDataFormat);
    % Always read into double
    readfmt=[fmt '=>double'];
    % Read the data - always casting to double
    fseek(fh, infotree{traceID,tracecol}.TrData, 'bof');
    [trace(1:infotree{traceID,tracecol}.TrDataPoints)]=...
    fread(fh, double(infotree{traceID,tracecol}.TrDataPoints), readfmt);

    trace(:)=trace(:)*infotree{traceID,tracecol}.TrDataScaler+infotree{traceID,tracecol}.TrZeroData;

end

function fmt=LocalFormatToString(n)
%--------------------------------------------------------------------------
switch n
    case 0
        fmt='int16';
    case 1
        fmt='int32';
    case 2
        fmt='single';
    case 3
        fmt='double';
end
return
end
