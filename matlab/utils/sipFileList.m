function fileList = sipFileList(listFolder,analysis)

% fileLists = sipFileList(listFolder,analysis) loads the files lists needed
% according to specifica analysis of the
% schedule-induced polydipsia project. This includes:
%
% listFolder - Folder containing all list files
% analysis - SIP analysis (e.g, behavior, lfp, etc.)
%
% Sergio Conde-Ocazionez, August 2026. 
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.

switch analysis
    case 'behavior'
        load(fullfile(listFolder, '\rawFilesList.mat'),...
            "behNlynxFiles","behMedFiles");
        behNlynxFiles = rmfield(behNlynxFiles,"rawFolder");
        jointList = cat(2,behNlynxFiles,behMedFiles);
        cfg = [];
        cfg.sessionID = [1 25];
        cfg.contrast.sessionID = 'range';
        fileList.behavior = getEntry(jointList,cfg);
    case 'lfp'
        fileList = load(fullfile(listFolder, '\lfpResampFiles.mat'),...
            'lfpFiles');
        fileList = fileList.lfpFiles;
    case 'spike'
    otherwise
        fileList = [];
end
