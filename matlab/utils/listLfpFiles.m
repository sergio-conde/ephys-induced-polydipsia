%% LIST RESAMPLE LFP FILES
clear; clc; 
sip = sipConfig; 
dirFiles = dir(fullfile(sip.folder.proc,'lfp\03_resamp\*.mat'));
%%
lfpFiles = struct([]);
for ifile = 1:length(dirFiles)

    lfpFiles(ifile).name       = dirFiles(ifile).name;
    lfpFiles(ifile).folder     = dirFiles(ifile).folder;
    lfpFiles(ifile).file_path  = fullfile(lfpFiles(ifile).folder,lfpFiles(ifile).name);
    splitName                 = split(lfpFiles(ifile).name,'_');
    lfpFiles(ifile).cohortID  = str2double(splitName{1}(2));
    lfpFiles(ifile).animalID  = str2double(splitName{2}(2));
    lfpFiles(ifile).sessionID = str2double(splitName{3}(2:end));
    lfpFiles(ifile).tetID     = str2double(splitName{4}(3:end));
    lfpFiles(ifile).area      = splitName{6};

    ratFlag = sip.data.ratIds.cohortID == lfpFiles(ifile).cohortID & ...
        sip.data.ratIds.animalID == lfpFiles(ifile).animalID;
    lfpFiles(ifile).tagID = sip.data.ratIds.tagID(ratFlag);
end
lfpFiles = orderfields(lfpFiles,[9 4:8 1:3]);
% save(fullfile(sip.folder.support,'lfpResampFiles.mat'),"lfpFiles")