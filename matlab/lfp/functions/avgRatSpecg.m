
function [idInfo, lickPlusSpec, lickMinusSpec] = avgRatSpecg(cfg)

% ADD SOME INPUT CHECKING

% avgRatSpecg(cfg) loads the spectrograms of each rat/session and compute
% the mean spectrogram during lick(+) and lick(-) trials. It checks that
% the data from all tetrodes is present, clean the data (nans at noisy
% intervals)
% 
% Inputs:
% Structure containig (at least):
%
% Also can contain:
%
% Output:
%
% Schedule-Induced Polydipsia project
% Sergio Conde-Ocazionez, 2026. 
% Neurobiology and Behavior Lab
% Netherlands Institute for Neuroscience 

FRQSAMPLES = 541;
MAXNBIN = 102; 

% 102 because of the longest t_axis possible given te spectogram 
% configuration (102 samples [-7 45]s) but this has to be adapted, 
% shouldn't be fixed

% Initialize data from rat itag %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for itet = [cfg.tetInfo.(cfg.tetSelection)]
    for iAlign = 1:3
        alignLabel = cfg.alignDef{iAlign};
        tetLabel = sprintf('tt%i',itet);
        tetAvgPlus.(alignLabel).(tetLabel) = nan(FRQSAMPLES,MAXNBIN);
        tetAvgMinus.(alignLabel).(tetLabel) = nan(FRQSAMPLES,MAXNBIN);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

idInfo = get_id(cfg.tetInfo(1));
idInfo.area_id = [cfg.tetInfo.area_id];
idInfo.tet_id = [cfg.tetInfo.(cfg.tetSelection)];
idInfo.area = {cfg.tetInfo.area};


for isess = 1:length(cfg.ratSpecFiles)
    % load the specs from the session isess within the epoich iepoch
    load(cfg.ratSpecFiles(isess).file_path)

    specFields = fieldnames(specs);
    refThetrodes = [cfg.tetInfo.(cfg.tetSelection)];
    sessTetrodes = checkTetrodes(specFields,refThetrodes);

    sessionId = cfg.ratSpecFiles(isess).session_id;

    cfgBehavior = [];
    cfgBehavior.beh = pick_files(cfg.ratBehavior,'session_id',sessionId);
    cfgBehavior.events = {'lick'};
    sessBehavior = sip_behavior(cfgBehavior);

    % loop over all selected tetrodes for the rat itag, during session iepoch(isess)
    for itet = sessTetrodes 

        tetLabel = sprintf('tt%i',itet);
        tetSpec = specs.(tetLabel);
        spcTime = cellfun(@(x) size(x,2),tetSpec.spcgram); % lenght of each trial
        for ishort = find(spcTime < MAXNBIN) 
            tetSpec.spcgram{ishort}(:,spcTime(ishort) + 1:MAXNBIN) = nan;
        end

        sessArtefact.info = pick_files(cfg.artefactInfo.events,...
            'session_id',sessionId,...
            'tet_id',itet);
        sessArtefact.threshold = cfg.artefactInfo.threshold;

        if ~isempty(sessArtefact.info)
            cleanSpecs = removeArtefacts(tetSpec,sessArtefact);
        end
        
        for iAlign = 1:length(cfg.alignDef)

            alignLabel = cfg.alignDef{iAlign};
            centeredSpecs = alignSpecs(cleanSpecs,alignLabel,sessBehavior);

            % separate L+ and L- trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            tetPlus = cat(3,centeredSpecs.spcgram{specs.lick_flags});
            if ~isempty(tetPlus)
                tetAvgPlus.(alignLabel).(tetLabel) = cat(3,...
                    tetAvgPlus.(alignLabel).(tetLabel),...
                    mean(tetPlus,3,"omitmissing"));
            end
            tetMinus = cat(3,centeredSpecs.spcgram{~specs.lick_flags});
            tetAvgMinus.(alignLabel).(tetLabel) = cat(3,...
                tetAvgMinus.(alignLabel).(tetLabel),...
                mean(tetMinus,3,"omitmissing"));
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end

for iAlign = 1:length(cfg.alignDef)
    alignLabel = cfg.alignDef{iAlign};
    lickPlusSpec.(alignLabel) = structfun(@(x) mean(x,3,"omitmissing"),...
        tetAvgPlus.(alignLabel),'UniformOutput',false);
    lickMinusSpec.(alignLabel) = structfun(@(x) mean(x,3,"omitmissing"),...
        tetAvgMinus.(alignLabel),'UniformOutput',false);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sessTetrodes = checkTetrodes(specFields,refThetrodes)
sessTetrodes = [];
for tetRef = refThetrodes
    tetField = strcat('tt',num2str(tetRef));
    if ismember(tetField,specFields)
        sessTetrodes = cat(2,sessTetrodes,tetRef);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cleanSpecs = removeArtefacts(tetSpec,sessArtefact)

cleanSpecs = tetSpec;
arteFlags = sessArtefact.info.woi_percg > sessArtefact.threshold;
arteEvents = sessArtefact.info.woi_table(arteFlags,:);
noisyTrials = arteEvents.trial_id; 

for itrial = 1:length(noisyTrials)

    trialId = noisyTrials(itrial);
    trialFlags = sessArtefact.info.woi_table.trial_id == trialId;
    cueFlags = strcmp(sessArtefact.info.woi_table.woi_label,'cue');
    trialCue = sessArtefact.info.woi_table{trialFlags & cueFlags,'t_start'};
    artStart = (arteEvents{itrial,'t_start'} - trialCue) * 1e-6;
    artEnd = (arteEvents{itrial,'t_end'} - trialCue) * 1e-6;

    arteBins = tetSpec.t_axis{trialId} >= artStart & ...
        tetSpec.t_axis{trialId} <= artEnd;
    cleanSpecs.spcgram{trialId}(:,arteBins) = nan;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function centeredSpecs = alignSpecs(tetSpec,alignLabel,sessBehavior)

centeredSpecs = tetSpec;
centerPoint = 51; % 102/2

meanFirst = mean(sessBehavior.lick.t_first);
if isnan(meanFirst); meanFirst = 15; end % case of not having any lick in the current session

switch alignLabel
    case 'cue'
        return
    case 'start'
        firstTime = sessBehavior.lick.t_first;
    case 'end'
        firstTime = sessBehavior.lick.t_first + sessBehavior.lick.dur_first;
end

lickPlusTrials = unique(sessBehavior.lick.trial_id);
for itrial = 1:sessBehavior.ntrials
    timeAxis = tetSpec.t_axis{itrial};
    unShiftSpec = tetSpec.spcgram{itrial};
    [plusFlag, plusIdx] = ismember(itrial,lickPlusTrials);
    if plusFlag
        [~,firstSample] = min(abs(timeAxis - firstTime(plusIdx)));
    else
        [~,firstSample] = min(abs(timeAxis - meanFirst)); 
    end
    trialShift = centerPoint - firstSample;
    centeredSpecs.spcgram{itrial} = circshift(unShiftSpec,trialShift,2);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
