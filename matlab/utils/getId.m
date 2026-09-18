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

cfg = checkCfg(varargin);

if isstruct(dataInfo)
    dataInfo = struct2table(dataInfo);
end
dataFields = dataInfo.Properties.VariableNames;
idFields = dataFields(contains(dataFields,cfg.idCoding));
if ~isempty(cfg.exclude)
    idFields = setdiff(idFields,cfg.exclude,'stable');
end

[~, idx] = unique(dataInfo(:,idFields),"rows","stable");
ids = dataInfo(idx,idFields);

switch cfg.outType
    case 'struct'
        ids = table2struct(ids);
end

% check input variables
function cfg = checkCfg(ogVars)
nVars = numel(ogVars);
if isempty(ogVars)
    cfg.exclude = '';
    cfg.idCoding = 'ID';
    cfg.outType = 'table';
    return
end
if isstruct(ogVars{1})
    cfg = ogVars{1};
elseif ischar(ogVars{1})
    if nVars < 3
        ogVars{3} = [];
    elseif nVars > 3
        errorMsg = sprintf('\n--> Too many input parameters <--\n');
        error(errorMsg)
    end
    cfg.exclude = ogVars{1};
    cfg.idCoding = ogVars{2};
    cfg.outType = ogVars{3};
    if isempty(cfg.idCoding)
        cfg.idCoding = 'ID';
    end
    if isempty(cfg.outType)
        cfg.outType = 'table';
    end
end


