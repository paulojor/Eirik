function [filetree,infotree,endian,FileName,PathName]=Vespucio(FileName,PathName)
%'Vespucio' loads the header tree of a HEKA '*.dat' file. 
%
%INPUTS:
%FileName: name of the HEKA '*.dat' one wants to load.
%PathName: directory where the file is located.

if nargin==0,
    %in case no input is given, the function shows a loading menu. 
    [FileName,PathName]= uigetfile('*.dat','Select the data file'); 
elseif nargin==1,
    %in case only the name of the file is give, the function assumes the
    %current directory to be the path. 
    PathName=pwd;
end

disp('Importing original metadata');
[tree,endian]=ImportHEKA2(FileName,PathName);
disp('Reorganizing the metadata');
[~,filetree,infotree]=OverviewHEKA(tree);