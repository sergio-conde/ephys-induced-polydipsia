clear; clc; 
sip = sip_mainconfig; ft_defaults

% list of files required
load(fullfile(sip.file.support,'lfp_resamp_files.mat'))

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

sessionIds = getId(lateFiles,'tet_id');

%%
cohereCell = cell(16,1);
drinkFlags = cell(16,1);
for isession = 5:length(sessionIds)

    fprintf('\nProcessing sess %i ... ',isession)

    fileIds = sessionIds(isession);
    header_file = get_entry(sip.file_list.nlynx.ncs,fileIds);

    cfg             = [];
    cfg.header      = ft_read_header(header_file(1).file_path);
    cfg.beh         = get_entry(behavior,fileIds);
    cfg.interval    = 'sip_trial';
    [trl,trlTable]  = trial_gen(cfg);

    % this trl coming from trial_gen is time, not samples as the one coming
    % from ft_definetrials. I should call this differently. 

    sessArtefact = get_entry(artefacts,fileIds);

    % loopFiles = get_entry(lateFiles,fileIds);
    lfps.ids = fileIds;
    nanFlag = false;
    for iarea = 1:2
        areaLabel = sip.ephys.area_label{iarea};

        cfg = fileIds;
        cfg.area = areaLabel;
        sessionLfp = get_entry(lateFiles,cfg);

        if ~isempty(sessionLfp)
            cfg.tet_id = sessionLfp.tet_id;
            tetAft = get_entry(sessArtefact,cfg);

            % PENSAR COMO ORGANIZAR PARA FACILITAR EL PLOT

            loopLFP = importdata(sessionLfp.file_path);
            if any(isnan(loopLFP.trial{1}))
                nanFlag = true;
            else
                timeIn = trl * 1e-6; % Trial times in seconds
                startTime = loopLFP.time{1}(1); % start time in seconds
                [trlSamples, resampTable] = resampTrl(timeIn,trlTable,startTime,loopLFP.fsample);

                % the input of ft_redefinetrial is samples
                trialCfg      = [];
                trialCfg.trl  = trlSamples;
                lfps.(areaLabel) = ft_redefinetrial(trialCfg,loopLFP);
            end
        else
            nanFlag = true;
        end
    end
    lfps.trialsInfo = resampTable;

    if ~nanFlag
        coheTrials = trialCoherence(lfps,sip);
        cohereCell{fileIds.tag_id} = cat(2,cohereCell{fileIds.tag_id},coheTrials);
        drinkFlags{fileIds.tag_id} = cat(2,drinkFlags{fileIds.tag_id},...
            lfps.trialsInfo.drink);
    end
    fprintf('done\n')
end
%%

tempCohere.data = cohereCell;
tempCohere.flags = drinkFlags;

% save(fullfile(sip.file.proc,'tempCohere.mat'),"tempCohere")

%%
clear; clc
sip = sip_mainconfig;
load(fullfile(sip.file.proc,'tempCohere.mat'))

%%
wfig(1); clf
for itag = 3:16

    subplot (4,4,itag); hold on
    tagPlus = []; tagMinus = [];

    for isess = 1:size(tempCohere.data{itag},2)
        sessPlus = logical(tempCohere.flags{itag}(:,isess));
        plusCohere = cat(1,tempCohere.data{itag}{sessPlus});
        if isempty(plusCohere)
            plusCohere = nan(1,length(sip.ephys.psds.foi));
        end
        tagPlus = cat(1,tagPlus,mean(plusCohere,1,"omitmissing"));
        minusCohere = cat(1,tempCohere.data{itag}{~sessPlus});
        tagMinus = cat(1,tagMinus,mean(minusCohere,1,"omitmissing"));
    end

    cfg = [];
    cfg.xdata = sip.ephys.psds.foi;
    cfg.ydata = tagPlus;
    cfg.alpha = 0.5;
    cfg.color_val = sip.graph.color.plus;
    avg_err_shade(cfg);
    cfg.color_val = sip.graph.color.minus;
    cfg.ydata = tagMinus;
    cfg.alpha = 0.4;
    avg_err_shade(cfg);
    xlim([0 25])
    title(sprintf('%s - %s',...
        sip.analysis.rat_ids.label{itag},...
        upper(sip.analysis.rat_ids.drink_gr{itag})))
    xlabel 'Frequency (Hz)';
    ylabel 'Coherence'
    box off
    ylim([0 0.5])
    hold off

