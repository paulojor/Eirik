function sumAP = groupRasterplot

addpath(pwd);
folder = uigetdir;
cd(folder);
listfiles=dir;

sumAP=[];
for i=1:length(listfiles)
    if ~listfiles(i).isdir && ~isempty(strfind(listfiles(i).name,'rast'))
        load(listfiles(i).name);
        sumAP=[sumAP,AP];
    end
end

protocolName=sumAP(1).protocol;
protocol = protocolLoader(listfiles,protocolName);
for i=1:size(sumAP,2)
    if ~strcmp(sumAP(i).protocol,protocolName)
       protocolName=sumAP(i).protocol;
       protocol = protocolLoader(listfiles,protocolName);
    end
    simpleRasterplot(sumAP,i,protocol,1);
end

end


