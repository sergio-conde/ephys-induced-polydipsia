clear; clc
cfg = sipConfig;

% files configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rawConfig.mainPath = cfg.folder.raw;          % data's root folder
rawConfig.levelName = [cfg.folder.levelName,'rawFolder'];                               % labels of each organization level
rawConfig.folderCode = {'*cohort*','w*','*','*'};                                          % string coding for each level (folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% % Listing event files
rawConfig.fileCode = '*.nev';         % files'string coding 
eveFiles = projectFiles(rawConfig);   % files' list
eveFiles = addSipIds(eveFiles,'nev'); % add id fields

% % Listing lfp files
rawConfig.fileCode = '*.ncs';         % files'string coding 
ncsFiles = projectFiles(rawConfig);   % files' list
ncsFiles = addSipIds(ncsFiles,'ncs'); % add id fields

% % Listing event files
rawConfig.fileCode = 'Cheeta*';           % files'string coding 
cheFiles = projectFiles(rawConfig);   % files' list
cheFiles = addSipIds(cheFiles,'cheeta');% add id fields

% % Listing spiking files
rawConfig.fileCode = '*.ntt';             % files'string coding 
nttFiles = projectFiles(rawConfig);   % files' list
nttFiles = addSipIds(nttFiles,'ntt');   % add id fields

% % Listing spiking files
rawConfig.fileCode = '*.nvt';             % files'string coding 
nvtFiles = projectFiles(rawConfig);   % files' list
nvtFiles = addSipIds(nvtFiles,'nvt');   % add id fields

% %Listing medPC files
rawConfig.levelName = {'cohort','animal','session'};                               % labels of each organization level
rawConfig.folderCode = {'*cohort*','w*','*'};                                    % string coding for each level (folders)
rawConfig.fileCode = 'w*';            % files'string coding 
medFiles = projectFiles(rawConfig);   % files' list
medFiles = addSipIds(medFiles,'med');   % add id fields

%%
% Behavior analysis uses .eve or medpc files
eveIds = getID(eveFiles);
medIds = getID(medFiles);

% Find sessions with only medpc output files available
[onlyMed, indxMed] = setdiff(medIds,eveIds,"rows");
[~, indxNlyxn] = setdiff(eveIds,onlyMed,"rows");

behMedFiles = medFiles(indxMed);
behNlynxFiles = eveFiles(indxNlyxn);
%% Save the raw files lists so each one can be loaded independently

% save([cfg.folder.support '\rawFilesList.mat'],...
% "nttFiles",...
% 'ncsFiles',...
% "eveFiles",...
% "medFiles",...
% "cheFiles",...
% "nvtFiles", ...
% "behMedFiles", ...
% "behNlynxFiles");

%% save water intake file list

cfg = [];
cfg.mainPath = sip.folder.raw; % data's root folder
cfg.levelName = {'cohort'};    % labels of each organization level
cfg.folderCode = {'*cohort*'}; % string coding for each level (folders)
cfg.fileCode = '*.xlsx';
waterFiles = projectFiles(cfg); % files' list

% save([sip.folder.support '\waterFiles.mat'],"waterFiles");
