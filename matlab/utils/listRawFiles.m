clear; clc
cfg = sipConfig;

% files configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rawConfig.mainPath = '\\vs03\VS03-NandB-1\tara\ephys_rat_sip\Data_collection\raw';          % data's root folder
rawConfig.levelName = {'cohort','animal','session','raw_folder'};                               % labels of each organization level
rawConfig.folderCode = {'*cohort*','w*','*','*'};                                          % string coding for each level (folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% % Listing event files
rawConfig.fileCode = '*.nev';         % files'string coding 
eveFiles = projectFiles(rawConfig);   % files' list
eveFiles = addSipIds(eveFiles,'nev');   % add id fields

% % Listing lfp files
rawConfig.fileCode = '*.ncs';             % files'string coding 
ncsFiles = projectFiles(rawConfig);   % files' list
ncsFiles = addSipIds(ncsFiles,'ncs');   % add id fields

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


%% Save the raw files lists so each one can be loaded independently

save([cfg.folder.support '\rawFilesList.mat'],...
"nttFiles",...
'ncsFiles',...
"eveFiles",...
"medFiles",...
"cheFiles",...
"nvtFiles");
