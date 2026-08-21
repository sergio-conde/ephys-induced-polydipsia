function fileLists = sipFileList(listFolder,analysis)

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
        fileLists = load(fullfile(listFolder, '\rawFilesList.mat'),...
            "eveFiles","medFiles");
    case 'lfp'
    case 'spike'
    otherwise
        fileLists = [];
end
