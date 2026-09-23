clear; clc
sip = sipConfig;
load([sip.folder.support '\waterFiles.mat'],"waterFiles");
waterIntake = importdata(fullfile(sip.folder.support,'\rawFilesList.mat'), ...
    "behMedFiles");

ratIds = setRatIds;
nRats = height(ratIds);

cohortID = 0;
for iRat = 1:nRats
    if ratIds.cohortID(iRat) ~= cohortID
        cohortID = cohortID + 1;
        cohortData = readtable(waterFiles(cohortID).filePath);
    end
end

% % import medpc outputfiles. These files are taken as reference to find the
% % water intke in the excel files. 
% medpcDates = cellfun(@(x) x(5:end),{waterIntake(:).name}, ...
%     'UniformOutput',false)';