end

% plusFalgs = lfps.trialsInfo.drink == 1;
% 
% plusCohere = cat(1,coheTrials{plusFalgs});
% minusCohere = cat(1,coheTrials{~plusFalgs});
% 
% cfg = [];
% cfg.xdata = sip.ephys.psds.foi;
% cfg.ydata = plusCohere;
% avg_err_shade(cfg);
% hold on
% cfg.color_val = 'r';
% cfg.ydata = minusCohere;
% avg_err_shade(cfg);
% hold off

% artefactos
% coherencia en cada epoch (3 sesiones)
% -> 3 x 7 x 2001 (sesion x epoch x freq)
% media de coherencia/epoch
% -> 7 x 2001 x 7 (epoch x freq x animal)
% media across animals

%%
%%
cohereCell = cell(16,1);
drinkFlags = cell(16,1);
% [18 27 30 34 38 46]
for isession = [7 10 13 16 18 22 25 28 31 34 37 40 43 46]%5:length(sessionIds)

    fprintf('\nProcessing sess %i ... ',isession)

    fileIds = sessionIds(isession);
    header_file = get_entry(sip.file_list.nlynx.ncs,fileIds);

    cfg             = [];
    cfg.header      = ft_read_header(header_file(1).file_path);
    cfg.beh         = get_entry(behavior,fileIds);
    cfg.interval    = 'lick';
    [trl,trlTable]  = trial_gen(cfg);

    % this trl coming from trial_gen is time, not samples as the one coming
    % from ft_definetrials. I should call this differently. 

    sessArtefact = get_entry(artefacts,fileIds);

    % loopFiles = get_entry(lateFiles,fileIds);
    lfps.ids = fileIds;
    nanFlag = false;
    for iarea = 1:2
        areaLabel = sip.ephys.area_label{iarea};

        cfg = fileIds;
        cfg.area = areaLabel;
        sessionLfp = get_entry(lateFiles,cfg);

        if ~isempty(sessionLfp)
            cfg.tet_id = sessionLfp.tet_id;
            tetAft = get_entry(sessArtefact,cfg);

            % PENSAR COMO ORGANIZAR PARA FACILITAR EL PLOT

            loopLFP = importdata(sessionLfp.file_path);
            if any(isnan(loopLFP.trial{1}))
                nanFlag = true;
            else
                timeIn = trl * 1e-6; % Trial times in seconds
                startTime = loopLFP.time{1}(1); % start time in seconds
                [trlSamples, resampTable] = resampTrl(timeIn,trlTable,startTime,loopLFP.fsample);

                % the input of ft_redefinetrial is samples
                trialCfg      = [];
                trialCfg.trl  = trlSamples;
                lfps.(areaLabel) = ft_redefinetrial(trialCfg,loopLFP);
            end
        else
            nanFlag = true;
        end
    end
    lfps.trialsInfo = resampTable;

    if ~nanFlag
        coheTrials = trialCoherence(lfps,sip);
        cohereCell{fileIds.tag_id} = cat(2,cohereCell{fileIds.tag_id},coheTrials);
        drinkFlags{fileIds.tag_id} = trlTable;
    end
    fprintf('done\n')
end
tempCohere.data = cohereCell;
tempCohere.flags = drinkFlags;
% save(fullfile(sip.file.proc,'tempCohereLick.mat'),"tempCohere")
%%
clear; clc
sip = sip_mainconfig;
load(fullfile(sip.file.proc,'tempCohereLick.mat'))

%%

