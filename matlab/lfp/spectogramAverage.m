clear; clc
sip = sip_mainconfig; 

sessions = 'late';
alignDef = {'cue','start','end'};
for iArea = 1:2
    areaLabel = sip.ephys.area_label{iArea};
    for iAlign = 1:length(alignDef)
        alignLabel = alignDef{iAlign};
        alignedSpecs.(areaLabel).(alignLabel).plus = [];
        alignedSpecs.(areaLabel).(alignLabel).minus = [];
    end
end
load(fullfile(sip.file.support,'session_specs_files_pre7.mat'));
load(fullfile(sip.file.support,'tetrode_epoch.mat'))
tetInfo = tetrode_epoch.(sessions);
load(fullfile(sip.file.proc,'behavior.mat'));
fileName = strcat('lfpArtefacts', sessions, '.mat');
load(fullfile(sip.file.support,fileName))

%%

artefactInfo = [];
artefactInfo.threshold = 1;

tagStr = ' ... ';
fprintf('\nProcessing rat%s',tagStr)
for itag = 1:16

    fprintf(repmat('\b',1,length(tagStr)))
    tagStr = sprintf(' %i ',itag);
    fprintf('%s',tagStr)  

    % Get the spectrum files from the rat itag contained in the file
    % list
    entry             = [];
    entry.tag_id      = itag;
    entry.rat_tag     = itag;
    entry.session_id  = sip.ephys.(sessions)(itag,:);
    ratSpec           = get_entry(session_specs_files,entry);
    ratBehavior       = get_entry(behavior,entry);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    artefactInfo.events = pick_files(artefacts,'tag_id',itag);  
    ratTetrodes = pick_files(tetInfo,'tag_id',itag);

    cfg = [];
    cfg.ratSpecFiles = ratSpec;
    cfg.tetInfo = ratTetrodes;
    cfg.tetSelection = 'wide';
    cfg.artefactInfo = artefactInfo;
    cfg.ratBehavior = ratBehavior;
    cfg.alignDef = alignDef;
    [ratId, ratLickPLus, ratLickMinus] = avgRatSpecg(cfg);

    for iArea = 1:2
        areaLabel = sip.ephys.area_label{iArea};
        tetId = ratId.tet_id(ratId.area_id == iArea);
        if ~isempty(tetId)
            tetLabel = strcat('tt',num2str(tetId));
            for iAlign = 1:length(alignDef)
                alignLabel = alignDef{iAlign};

                alignedSpecs.(areaLabel).(alignLabel).plus = cat(3,...
                    alignedSpecs.(areaLabel).(alignLabel).plus,...
                    ratLickPLus.(alignLabel).(tetLabel));

                alignedSpecs.(areaLabel).(alignLabel).minus = cat(3,...
                    alignedSpecs.(areaLabel).(alignLabel).minus,...
                    ratLickMinus.(alignLabel).(tetLabel));
            end
        end
    end
end
fprintf('\n')  
alignedSpecs.ratId = sip.analysis.rat_ids;
% save(fullfile(sip.file.support,'alignedSpecs.mat'),"alignedSpecs")

%% PLOT RESULTS

clear; clc
sip = sip_mainconfig;
load(fullfile(sip.file.support,'alignedSpecs.mat'))

sessions = 'late';
alignDef = {'cue','start','end'};
titleLabels = {'@cue','@start','@end'};

%%
dispFreq = [0 80];
dispTime = [-5 15;... cue centered window
    -7.5 8; ... aligned to the bout start
    -8 6]; % aligned to the bout end

tAxis = linspace(-6,44.5,102);
fAxis = linspace(1,100,541);
frqFlags = fAxis >= dispFreq(1) & fAxis <= dispFreq(2);

xLabelTick = {[0 5 10 dispTime(1,2)],...
    [dispTime(2,1) 0 dispTime(2,2)],....
    [dispTime(3,1) 0 dispTime(3,2)]};

xLabelRefs = {{'cue on','pellet','10s',sprintf('%is',dispTime(1,2))},...
    {sprintf('%.1fs',dispTime(2,1)),'onset',sprintf('%is',dispTime(2,2))},...
    {sprintf('%is',dispTime(3,1)),'offset',sprintf('%is',dispTime(3,2))}};


for iDrink = 1:2
    drinkFlags = alignedSpecs.ratId.drink_id == iDrink;
    drinkFlags(1:2) = false;
    wfig(iDrink);
    nsp = 1;
    for iArea = 1:2
        areaLabel = sip.ephys.area_label{iArea};        
        for iAlign = 1:length(alignDef)

            if iAlign > 1
                tAxisPLot = tAxis - tAxis(51);
            else
                tAxisPLot = tAxis;
            end

            timeFlags = tAxisPLot >= dispTime(iAlign,1) & ...
                tAxisPLot <= dispTime(iAlign,2);

            alignLabel = alignDef{iAlign};
            plotPlus = alignedSpecs.(areaLabel).(alignLabel).plus;
            plotMinus = alignedSpecs.(areaLabel).(alignLabel).minus;

            % plotRatio = plotPlus - plotMinus;
            plotRatio = 20*log10(plotPlus./plotMinus);
            plotData = mean(plotRatio(:,:,drinkFlags),3,"omitmissing");

            % plotData = smoothdata2(plotData,"gaussian",3);

            subplot(2,3,nsp)
            contourf(tAxisPLot(timeFlags),fAxis(frqFlags), ...
                plotData(frqFlags,timeFlags),...
                30,'LineStyle','none')
            hold on
            plot(dispTime(iAlign,:),[4 12 30;4 12 30],'w','LineWidth',2)
            plot([0 0],[1.1 80],'--w')
            if iAlign == 1
                plot([5 5],[1.1 80],'--w')
            end
            hold off; box off
            set(gca,'YScale','log')
            set(gca,'XTick',xLabelTick{iAlign}, ...
                'XTickLabel',xLabelRefs{iAlign})
            set(gca,'yTick',[2 7 18 45] ,...
                'YTickLabel',sip.ephys.band_label)

            xlabel('Time (s)'); ylabel('Frequency (Hz)');
            title(sprintf('%s - %s - %s - %s', ...
                titleLabels{iAlign},...
                upper(sip.analysis.drink_label{iDrink}),...
                sip.ephys.area_label{iArea},...
                sessions));

            colormap(parula)
            colorbar

            nsp = nsp + 1;
            clim([-2.5 2.5])
            % clim([-100 100])
            % clim([0.8 1.25])
        end
    end
end
