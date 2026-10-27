function [newTrace,newTime,preTrace,postTrace]=sax(trace,time,protocol)

%Calculates the intX:
intX=time(2)-time(1);

%protocol is a structure with the following elements:
%protocol.preStart: time before first block
%protocol.preStim: time before stimulus (in each block)
%protocol.stimDur: stimulus duration
%protocol.afterStim: periode after stimulus (in each block)
%protocol.baseline: periode before the stimulus in the final cut 
%protocol.N: number of blocks

%blockDur=protocol.baseline+protocol.preStim+protocol.stimDur+(protocol.afterStim-protocol.baseline);
blockDur=protocol.durBlock;

if protocol.preStart==0
    startIndex=1;
    preTrace=[];
else
    startIndex=uint64(protocol.preStart/intX);
    preTrace=trace(1:startIndex-1); 
end

blockIndex=blockDur/intX;

newTrace=NaN(protocol.N,blockIndex);

k=startIndex;
for i=1:protocol.N
    for j=1:blockIndex
        newTrace(i,j)=trace(k);
        k=k+1;
    end
end

newTime=(1:size(newTrace,2))*intX;

endIndex=startIndex+(protocol.N*blockIndex);
if endIndex<=length(trace)
    postTrace=trace(endIndex:end);
else
    postTrace=[];
end

end