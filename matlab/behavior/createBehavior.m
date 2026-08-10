
%%

clear; clc
ft_defaults                                           

sip = sipConfig('behavior');
sip2 = sip_mainconfig;
fileList = sipFileList(sip.folder.support,'behavior');

% Behavior analysis uses .eve or medpc files
eveIds = getId(fileList.eveFiles);
medIds = getId(fileList.medFiles);

% Find sessions with only medpc output files available
[onlyMed, indx] = setdiff(medIds,eveIds,"rows");
onlyMedFiles = fileList.medFiles(indx);


%%
%% all eve files

% ----------configure event info for extraction -----%
behCfg.events       = sip.behavior.events;
behCfg.inter_bout   = sip.behavior.intBoutTime;
behCfg.min_dur      = sip.behavior.minBoutDur;
%----------configure event info for extraction -----%

emptyIds = [];                                                             % initilize variable

for ifile = 1%:length(file_list.eve)                                         % for each event file

    % -------------extract id infromation -------------------%
    behCfg.id.cohort_id     = file_list.eve(ifile).cohort_id;
    behCfg.id.animal_id     = file_list.eve(ifile).animal_id;
    behCfg.id.session_id    = file_list.eve(ifile).session_id;
    behCfg.id.manipulation  = file_list.eve(ifile).manipulation;
    % -------------extract id infromation -------------------%

    fprintf('Processing cohort %i, rat %i, session %i...',...
        behCfg.id.cohort_id,behCfg.id.animal_id,behCfg.id.session_id);      % print processing status

    behCfg.data = ft_read_event_tara(file_list.eve(ifile).file_path);       % read nlynxs behavior file
    behCfg.file = file_list.eve(ifile).file_path;

    if ~isempty(behCfg.data)
        events          = event_times(behCfg);                              % extract event information from nlynx
        behavior(ifile) = format_behavior(events);                          % format and concatenate behavioral info
    else
        emptyIds   = cat(1,emptyIds,ifile);                               % in case of a problem with nlynx, ev_cfg.data will be empty
    end
    fprintf('done\n')
end
% behavior(empty_ids)  = [];                                                             % remove empty files
% save([cfg.file.proc '\behavior_general.mat'],'behavior');     