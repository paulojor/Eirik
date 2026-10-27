function [rTrace]=rebuildTrace(preTrace,newTrace,postTrace)
%reconstructs a full continuous trace from his constituent parts (the
%inverse of 'sax' function).

rTrace=preTrace;

for i=1:size(newTrace,1)
   rTrace=horzcat(rTrace,newTrace(i,:)); 
end

rTrace=horzcat(rTrace,postTrace);

end
