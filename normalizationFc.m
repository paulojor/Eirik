function [normTrace]=normalizationFc(trace,time,baseline)
%normalizing function.

[~,indexEnd]=min(abs(time-baseline));
avrBaseline=nanmean(trace(1:indexEnd));

normTrace=trace-avrBaseline;

end