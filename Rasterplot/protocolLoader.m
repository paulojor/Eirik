function protocol = protocolLoader(listfiles,protocolName)

for i=1:size(listfiles,1)
    if length(listfiles(i).name)>length(protocolName) && strcmp(listfiles(i).name(1:length(protocolName)),protocolName) ...
            && strfind(listfiles(i).name,'prot') 
        load(listfiles(i).name);
        disp(strcat('Protocol:',protocolName));
        disp('Loaded');
    end
end

end