
%%

clear; clc
ft_defaults                                           

sip = sipConfig('behavior');
fileList = sipFileList(sip.folder.support,'behavior');

% TOW DIFFERENT FUNCTIONS (NERULAYNX AND MEDPC) CONVERGING TO THE SAME 
% OUPUT

% WHITHIN THE BEHAVIORAL FUNCTION: USE MEDPC PROCESSING FROM TOOLBOX

%% Select only files from regular SIP sessions
cfg = [];
cfg.sessionID = [1 25];
cfg.contrast.sessionID = 'range';
sipMedFiles = getEntry(fileList.behMedFiles,cfg); 
sipNlynxFiles = getEntry(fileList.behNlynxFiles,cfg);
%%
ifile = 1;

cfg = sip.medpc;
cfg.data = sipMedFiles(ifile).filePath;
medBehavior = medEvents(cfg);

% extract number of pre-licks from internal counter
medBehavior.preLicks = medBehavior.cfg.data.C(7);

%%

ifile = 1;

%% all eve files

% ----------configure event info for extraction -----%
behCfg.events      = sip.behavior.events;
behCfg.interBout   = sip.behavior.intBout;
behCfg.minBoutDur  = sip.behavior.minBoutDur;
%----------configure event info for extraction -----%

emptyIds = [];                                                              % initilize variable

for ifile = 1%:length(file_list.eve)                                        % for each event file

    fileId = getID(fileList.eveFiles(ifile)); 
    
    % -------------extract id infromation -------------------%
    behCfg.id.cohort_id     = fileList.eve(ifile).cohort_id;
    behCfg.id.animal_id     = fileList.eve(ifile).animal_id;
    behCfg.id.session_id    = fileList.eve(ifile).session_id;
    behCfg.id.manipulation  = fileList.eve(ifile).manipulation;
    % -------------extract id infromation -------------------%

    fprintf('Processing cohort %i, rat %i, session %i...',...
        behCfg.id.cohort_id,behCfg.id.animal_id,behCfg.id.session_id);      % print processing status

    behCfg.data = ft_read_event_tara(file_list.eve(ifile).file_path);       % read nlynxs behavior file
    behCfg.file = file_list.eve(ifile).file_path;

    if ~isempty(behCfg.data)
        events          = nlynxEvents(behCfg);                             % extract event information from nlynx
        behavior(ifile) = format_behavior(events);                          % format and concatenate behavioral info
    else
        emptyIds   = cat(1,emptyIds,ifile);                                 % in case of a problem with nlynx, ev_cfg.data will be empty
    end
    fprintf('done\n')
end

% behavior(empty_ids)  = [];                                                % remove empty files
% save([cfg.file.proc '\behavior_general.mat'],'behavior');     