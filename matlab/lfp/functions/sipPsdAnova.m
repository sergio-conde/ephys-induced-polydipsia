function psdTest = sipPsdAnova(cfg)

% 1. Define the within-subjects factor: Epoch
testEpochs = {'PreCue','Cue','PreLick','Lick','PostLick'};
withinDesign = table(categorical(testEpochs'), 'VariableNames', {'Epoch'});

% PSD data selection 
idVariables = cfg.testPsd.Properties.VariableNames(1:3);

% Animal / Session -based ANOVA data selection 
dataVariables = cfg.testPsd.Properties.VariableNames(5:end);
switch cfg.based
    case 'animal'
        cfg.testPsd = groupsummary(cfg.testPsd,idVariables,"mean",dataVariables);
        dataVariables = cfg.testPsd.Properties.VariableNames(5:end);
    case 'session'
        
    otherwise
        errorMsg = sprintf('\n--> cfg.based must be "animal" or "session"\n');
        error(errorMsg)
end

% ANOVA data selection
strVarCode = strcat(cfg.testBand,cfg.testQuant);
testVarFlags = cellfun(@(x) contains(x,strVarCode),dataVariables);
testVariables = dataVariables(testVarFlags);

% ANOVA data format 
testData = cfg.testPsd(:,['rat','group',testVariables]);
testData.Properties.VariableNames = ['Rat','Group',testEpochs];
testData.Group = categorical(testData.Group);

% Mixed / Repeated ANOVA configuration 
switch cfg.model
    case 'mixed'
        formulaStr = sprintf('%s-%s ~ Group', testEpochs{1}, testEpochs{end}); 
        modelLabels = {'Group','(Intercept):Epoch','Group:Epoch'};
    case 'repeated'
        testData = testData(testData.Group == cfg.group,:);
        formulaStr = sprintf('%s-%s ~1', testEpochs{1}, testEpochs{end});
        modelLabels = {'(Intercept):Epoch'};
    otherwise
        errorMsg = sprintf('\n--> cfg.model must be "mixed" or "repeated"\n');
        error(errorMsg)
end

% Fit the ANOVA model 
rm = fitrm(testData, formulaStr, 'WithinDesign', withinDesign);

% Repeated measures ANOVA (within-subject effect + interaction)
ranovatbl = ranova(rm, 'WithinModel', 'Epoch');
disp(ranovatbl(modelLabels,'pValue'))

% format default output
psdTest.cfg = cfg;
psdTest.cfg.testEpochs = testEpochs;
psdTest.cfg.withinDesign = withinDesign;
psdTest.anova.data = testData;
psdTest.anova.fitModel = rm;
psdTest.anova.tbl = ranovatbl;
psdTest.anova.modelLabels = modelLabels;

if ranovatbl{"(Intercept):Epoch","pValue"} < 0.05
    psdTest.anova.epochComp = multcompare(rm,'Epoch');
    epochSig = psdTest.anova.epochComp(psdTest.anova.epochComp.pValue < 0.05,:);
    disp(epochSig)
end

% post-hoc tests for mixed ANOVA model
if strcmp(cfg.model,'mixed')
    if ranovatbl{"Group","pValue"} < 0.05
        psdTest.anova.groupComp = multcompare(rm,'Group');
        sigFlags = psdTest.anova.groupComp.pValue < 0.05;
        groupSig = psdTest.anova.groupComp(sigFlags,:);
        disp(groupSig)
    end
    if ranovatbl{"Group:Epoch","pValue"} < 0.05
        psdTest.anova.interEpochs = multcompare(rm,'Epoch','By','Group');
        sigFlags = psdTest.anova.interEpochs.pValue < 0.05;
        epochGroupSig = psdTest.anova.interEpochs(sigFlags,:);
        disp(epochGroupSig)

        psdTest.anova.interGroup = multcompare(rm,'Group','By','Epoch');
        sigFlags = psdTest.anova.interGroup.pValue < 0.05;
        groupEpochSig = psdTest.anova.interGroup(sigFlags,:);
        disp(groupEpochSig)
    end
end

