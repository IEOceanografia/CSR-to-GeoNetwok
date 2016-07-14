% This Matlab script is a simple loop to apply the XSL Transformation
% (CSR-to-GeoNetwork.xsl) to CSR files prevously stored in a folder of
% your system.
%
% Be sure that the folder only contains your XML files to be transformed.
%
% Author: Instituto Español de Oceanografia
%         Pablo Otero (pablo.otero@md.ieo.es)
% 14-Jul-2016 

clear all; close all;

% Choose name of the directory that will be created in the current dir
output_dir_name='CSR2GN';

% ----- (END USER OPTIONS)

directoryname = uigetdir('', 'Pick a Directory with your CSR files');

newSubFolder = fullfile(pwd,output_dir_name);
if ~exist(newSubFolder, 'dir')
  mkdir(newSubFolder);
end

kk=dir(fullfile(directoryname,'*.xml'));

for count=1:length(kk)
     namefile=kk(count).name;
    
    inputfile=fullfile(directoryname,namefile);
    outputfile=fullfile(newSubFolder,namefile);

    xslt(inputfile,'CSR-to-GeoNetwork.xsl',outputfile);
end