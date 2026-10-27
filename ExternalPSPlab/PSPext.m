function [dataFinal] = PSPext(varargin)

if nargin<2
    [FileName,PathName]= uigetfile({'*.mat'},'Select the data file to analyze');
    fullnameData=fullfile(PathName,FileName);
    [FileName,PathName]= uigetfile({'*.mat'},'Select the settings file');
    fullnameSettings=fullfile(PathName,FileName);   
    try
        load(fullnameData);
        load(fullnameSettings);
    catch
        error('Could not load the files');
    end
else
    if ~isstruct(varargin{1}) || ~isstruct(varargin{2}) %checks if the two inputs are both structures.
        disp('One or both of the inputs are not structures');
        return %stops the function.
    end
    PSPhandles=varargin{1};
    PSPsettings=varargin{2};
end


%%
plotFig=1; %1 for plotting the individual traces, 0 for not.
tic %starts the timer.
addpath(pwd);
set(0,'DefaultFigureVisible','off'); %turns off figure visibility.

if strcmp(PSPhandles.originProg,'KlippPSP')
    cutData=PSPhandles.cutData;
    cutTime=PSPhandles.cutTime;
    unitY=PSPhandles.unitY;
    listCh=PSPhandles.listCh;
end

motherfolder=pwd;
mainFolderName = uigetdir(pwd,'Choose the folder where you want to put your data.');
cd(mainFolderName);
[newCutData]=cutDataConverter(cutData); %converts structural organization. 
N=length(cutData)*length(newCutData); %N = Ntraces * Nblocks.
%converts the units:
handles.time=cutTime*1000; %the time input is given in 's', while the program handles in 'ms'. 
w=waitbar(0,'Analyzing the data'); %creates a waitbar.
n=0;
%creates a matrix that will contain the data:
dataFinal=nan(length(cutData),10,length(newCutData),size(newCutData{1},3)); 
%dimensions: Ntraces x statistical data(fields) x Nblocks x N channels.
for i=1:length(newCutData) %blocks
    if plotFig
        foldername=strcat('Block',num2str(i));
        mkdir(foldername);
        cd(foldername);
    end
    disp(strcat('Processing:','Block',num2str(i)));
    for j=1:size(newCutData{i},1) %traces
        n=n+1;
        for k=1:size(newCutData{i},3) %channels
            ID=strcat('Block',num2str(i),'_Trace',num2str(j),'_Ch',listCh{k});
            if strcmp(unitY,'V')
                handles.trace=newCutData{i}(j,:,k)*1000; %in mV.
            else
                handles.trace=newCutData{i}(j,:,k)*1000000000000; %in pA.
            end
            handles.unitY=unitY; 
            if ~all(isnan(handles.trace)) %check for empty traces. 
                try
                    [rowData]=plotterPSPext(handles,PSPsettings,ID,plotFig);
                    dataFinal(j,1:10,i,k)=rowData;
                    clear rowData;
                catch
                    disp(strcat('Skipped:',ID));
                end
            else
                dataFinal(j,1:10,i,k)=nan(1,10);
            end
        end
        waitbar(n/N,w,strcat('Analyzed:',num2str(n),'/',num2str(N))); %updates progress in waitbar. 
    end
    if plotFig,cd(mainFolderName),end
end
close(w); %closes the waitbar. 


set(0,'DefaultFigureVisible','on'); %turns back on figure visibility.

disp('Saving the data');
save('summary','dataFinal'); %saves a '*.mat' version of the analysis data. 
for k=1:size(dataFinal,4) %creates a excel file for each channel.
    if size(dataFinal,4)>1
        filenameExcel = strcat('summaryCh',num2str(listCh{k}),'.xlsx');
    else
        filenameExcel = 'summary.xlsx';
    end
    for i=1:size(dataFinal,3)
        T=array2table(dataFinal(:,:,i,k),'VariableNames',...
            {'PeakValue','Amplitude','ZScore','LatencyPeak','Latency','RiseTime','Halfwidth','Baseline','BaselineSD','Area'});
        writetable(T,fullfile(pwd,filenameExcel),'Sheet',strcat('Block',num2str(i)));
    end
    Delete_sheets_Excel(fullfile(pwd,filenameExcel),{'Sheet1','Sheet2','Sheet3'});  %To delete 3 sheets
end
cd(motherfolder);
toc %times the execution of the function. 

end