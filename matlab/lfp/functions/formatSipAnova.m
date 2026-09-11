function testData = formatSipAnova(cfg)

testEpochs = {'PreCue','Cue','PreLick','Lick','PostLick'};
strVarCode = strcat(cfg.testBand,cfg.testQuant);
switch cfg.model
    case {'mixed','repeated'}
        idVariables = cfg.testPsd.Properties.VariableNames(1:3);
        inputVariables = cfg.testPsd.Properties.VariableNames(5:end);
        switch cfg.based
            case 'animal'
                cfg.testPsd = groupsummary(cfg.testPsd,idVariables, ...
                    @(x)mean(x,'omitmissing'),inputVariables);
                dataVariables = cfg.testPsd.Properties.VariableNames(5:end);
            case 'session'
                dataVariables = inputVariables;
            otherwise
                errorMsg = sprintf('\n--> cfg.based must be "animal" or "session"\n');
                error(errorMsg)
        end
        % ANOVA data selection
        testVarFlags = cellfun(@(x) contains(x,strVarCode),dataVariables);
        testVariables = dataVariables(testVarFlags);
        % ANOVA data format
        testData = cfg.testPsd(:,['rat','group',testVariables]);
        testData.Properties.VariableNames = ['Rat','Group',testEpochs];
        testData.Group = categorical(testData.Group);
        % ----- PSD data selection and formatting ----- %

    case 'earlyLate'
        sessions = {'early','late'};
        for isession = 1:2
            localSession = sessions{isession};
            sessLabel = [upper(localSession(1)) localSession(2:end)];
            localLabels = cellfun(@(x)strcat(x,sessLabel),testEpochs, ...
                'UniformOutput',false);

            localData = cfg.testPsd.(localSession).(cfg.testArea)(:,1:104);
            idVariables = localData.Properties.VariableNames(1:2);
            inputVariables = localData.Properties.VariableNames(5:end);
            localData = getEntry(localData,'group',cfg.testGroup);
            localData = groupsummary(localData,idVariables, ...
                @(x)mean(x,'omitmissing'),inputVariables);
            dataVariables = localData.Properties.VariableNames(4:end);
            testVarFlags = cellfun(@(x) contains(x,strVarCode),dataVariables);
            localData = localData(:,[idVariables dataVariables{testVarFlags}]);
            localData.Properties.VariableNames(3:end) = localLabels;
            sessData.(localSession) = localData;
        end
        testData = innerjoin(sessData.early,sessData.late,'Keys','rat');
        testData.Properties.VariableNames(1:2) = idVariables;
        testData(:,8) = [];
end
