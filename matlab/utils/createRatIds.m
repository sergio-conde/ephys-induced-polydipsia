




sel_rats  = {[1 2],[1 2],1,1:6,2:6};          % selected rats rom each cohort
rat_ids   = zeros(0,2);
for icoh = 1:5
    for irat = 1:length(sel_rats{icoh})
        rat_ids = cat(1,rat_ids,...
            [icoh sel_rats{icoh}(irat)]);
    end
end
rat_labels = cell(cfg.analysis.nrats,1);
for irat = 1:cfg.analysis.nrats
    rat_labels{irat} = sprintf('C%iW0%i',rat_ids(irat,1),rat_ids(irat,2));
end
load(fullfile(cfg.folder.proc,'animal_groups.mat'),"group")

drink_group = cell(cfg.analysis.nrats,1);
[drink_group{group.id == 1}] = deal('ld');
[drink_group{group.id == 2}] = deal('hd');

rat_ids =[rat_labels num2cell([(1:cfg.analysis.nrats)' rat_ids group.id]) drink_group];
rat_ids = cell2table(rat_ids,'VariableNames',...
    {'label','tag_id','cohort_id','animal_id','drink_id','drink_gr'});