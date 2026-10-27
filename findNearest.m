function [index]=findNearest(time,timepoint)
%fining the nearest point in the time vector.

vector=abs(time-timepoint);
[~,index]=min(vector);

end