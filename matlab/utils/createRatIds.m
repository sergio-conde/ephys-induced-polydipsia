function ratIds = setRatIds(groupFile)




selRats  = {[1 2],[1 2],1,1:6,2:6}; % selected rats rom each cohort
ratIds   = zeros(0,2);
for icohort = 1:5
    for irat = 1:length(selRats{icohort})
        ratIds = cat(1,ratIds,...
            [icohort selRats{icohort}(irat)]);
    end
end
nRats = size(ratIds,1);
ratLabels = cell(nRats,1);
for irat = 1:nRats
    ratLabels{irat} = sprintf('C%iW0%i',ratIds(irat,1),ratIds(irat,2));
end

% drinkGroup is a file created with behavior_grouping, resulting from
% clustering of animal behavior.
load(groupFile)

ratIds = [ratLabels num2cell([(1:nRats)' ratIds drinkGroup.id]) drinkGroup.label];
ratIds = cell2table(ratIds,'VariableNames',...
    {'label','tag_id','cohort_id','animal_id','drink_id','drink_gr'});