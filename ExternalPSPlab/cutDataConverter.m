function [newCutData]=cutDataConverter(cutData)
%converts structure of the cell 'cutData' into a different cell
%organization. 

Ntraces=length(cutData);
Nblocks=size(cutData{1},1);
Npoints=size(cutData{1},2);
NCh=size(cutData{1},3);

newCutData=cell(1,Nblocks);

for i=1:Nblocks
    block=nan(Ntraces,Npoints,NCh);
    for j=1:Ntraces
        for k=1:NCh
            block(j,:,k)=cutData{j}(i,:,k);
        end
    end
    newCutData{i}=block;
    clear block
end


end
