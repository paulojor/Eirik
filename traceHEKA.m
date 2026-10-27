function [data,time]=traceHEKA(datafile,endian,tracenumber,tree)

fh=fopen(datafile, 'r', endian);

%this program works both with the original sigTool tree from ImportHEKA.m and the overview
%tree created by OverviewHEKA.m
tracecol=size(tree,2);

%initializes the trace data. 
data=zeros(1,tree{tracenumber,tracecol}.TrDataPoints);
 
 
 % Disc format
 fmt=LocalFormatToString(tree{tracenumber,tracecol}.TrDataFormat);
 % Always read into double
 readfmt=[fmt '=>double'];
 % Read the data - always casting to double
 fseek(fh, tree{tracenumber,tracecol}.TrData, 'bof');
 [data(1,1:tree{tracenumber,tracecol}.TrDataPoints)]=...
 fread(fh, double(tree{tracenumber,tracecol}.TrDataPoints), readfmt);
 
 data(1,:)=data(1,:)*tree{tracenumber,tracecol}.TrDataScaler+tree{tracenumber,tracecol}.TrZeroData;

 %In case the user wants to plot it in another unkit range
 %(pV,nV,microV,mV, etc)
     % Get the data range....
     %[sc prefix]=LocalDataScaling(data);        
     %... and scale the data (to the prefix unit)
     %data=data*sc;
     
%creates a time vector (X coordinate in a plot):
nDataPoints=tree{tracenumber,tracecol}.TrDataPoints;
XInt=tree{tracenumber,tracecol}.TrXInterval;
time=[1:nDataPoints];
time=double(time);
time=time*XInt;

fclose(fh);

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

function [sc prefix]=LocalDataScaling(data)
%--------------------------------------------------------------------------
range=max(data(:)-min(data(:)));
if range<10^-9
    % Scale to pico-units
    sc=10^12;
    prefix='p';
elseif range<10^-6
    % Nano
    sc=10^9;
    prefix='n';
elseif range<10^-3
    % Micro
    sc=10^6;
    prefix='µ';
elseif range<1
    % Milli
    sc=10^3;
    prefix='m';
else
    % Stet
    sc=1;
    prefix='';
end
return
end