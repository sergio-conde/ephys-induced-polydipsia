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
ratIds = table('Size',[nRats 4],...
    'Variabletypes',["string" "double" "double" "double"],...
    'Variablenames',{'label','tagID','cohortID','animalID'});

ratTag = 1;
for icohort = 1:length(selRats)
    for irat = 1:length(selRats{icohort})
        ratIds.label{ratTag} = sprintf('C%iW0%i',...
            icohort,selRats{icohort}(irat));
        ratIds.tagID(ratTag) = ratTag;
        ratIds.cohortID(ratTag) = icohort;
        ratIds.animalID(ratTag) = selRats{icohort}(irat);
        ratTag = ratTag + 1;
    end
end
ratIds.Properties.VariableTypes(1) = "categorical";

if nargin > 0
    load(groupFile,'drinkGroup')
    ratIds.drinkID = drinkGroup.id;
    ratIds.drinkLabel = categorical(drinkGroup.label);
end

