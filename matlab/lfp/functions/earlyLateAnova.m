

cfg.sessions = {'early','late'};

earlyLateData = [];
for isession = 1:2
    sessData = cfg.testPsd.(cfg.sessions{isession}).(cfg.testArea)(:,1:104);
    sessData = getEntry(sessData,'group',cfg.testGroup);
    sessData(:,'group') = sessions(isession);
    earlyLateData = cat(1,earlyLateData,sessData);
end
cfg.testPsd = earlyLateData;

cfg.testPsd = formatSipAnova(cfg);

anovaVars = cfg.testPsd.Properties.VariableNames(3:end);

%% Define the two within-subject factors

sessionLevels = repelem({'Early','Late'}, 5)';   % Early x5, Late x5
epochLevelsRep = repmat(epochLabels', numel(cfg.sessions), 1);    % epochs repeated per session

withinDesign = table(categorical(sessionLevels), categorical(epochLevelsRep), ...
    'VariableNames', {'Session','Epoch'});

% Fit the model — response variables must be in the SAME order as withinDesign2
formulaStr = sprintf('%s-%s ~ 1', anovaVars{1}, anovaVars{end});
rm = fitrm(cfg.testPsd, formulaStr, 'WithinDesign', withinDesign);

% Two-way repeated measures ANOVA: Session, Epoch, and their interaction
ranovatbl = ranova(rm, 'WithinModel', 'Session*Epoch');
disp(ranovatbl)

% Compare epochs within Early, and epochs within Late, separately
compWithinSession = multcompare(rm, 'Epoch', 'By', 'Session',...
    'ComparisonType','lsd');
disp(compWithinSession)

% Compare Early vs Late, separately for each epoch
compAcrossSession = multcompare(rm, 'Session', 'By', 'Epoch',...
    'ComparisonType','lsd');
disp(compAcrossSession)

% %% There are different number of early vs late sessions per animal. 
% % In order to test session based repeated measures, we need to take 
% 
% groupRats = unique([earlyData.rat;lateData.rat]);
% for irat = 1%:numel(groupRats)
%     earlyRat = earlyData(earlyData.rat == groupRats(irat),:);
%     validEarly = earlyRat{:,5} ~= 0 & ~isnan(earlyRat{:,5});
%     lateRat = lateData(lateData.rat == groupRats(irat),:);
%     validLate = lateRat{:,5} ~= 0 & ~isnan(lateRat{:,5});
% end