function psdTest = sipPsdAnova(cfg)

if ~isfield(cfg,'display')
    cfg.display = false;
end

% 1. Define the within-subjects factor: Epoch
testEpochs = {'PreCue','Cue','PreLick','Lick','PostLick'};
withinDesign = table(categorical(testEpochs'), 'VariableNames', {'Epoch'});

% format data to process the ANOVA
testData = formatSipAnova(cfg);

% Mixed / Repeated ANOVA configuration 
switch cfg.model
    case 'mixed'
        formulaStr = sprintf('%s-%s ~ Group', testEpochs{1}, testEpochs{end}); 
        modelLabels = {'Group','(Intercept):Epoch','Group:Epoch'};
        tableLabels = {'Group','Epoch','GroupEpoch'};
        multLabels = {'epochComp','interEpochs','interGroup'};
        cfg.group = 'hd | ld';
    case 'repeated'
        testData = testData(testData.Group == cfg.group,:);
        formulaStr = sprintf('%s-%s ~1', testEpochs{1}, testEpochs{end});
        modelLabels = {'(Intercept):Epoch'};
        tableLabels = {'Epoch'};
        if ~isfield(cfg,'group')
            cfg.group = 'hd';
        end
        multLabels = {'epochComp'};
    otherwise
        errorMsg = sprintf('\n--> cfg.model must be "mixed" or "repeated"\n');
        error(errorMsg)
end

% Fit the ANOVA model 
rm = fitrm(testData, formulaStr, 'WithinDesign', withinDesign);

% Repeated measures ANOVA (within-subject effect + interaction)
ranovatbl = ranova(rm, 'WithinModel', 'Epoch');
if cfg.display
    disp(ranovatbl(modelLabels,'pValue'))
end

% format default output
psdTest.cfg = cfg;
psdTest.cfg.testEpochs = testEpochs;
psdTest.cfg.withinDesign = withinDesign;
psdTest.anova.data = testData;
psdTest.anova.fitModel = rm;
psdTest.anova.mainTest = ranovatbl;
psdTest.anova.modelLabels = modelLabels;
psdTest.anova.tableLabels = tableLabels;
psdTest.anova.multLabels = multLabels;

if ranovatbl{"(Intercept):Epoch","pValue"} < 0.05 
    psdTest.anova.epochComp = multcompare(rm,'Epoch');
    epochSig = psdTest.anova.epochComp(psdTest.anova.epochComp.pValue < 0.05,:);
    if cfg.display
        disp(epochSig)
    end
else
    psdTest.anova.epochComp = nan;
end

% post-hoc tests for mixed ANOVA model
if strcmp(cfg.model,'mixed')
    if ranovatbl{"Group","pValue"} < 0.05 
        psdTest.anova.groupComp = multcompare(rm,'Group');
        sigFlags = psdTest.anova.groupComp.pValue < 0.05;
        groupSig = psdTest.anova.groupComp(sigFlags,:);
        if cfg.display
            disp(groupSig)
        end
    else
        psdTest.anova.groupComp = nan;
    end
    if ranovatbl{"Group:Epoch","pValue"} < 0.05 
        psdTest.anova.interEpochs = multcompare(rm,'Epoch','By','Group');
        sigFlags = psdTest.anova.interEpochs.pValue < 0.05;
        epochGroupSig = psdTest.anova.interEpochs(sigFlags,:);
        if cfg.display
            disp(epochGroupSig)
        end

        psdTest.anova.interGroup = multcompare(rm,'Group','By','Epoch');
        sigFlags = psdTest.anova.interGroup.pValue < 0.05;
        groupEpochSig = psdTest.anova.interGroup(sigFlags,:);
        if cfg.display
            disp(groupEpochSig)
        end
    else
        psdTest.anova.interEpochs = nan;
        psdTest.anova.interGroup = nan;
    end
end

