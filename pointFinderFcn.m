function [index,indexTime,indexValue]=pointFinderFcn(trace,time,goal,peak,direction,baseline,amplitude,fraction)

for i=peak:direction:goal,
    if abs(trace(i)-baseline)-abs(amplitude*fraction)<0,
        index=i+goal-1;
        indexTime=time(i);
        indexValue=trace(i);
        break
    end
end