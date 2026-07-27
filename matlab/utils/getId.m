function ids = getId(dataInfo,exclLevel)

dataFields = fieldnames(dataInfo);
idFields = dataFields(contains(dataFields,'_id'));

refLevels = setdiff(idFields,exclLevel,'stable');

structFlag = false;
if isstruct(dataInfo)
    dataInfo = struct2table(dataInfo);
    structFlag = true;
end

[~, idx] = unique(dataInfo(:,refLevels),"rows","stable");
ids = dataInfo(idx,refLevels);

if structFlag
    ids = table2struct(ids);
end
