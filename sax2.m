function [newTrace,newTime,preTrace,postTrace]=sax2(trace,time,protocol2)

%Calculates the intX:
intX=time(2)-time(1);

%extracting the relevant cut information:
stimInds=uint64(protocol2.stimtimes/intX);
preInds=uint64(protocol2.beforeStim/intX);
afterInds=uint64(protocol2.afterStim/intX);
N=length(stimInds);
blockIndex=preInds+1+afterInds;
blocks=[stimInds-preInds;stimInds+afterInds];
blocks=blocks';

%creates new trace variable:
newTrace=NaN(N,blockIndex);

%filling the new trace:
for i=1:N
   newTrace(i,:)=trace(blocks(i,1):blocks(i,2)); 
end

%creating the new time variable:
newTime=(1:size(newTrace,2))*intX;

%filling up the ends:
if blocks(1,1)==0
    preTrace=[];
else
    preTrace=trace(1:blocks(1,1)-1);
end

endIndex=blocks(N,2);
if endIndex<=length(trace)
    postTrace=trace(endIndex:end);
else
    postTrace=[];
end

end


