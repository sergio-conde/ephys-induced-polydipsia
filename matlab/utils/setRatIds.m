function ratIds = setRatIds(groupFile)

% ratIds = setRatIds(groupFile)
%
% setRatIds returns the default ID definition for each animal, including
% their classification into high / low drinkers 
%
% Sergio Conde-Ocazionez, August 2024. 
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.


selRats  = {[1 2],[1 2],1,1:6,2:6}; % selected rats rom each cohort

nRats = length([selRats{:}]);
ratIds = cell2table(cell(nRats,4),...
    "VariableNames",{'label','tag_id','cohort_id','animal_id'});

ratTag = 1;
for icohort = 1:length(selRats)
    for irat = 1:length(selRats{icohort})
        ratIds.label{ratTag} = sprintf('C%iW0%i',...
            icohort,selRats{icohort}(irat));
        ratIds.tag_id{ratTag} = ratTag;
        ratIds.cohort_id{ratTag} = icohort;
        ratIds.animal_id{ratTag} = selRats{icohort}(irat);
        ratTag = ratTag + 1;
    end
end

if nargin > 0
    load(groupFile,'drinkGroup')
    ratIds.drink_id = drinkGroup.id;
    ratIds.drink_gr = drinkGroup.label;
end