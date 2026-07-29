clear; clc; 
sip = sip_mainconfig; ft_defaults

% list of files required
load(fullfile(sip.file.support,'lfp_files.mat'))

% supporting data required
load(fullfile(sip.file.proc,'behavior.mat'))

load(fullfile(sip.file.support,'lfpArtefactsLate.mat'))

% %
% lfp file list
% tetrode: to compute only from those pairs
% behavior: to cut trials

% load each file: final?
% fill?
% extract phase from all session
% cut trials from raw
% cut trials from phases
% remove trials with artefacts
% quantify how many good trials we still have

% Inlcude coherence parameters into config
% compute coherence
% present coherence spectrum: trial
% present rose histogram of phases

% %

% list of late session files to be processed
% sessions and tetrodes

cfg               = [];
cfg.lfp_list      = lfp_files;
cfg.tetrode       = sip.ephys.tetrodes;
cfg.epoch         = 'late';
cfg.tet_selection = 'wide';
lateFiles         = pickLFP(cfg);
% sessionFiles = unique([[lateFiles.cohort_id]' [lateFiles.animal_id]' [lateFiles.session_id]'],"rows");

sessionIds = getId(lateFiles,'tet_id');
%%
for isession = 5%:length(sessionIds)

    fileIds = sessionIds(isession);
    header_file = get_entry(sip.file_list.nlynx.ncs,fileIds);

    cfg             = [];
    cfg.header      = ft_read_header(header_file(1).file_path);
    cfg.beh         = get_entry(behavior,fileIds);
    cfg.interval    = 'sip_trial';
    [trl,trlTable]  = trial_gen(cfg);
    %this trl coming from trial_gen is time, not samples as the one coming
    %from ft_definetrials. I should call this differently. 

    sessArtefact = get_entry(artefacts,fileIds);

    % loopFiles = get_entry(lateFiles,fileIds);
    lfps.ids = fileIds;
    for iarea = 1:2
        areaLabel = sip.ephys.area_label{iarea};

        cfg = fileIds;
        cfg.area = areaLabel;
        sessionLfp = get_entry(lateFiles,cfg);
        cfg.tet_id = sessionLfp.tet_id;
        tetAft = get_entry(sessArtefact,cfg);

        % PENSAR COMO ORGANIZAR PARA FACILITAR EL PLOT

        loopLFP = importdata(sessionLfp.file_path);

        % Extract, cut and store beta phase information

        timeIn = trl * 1e-6; % Trial times in seconds
        startTime = loopLFP.time{1}(1); % start time in seconds 
        [trlSamples, resampTable] = resampTrl(timeIn,trlTable,startTime,loopLFP.fsample);
       
        % the input of ft_redefinetrial is samples
        trialCfg      = [];
        trialCfg.trl  = trlSamples;
        lfps.(areaLabel) = ft_redefinetrial(trialCfg,loopLFP);
    end
    lfps.trialsInfo = resampTable;  

end
%%
% artefactos
% coherencia en cada epoch (3 sesiones)
% -> 3 x 7 x 2001 (sesion x epoch x freq)
% media de coherencia/epoch
% -> 7 x 2001 x 7 (epoch x freq x animal)
% media across animals