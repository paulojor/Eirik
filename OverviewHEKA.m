
function [overview,filetree,infotree]=OverviewHEKA(tree)
%this function gives three variables in the end: 
%filetree: describes the name of the boxes with information.
%infotree: has the detailed meta information inside of each box.
%overview: contains both (the filetree on the first level, and the
%infotree in the second). 

%fh=fopen(datafile, 'r', endian);
%fseek(fh, start, 'bof');

%finds the number of traces.
ntraces=0;
for i=1:size(tree,1),
    if ~isempty(tree{i,5})
        ntraces=ntraces+1;
    end
end

%creates an overview map of the file. 
overview=cell(ntraces,4,2);
row=1;
i=1;
while i<size(tree,1)+1
    if ~isempty(tree{i,2}),
        overview{row,1,1}=tree{i,2}.GrLabel;
        overview{row,1,2}=tree{i,2};
        i=i+1;
        overview{row,2}=tree{i,3}.SeLabel;
        overview{row,2,2}=tree{i,3};
        nrSweeps=tree{i,3}.SeNumbersw;
        i=i+1;
        for j=1:nrSweeps,
            try,
            overview{row,3}=strcat('Sw',num2str(tree{i,4}.SwSweepCount));
            overview{row,3,2}=tree{i,4};
            i=i+1;
            overview{row,4}=strcat('Ch',num2str(tree{i,5}.TrAmplIndex));
            overview{row,4,2}=tree{i,5};
            i=i+1;
            catch
                break
            end
            if i>size(tree,1)
                    break
                end
            while ~isempty(tree{i,5}),
                row=row+1;
                overview{row,4}=strcat('Ch',num2str(tree{i,5}.TrAmplIndex));
                overview{row,4,2}=tree{i,5};
                i=i+1;
                if i>size(tree,1)
                    break
                end
            end
            row=row+1;
        end
    elseif ~isempty(tree{i,3}),
        overview{row,2}=tree{i,3}.SeLabel;
        overview{row,2,2}=tree{i,3};
        nrSweeps=tree{i,3}.SeNumbersw;
        i=i+1;
        for j=1:nrSweeps,
            try
            overview{row,3}=strcat('Sw',num2str(tree{i,4}.SwSweepCount));
            overview{row,3,2}=tree{i,4};
            i=i+1;
            overview{row,4}=strcat('Ch',num2str(tree{i,5}.TrAmplIndex));
            overview{row,4,2}=tree{i,5};
            i=i+1;
            catch
                break
            end
            if i>size(tree,1)
                    break
                end
            while ~isempty(tree{i,5}),
                row=row+1;
                overview{row,4}=strcat('Ch',num2str(tree{i,5}.TrAmplIndex));
                overview{row,4,2}=tree{i,5};
                i=i+1;
                if i>size(tree,1)
                    break
                end
            end
            row=row+1;
        end
    else
    i=i+1;
    end
end
            
filetree=overview(:,:,1);
infotree=overview(:,:,2);
end

            