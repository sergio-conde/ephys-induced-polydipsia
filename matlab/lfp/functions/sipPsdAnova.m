function psdTest = sipPsdAnova(cfg)

% Check input configuration and defaults
cfg = checkCfg(cfg);

% 1. Define the within-subjects factor: Epoch
testEpochs = {'PreCue','Cue','PreLick','Lick','PostLick'};

% format data to process the ANOVA
testData = formatSipAnova(cfg);

% Mixed / Repeated ANOVA configuration 
switch cfg.model
    case 'mixed'
        modelVar = 'Epoch';
        withinDesign = table(categorical(testEpochs'), ...
            'VariableNames', {modelVar});
        formulaStr = sprintf('%s-%s ~ Group', ...
            testEpochs{1}, testEpochs{end}); 
        modelLabels = {'Group','(Intercept):Epoch','Group:Epoch'};
        tableLabels = {'Group','Epoch','GroupEpoch'};
        multLabels = {'epochComp','interEpochs','interGroup'};
        cfg.testGroup = 'hd | ld';
    case 'repeated'
        modelVar = 'Epoch';
        withinDesign = table(categorical(testEpochs'), ...
            'VariableNames', {modelVar});
        testData = testData(testData.Group == cfg.testGroup,:);
        formulaStr = sprintf('%s-%s ~1', ...
            testEpochs{1}, testEpochs{end});
        modelLabels = {'(Intercept):Epoch'};
        tableLabels = {'Epoch'};
        multLabels = {'epochComp'};
    case 'earlyLate'
        modelVar = 'Session*Epoch';
        sessionLevels = repelem({'Early','Late'}, 5)';   
        epochLevelsRep = repmat(testEpochs', 2, 1);   
        anovaVars = testData.Properties.VariableNames(3:end);
        withinDesign = table(categorical(sessionLevels), ...
            categorical(epochLevelsRep), ...
            'VariableNames', {'Session','Epoch'});
        formulaStr = sprintf('%s-%s ~ 1', ...
            anovaVars{1}, anovaVars{end});
        modelLabels = {'(Intercept):Session',
            '(Intercept):Epoch',
            '(Intercept):Session:Epoch'};
        tableLabels = {'Session','Epoch','SessionEpoch'};
        multLabels = {'epochComp','interEpochs','interSession'};
    otherwise
        errorMsg = sprintf(['\n--> cfg.model must be: ' ...
            '"mixed" / "repeated" / "earlyLate"\n']);
        error(errorMsg)
end

% Fit the ANOVA model 
rm = fitrm(testData, formulaStr, 'WithinDesign', withinDesign);

% Repeated measures ANOVA (within-subject effect + interaction)
ranovatbl = ranova(rm, 'WithinModel', modelVar);
if cfg.display
    disp(ranovatbl(modelLabels,'pValue'))
end

% format default output
psdTest.cfg = cfg;
psdTest.cfg.testEpochs = testEpochs;
psdTest.cfg.withinDesign = withinDesign;
psdTest.anova.data = testData;
psdTest.anova.modelVar = modelVar;
psdTest.anova.fitModel = rm;
psdTest.anova.mainTest = ranovatbl;
psdTest.anova.modelLabels = modelLabels;
psdTest.anova.tableLabels = tableLabels;
psdTest.anova.multLabels = multLabels;

psdTest = multSipCompare(psdTest);

% Check / display / store results
function psdTest = multSipCompare(psdTest)

rm = psdTest.anova.fitModel;
ranovatbl = psdTest.anova.mainTest;

if ranovatbl{"(Intercept):Epoch","pValue"} < 0.05 
    psdTest.anova.epochComp = multcompare(rm,'Epoch');
    epochSig = psdTest.anova.epochComp(psdTest.anova.epochComp.pValue < 0.05,:);
    if psdTest.cfg.display
        disp(epochSig)
    end
else
    psdTest.anova.epochComp = nan;
end

% post-hoc tests for mixed ANOVA model
switch psdTest.cfg.model
    case 'mixed'
        if ranovatbl{"Group","pValue"} < 0.05
            psdTest.anova.groupComp = multcompare(rm,'Group');
            sigFlags = psdTest.anova.groupComp.pValue < 0.05;
            groupSig = psdTest.anova.groupComp(sigFlags,:);
            if psdTest.cfg.display
                disp(groupSig)
            end
        else
            psdTest.anova.groupComp = nan;
        end
        if ranovatbl{"Group:Epoch","pValue"} < 0.05
            psdTest.anova.interEpochs = multcompare(rm,'Epoch','By','Group');
            sigFlags = psdTest.anova.interEpochs.pValue < 0.05;
            epochGroupSig = psdTest.anova.interEpochs(sigFlags,:);
            if psdTest.cfg.display
                disp(epochGroupSig)
            end

            psdTest.anova.interGroup = multcompare(rm,'Group','By','Epoch');
            sigFlags = psdTest.anova.interGroup.pValue < 0.05;
            groupEpochSig = psdTest.anova.interGroup(sigFlags,:);
            if psdTest.cfg.display
                disp(groupEpochSig)
            end
        else
            psdTest.anova.interEpochs = nan;
            psdTest.anova.interGroup = nan;
        end
    case 'earlyLate'
        if ranovatbl{"(Intercept):Session","pValue"} < 0.05
            psdTest.anova.sessionComp = multcompare(rm,'Session');
            sigFlags = psdTest.anova.sessionComp.pValue < 0.05;
            groupSig = psdTest.anova.sessionComp(sigFlags,:);
            if psdTest.cfg.display
                disp(groupSig)
            end
        else
            psdTest.anova.sessionComp = nan;
        end
        if ranovatbl{"(Intercept):Session:Epoch","pValue"} < 0.05
            psdTest.anova.interSession = multcompare(rm,...
                'Session', 'By', 'Epoch');
            sigFlags = psdTest.anova.interSession.pValue < 0.05;
            groupSig = psdTest.anova.interSession(sigFlags,:);
            if psdTest.cfg.display
                disp(groupSig)
            end
            psdTest.anova.interEpochs = multcompare(rm,...
                'Epoch', 'By', 'Session');
            sigFlags = psdTest.anova.interEpochs.pValue < 0.05;
            groupSig = psdTest.anova.interEpochs(sigFlags,:);
            if psdTest.cfg.display
                disp(groupSig)
            end
        else
            psdTest.anova.interSession = nan;
            psdTest.anova.interEpochs = nan;
        end
end

function cfg = checkCfg(cfg)

if ~isfield(cfg,'display')
    cfg.display = false;
end
if strcmp(cfg.model,'repeated') && ~isfield(cfg,'testGroup')
    cfg.testGroup = 'hd';
end


