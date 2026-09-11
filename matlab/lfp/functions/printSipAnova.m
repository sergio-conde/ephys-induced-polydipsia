
function printSipAnova(summaryAnova)

% Extract significant results from summaryAnova struct and print them on
% the command window

sessInteraction = [];
switch summaryAnova(1).model
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