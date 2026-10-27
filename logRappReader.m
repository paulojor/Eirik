function times = logRappReader(varargin)

%name of the default file:
%filename='200309_3_timeline.txt';

if nargin<1
    [file,path] = uigetfile('*.txt');
    filename = fullfile(path,file);
else
    filename=varargin{1};
end

%%
%reads the log file and finds the stimulation times:
text = fileread(filename);
matches = regexp(text,'starttime=','end');
matches2 = regexp(text,'description','start');

times=nan(1,length(matches));
for i=1:length(times)
    times(i)=str2num(text(matches(i)+1:matches2(i)-1));
end

times=times/1000000; %converts to seconds.

end