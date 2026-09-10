%%
clear; clc
sip = sip_mainconfig;
sessions = {'early','late'};
for isessions = 1:2
    filename = strcat('psdQuant',sessions{isessions},'.mat');
    load(fullfile(sip.file.proc,filename));
    psdContrast.(sessions{isessions}) = psdQuant;
end
% load('C:\Users\scond\OneDrive\Escritorio\psdQuantlate.mat')

%% Test different stats configurations for early and late sessions

bandLabels = {'Delta','Theta','Beta'};

anovaModel = 'mixed';

if strcmp(anovaModel,'mixed')
    testGroup = 'hd | ld';
    nComp = 3;
else
    testGroup = 'hd';
    nComp = 1;
end

multLabels = {'epochComp','interEpochs','interGroup'};
summaryAnova = struct([]);
nLine = 1;
sigInteraction = [];

for isessions = 1:2
    for iband = 1:numel(bandLabels)
        for iarea = 1:2
            cfg = [];
            cfg.sessions = sessions{isessions};
            cfg.testArea = sip.ephys.area_label{iarea}; % ofc / striatum
            cfg.based = 'session'; % animal / session
            cfg.testQuant = 'Diff'; % Diff / Ratio / NormDf / Power
            cfg.testBand = bandLabels{iband};
            cfg.group = testGroup;
            cfg.model = anovaModel;
            % cfg.group = 'ld';
            cfg.testPsd = psdContrast.(sessions{isessions}).(cfg.testArea);
            psdTest = sipPsdAnova(cfg); % main ANOVA function
            cfg.testBand = bandLabels;
            idLabels = setdiff(fieldnames(psdTest.cfg),{'display'});
            for iIdVar = 1:numel(idLabels)
                summaryAnova(nLine).(idLabels{iIdVar}) = psdTest.cfg.(idLabels{iIdVar});
            end
            for iModelVar = 1:numel(psdTest.anova.tableLabels)
                modelLabel = psdTest.anova.modelLabels{iModelVar};
                tableLabel = strcat('pVal',psdTest.anova.tableLabels{iModelVar});
                summaryAnova(nLine).(tableLabel) = psdTest.anova.mainTest{modelLabel,'pValue'};
            end
            for iCompVar = 1:nComp
                summaryAnova(nLine).(multLabels{iCompVar}) = psdTest.anova.(multLabels{iCompVar});
            end
            nLine = nLine + 1;
        end
    end
end

sessInteraction = [];
switch cfg.model
    case 'mixed'
        %Extract significant interactions form summaryAnova
        sigResults = summaryAnova([summaryAnova.pValGroupEpoch] < 0.05);
        refComp = 'interEpochs';
        switchVars = [11 9 10 1:8];
    case 'repeated'
        sigResults = summaryAnova([summaryAnova.pValEpoch] < 0.05);
        refComp = 'epochComp';
        switchVars = [10 8 9 1:7];
end

for iInt = 1:numel(sigResults)
    sigFlags = sigResults(iInt).(refComp).pValue < 0.05;
    sigTable = sigResults(iInt).(refComp)(sigFlags,:);
    sigTable(:,'testBand') = {sigResults(iInt).testBand};
    sigTable(:,'testArea' ) = {sigResults(iInt).testArea};
    sigTable(:,'sessions' ) = {sigResults(iInt).sessions};
    sessInteraction = cat(1,sessInteraction,sigTable);
end

clc
disp(cfg)
if ~isempty(sigResults)
    sessInteraction = movevars(sessInteraction,switchVars);
    %Keep only one direction per pair (avoid duplicated Cue-vs-Lick / Lick-vs-Cue rows)
    epochOrder = sigResults(1).testEpochs;
    keepRow = false(height(sessInteraction), 1);
    for iPair = 1:height(sessInteraction)
        idx1 = find(strcmp(epochOrder, string(sessInteraction.Epoch_1(iPair))));
        idx2 = find(strcmp(epochOrder, string(sessInteraction.Epoch_2(iPair))));
        keepRow(iPair) = idx1 < idx2;   % keeps e.g. Cue-vs-Lick, drops Lick-vs-Cue
    end
    sessInteraction = sessInteraction(keepRow, :);
    sessInteraction.Properties.VariableTypes(1:3) = "categorical";
    disp(sessInteraction)
else
    fprintf('\n -> No significant differences found <-\n')
end

%% Compare early and late HD

testGroup = 'hd';

clc
cfg = [];
cfg.testArea = 'ofc'; % ofc / striatum

earlyData = getEntry(psdContrast.early.(cfg.testArea),'group',testGroup);
earlyData = earlyData(:,1:104);
earlyData(:,'group') = {'early'};

lateData = getEntry(psdContrast.late.(cfg.testArea),'group',testGroup);
lateData(:,'group') = {'late'};

% PSD data selection 
idVariables = earlyData.Properties.VariableNames(1:3);
% Animal / Session -based ANOVA data selection 
dataVariables = earlyData.Properties.VariableNames(5:end);
earlytestPsd = groupsummary(earlyData,idVariables, ...
    @(x)mean(x,'omitmissing'),dataVariables);
% dataVariables = cfg.testPsd.Properties.VariableNames(5:end);


%%
cfg.based = 'session'; % animal / session
cfg.testQuant = 'Diff'; % Diff / Ratio
cfg.testBand = 'Theta';
cfg.model = 'repeated';
cfg.group = testGroup;
cfg.testPsd = cat(1,earlyData,lateData);
cfg.display = true;

earlyLateTest = sipPsdAnova(cfg);

