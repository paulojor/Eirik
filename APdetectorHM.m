function [AP]=APdetectorHM(trace,threshold)
%This function will give the output 0 if there is no AP's and 1 if there
%is. 

AP=0;
if max(trace)-min(trace)>threshold, %the absolute threshold is set to a 20 mV change.
    AP=1;
end

end