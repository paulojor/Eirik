function [group]=CSGroupBuilder(filetree,infotree,Beginning,Ending,endian,fullname)
% builds the Current Steps data out of the raw *.dat file. 

[ProtInd,listName]=groupListerCS(filetree,infotree,Beginning,Ending);
[group]=groupAssemblerCS(ProtInd,listName,filetree,infotree,endian,fullname);

end


function [ProtInd,listName]=groupListerCS(filetree,infotree,Beginning,Ending)

% Looks for the Protocol.

%this part of the function finds the experiments where there are muøltiple
%sweeps (current step experiments, for example). The
%variable 'counter' gives you the number of multi-sweep experiments, while
%'ExpInd' gives the list of the positions of where they are in the tree. 
ExpInd=[];
counter=0;
for i=Beginning:Ending,
    if ~isempty(filetree{i,2}) && infotree{i,2}.SeNumbersw>1, %important: only takes the experiments with several sweeps.
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

function [group]=groupAssemblerCS(ProtInd,listName,filetree,infotree,endian,fullname)

if ~isempty(ProtInd) && ~isempty(listName), %checks to see if the input variables exist at all. 
    fh=fopen(fullname, 'r', endian); %opens the file.

    listProt=ProtInd{1}; %works if there is only one protocol used (ex.: Current Steps).
    group=struct('name',{},'rawdata',{},'intX',{},'unitY',{},'listCh',{},'include',{},'AP',{},'check',{},'CS',{}); %prealocates the group structure.
    counter=0;
    for i=1:length(listProt),
        counter=counter+1;
        SeNumberSweeps=infotree{listProt(i),2}.SeNumbersw;
        nDataPoints=infotree{listProt(i),4}.TrDataPoints;
        %short routine to check the number of channels:
        J=listProt(i)+1;
        nCh=1;
        listCh=infotree{listProt(i),4}.TrAmplIndex;
        while J<=size(filetree,1) && isempty(filetree{J,3}),
                J=J+1;
                listCh=[listCh infotree{listProt(i)+nCh,4}.TrAmplIndex];
                nCh=nCh+1;
        end
        %initiates the raw data:
        rawdata=NaN(SeNumberSweeps,nDataPoints,nCh);
        include=ones(size(rawdata,1),size(rawdata,3)); %rows = sweeps; columns = channels.
        
        intX=infotree{listProt(i),4}.TrXInterval;
        unitY=infotree{listProt(i),4}.TrYUnit;
        
        for j=1:SeNumberSweeps,
           index=listProt(i)+(j-1)*nCh;
           for k=1:size(rawdata,3),
               traceID=index+k-1;
               if traceID<size(infotree,1)+1 %to prevent crashing the program in case the expected nr of sweeps and the real number of sweeps mismatch.
                   [trace]=traceLoader(infotree,4,traceID,fh);
                   for l=1:length(trace),
                        rawdata(j,l,k)=trace(l);
                   end
                   if APdetectorHM(trace,0.02), %initial treshold set at 20 mV.
                       AP(j,k)=1;
                    else
                       AP(j,k)=0;
                   end
                   clear trace;
               end
           end   
        end
        group(i).name=strcat('CS_',num2str(counter)); %name of the group
        group(i).rawdata=rawdata; % the raw data
        group(i).intX=intX; %the minimal interval of the time axis.
        group(i).unitY=unitY; %Y axis unit.
        group(i).listCh=listCh; %the list of channels
        group(i).include=include; %the traces included (all by default)
        group(i).AP=AP; %which ones have APs or anomalies in them.
        group(i).check=zeros(1,length(listCh));
        group(i).CS=1; %marks the group as being a Current Steps protocol. 
        clear rawdata;
        
        [group(i)] = checkActiveChCS(group(i)); %this function cleans away the inactive channels.
    end
    
    fclose(fh); %closes the file.
else
    group=[];
end

end

function [AP]=APdetectorHM(trace,treshold)
%This function will give the output 0 if there is no AP's and 1 if there
%is. 

AP=0;
if max(trace)-min(trace)>treshold, %the absolute treshold is set to a 20 mV change.
    AP=1;
end

end

function [group] = checkActiveChCS(group)
%this function eliminates the tracers from inactive channels. 

i=length(group.listCh);

%the algorithm works backwards.
while i>0,
    if group.listCh(i)==0
       group.rawdata(:,:,i)=[];
       group.listCh(i)=[];
       group.AP(:,i)=[];
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





