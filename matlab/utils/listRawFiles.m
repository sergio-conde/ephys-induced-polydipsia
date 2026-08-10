clear; clc
cfg = sipConfig;

% files configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rawConfig.main_path = '\\vs03\VS03-NandB-1\tara\ephys_rat_sip\Data_collection\raw';          % data's root folder
rawConfig.level_name = {'cohort','animal','session','raw_folder'};                               % labels of each organization level
rawConfig.folder_coding = {'*cohort*','w*','*','*'};                                          % string coding for each level (folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% % Listing event files
rawConfig.file_str = '*.nev';         % files'string coding 
eveFiles = projectFiles(rawConfig);   % files' list
eveFiles = addSipIds(eveFiles,'nev');   % add id fields

% % Listing lfp files
rawConfig.file_str = '*.ncs';             % files'string coding 
ncsFiles = projectFiles(rawConfig);   % files' list
ncsFiles = addSipIds(ncsFiles,'ncs');   % add id fields

% % Listing event files
rawConfig.file_str = 'Cheeta*';           % files'string coding 
cheFiles = projectFiles(rawConfig);   % files' list
cheFiles = addSipIds(cheFiles,'cheeta');% add id fields

% % Listing spiking files
rawConfig.file_str = '*.ntt';             % files'string coding 
nttFiles = projectFiles(rawConfig);   % files' list
nttFiles = addSipIds(nttFiles,'ntt');   % add id fields

% % Listing spiking files
rawConfig.file_str = '*.nvt';             % files'string coding 
nvtFiles = projectFiles(rawConfig);   % files' list
nvtFiles = addSipIds(nvtFiles,'nvt');   % add id fields

% %Listing medPC files
rawConfig.level_name = {'cohort','animal','session'};                               % labels of each organization level
rawConfig.folder_coding = {'*cohort*','w*','*'};                                    % string coding for each level (folders)
rawConfig.file_str = 'w*';                % files'string coding 
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
