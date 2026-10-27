function [filetree,infotree,endian,FileName,PathName]=mapper

[FileName,PathName]= uigetfile({'*.dat;*.mat'},'Select the data file');
fullname=fullfile(PathName,FileName);
termination=FileName(end-2:end);

[filetree,infotree,endian,~,~]=Vespucio(FileName,PathName);

end
