function testData = formatSipAnova(cfg)

testEpochs = {'PreCue','Cue','PreLick','Lick','PostLick'};
strVarCode = strcat(cfg.testBand,cfg.testQuant);
switch cfg.model
    case {'mixed','repeated'}
        [cfg.testPsd, ~, dataVariables] = basedData(cfg.testPsd,cfg.based,3);
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
            localData = getEntry(localData,'group',cfg.testGroup);
            [localData, idVariables, dataVariables] = basedData(localData,cfg.based,2);
            testVarFlags = cellfun(@(x) contains(x,strVarCode),dataVariables);
            localData = localData(:,[idVariables dataVariables{testVarFlags}]);
            localData.Properties.VariableNames(3:end) = localLabels;
            sessData.(localSession) = localData;
        end
        testData = alignEarlyLate(sessData);
end

function [data, idVariables, dataVariables] = basedData(data,base,nIds)
idVariables = data.Properties.VariableNames(1:nIds);
inputVariables = data.Properties.VariableNames(5:end);
switch base
    case 'animal'
        data = groupsummary(data,idVariables, ...
            @(x)mean(x,'omitmissing'),inputVariables);
        dataVariables = data.Properties.VariableNames(5:end);
    case 'session'
        dataVariables = inputVariables;
    otherwise
        errorMsg = sprintf('\n--> cfg.based must be "animal" or "session"\n');
        error(errorMsg)
end

% Take the same number of data points from early and late sessions. This is
% only relevant if session-based anova is chosen
function testData = alignEarlyLate(sessData)

tags = unique([sessData.early.tagID;sessData.late.tagID])';
keepEarly = []; 
keepLate = [];
for itag = tags
    nEarly = find(sessData.early.tagID == itag);
    nLate = find(sessData.late.tagID == itag);
    minN = min(numel(nEarly),numel(nLate));
    keepEarly = cat(1,keepEarly,nEarly(randperm(numel(nEarly),minN)));
    keepLate = cat(1,keepLate,nLate(randperm(numel(nLate),minN)));
end
sessData.early = sessData.early(keepEarly,:);
sessData.late = sessData.late(keepLate,:);
testData = cat(2,sessData.early,sessData.late(:,3:7));