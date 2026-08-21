function ids = getID(dataInfo,varargin)

% ids = getId(dataInfo,exclLevel) gets the ids from any table of indexed
% struct containing files lists, indexed data, etc. 
%
% dataInfo - table or struct
% exclLevel - level to be excluded
%
% Schedule-Induced Polydipsia project. 
% Sergio Conde-Ocazionez, August 2026. 
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.


outType = 'table';

dataFields = fieldnames(dataInfo);
idFields = dataFields(contains(dataFields,'ID'));

if nargin > 1
    idFields = setdiff(idFields,varargin{1},'stable');
    if nargin > 2
        outType = varargin{2};
    end
end

if isstruct(dataInfo)
    dataInfo = struct2table(dataInfo);
end

[~, idx] = unique(dataInfo(:,idFields),"rows","stable");
ids = dataInfo(idx,idFields);

switch outType
    case 'struct'
        ids = table2struct(ids);
end