wfig(10); clf
nsp = 1;
for itag = 3:16%[7 10 11 12 14 16]

    subplot (4,4,nsp); hold on
    nsp = nsp + 1;
    % tagPlus = []; tagMinus = [];
    % 
    % for isess = 1:size(tempCohere.data{itag},2)
    %     sessPlus = logical(tempCohere.flags{itag}(:,isess));
    %     plusCohere = cat(1,tempCohere.data{itag}{sessPlus});
    %     if isempty(plusCohere)
    %         plusCohere = nan(1,length(sip.ephys.psds.foi));
    %     end
    %     tagPlus = cat(1,tagPlus,mean(plusCohere,1,"omitmissing"));
    %     minusCohere = cat(1,tempCohere.data{itag}{~sessPlus});
    %     tagMinus = cat(1,tagMinus,mean(minusCohere,1,"omitmissing"));
    % end

    sessPlus = logical(tempCohere.flags{itag}.drink);
    plusCohere = cat(1,tempCohere.data{itag}{sessPlus});
    minusCohere = cat(1,tempCohere.data{itag}{~sessPlus});

    cfg = [];
    cfg.xdata = sip.ephys.psds.foi;
    cfg.ydata = plusCohere;
    cfg.alpha = 0.5;
    cfg.color_val = sip.graph.color.plus;
    avg_err_shade(cfg);
    cfg.color_val = sip.graph.color.minus;
    cfg.ydata = minusCohere;
    cfg.alpha = 0.4;
    avg_err_shade(cfg);
    xlim([0 25])
    title(sprintf('%s - %s',...
        sip.analysis.rat_ids.label{itag},...
        upper(sip.analysis.rat_ids.drink_gr{itag})))
    xlabel 'Frequency (Hz)';
    ylabel 'Coherence'
    box off
    ylim([0 0.7])
    hold off

end
%%

wfig(11); clf
nsp = 1;
spRefs = [1 3];

for igroup = 1:2
    groupLabel = sip.analysis.rat_ids.drink_gr{igroup};
    groupTags = find(sip.analysis.rat_ids.drink_id == igroup)';
    groupTags(groupTags < 3) = [];
    groupTags(groupTags == 12) = [];

    subplot(2,2,igroup); hold on
    plusCohere = nan(length(groupTags),length(sip.ephys.psds.foi));
    minusCohere = nan(length(groupTags),length(sip.ephys.psds.foi));
    nrat = 1;
    for itag = groupTags

        sessPlus = logical(tempCohere.flags{itag}.drink);
        ratPlus = cat(1,tempCohere.data{itag}{sessPlus});
        plusCohere(nrat,:) = mean(ratPlus,1,"omitmissing");
        ratMinus = cat(1,tempCohere.data{itag}{~sessPlus});
        minusCohere(nrat,:) = mean(ratMinus,1,"omitmissing");
        nrat = nrat + 1;

    end
        cfg = [];
        cfg.xdata = sip.ephys.psds.foi;

        cfg.ydata = plusCohere;
        cfg.alpha = 0.5;
        cfg.color_val = sip.graph.color.plus;
        avg_err_shade(cfg);

        cfg.color_val = sip.graph.color.minus;
        cfg.ydata = minusCohere;
        cfg.alpha = 0.4;
        avg_err_shade(cfg);

        % title(sprintf('%s - %s',...
        %     sip.analysis.rat_ids.label{itag},...
        %     upper(sip.analysis.rat_ids.drink_gr{itag})))

        xlabel 'Frequency (Hz)';
        ylabel 'OFC-Striatum Coherence'
        hold off; box off
        ylim([0 0.6]);  xlim([0 35])
        

        subplot(2,2,3)
        cfg.ydata = plusCohere;
        cfg.alpha = 0.5;
        cfg.color_val = sip.graph.color.(groupLabel);
        avg_err_shade(cfg);
        hold on; box off
        ylim([0 0.6]); xlim([0 35])
        xlabel 'Frequency (Hz)';
        ylabel 'OFC-Striatum Coherence'


        subplot(2,2,4)
        cfg.ydata = minusCohere;
        cfg.alpha = 0.4;
        cfg.color_val = sip.graph.color.(groupLabel);
        avg_err_shade(cfg);
        hold on; box off
        ylim([0 0.6]); xlim([0 35])
        xlabel 'Frequency (Hz)';
        ylabel 'OFC-Striatum Coherence'
   
end