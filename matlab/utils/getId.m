function ids = getID(dataInfo,varargin)

% ids = getID(dataInfo) gets the ids from any table or indexed struct
% containing file lists, indexed data, etc. All variable names
% containing 'ID' are treated as id columns.
%
% ids = getID(dataInfo,exclude,idCoding,outType) or
% ids = getID(dataInfo,cfg), with cfg a struct with the fields below,
% lets you customize the id extraction.
%
% dataInfo  - table or struct containing (at least) the id columns
% exclude   - id field name(s) to exclude from the output (default: '')
% idCoding  - substring used to identify id columns in dataInfo
%             (default: 'ID')
% outType   - 'table' (default) or 'struct', output format
%
% Schedule-Induced Polydipsia project.
% Sergio Conde-Ocazionez, August 2026.
% Neuromodulation & Behavior Laboratory
% Netherlands Institute for Neuroscience.

if ~istable(dataInfo) && ~isstruct(dataInfo)
    error('getID:invalidDataInfo','dataInfo must be a table or a struct.')
end

cfg = checkCfg(varargin);

if isstruct(dataInfo)
    dataInfo = struct2table(dataInfo);
end
dataFields = dataInfo.Properties.VariableNames;
idFields = dataFields(contains(dataFields,cfg.idCoding));
if isempty(idFields)
    error('getID:noIdFields', ...
        'No fields matching id pattern ''%s'' were found in dataInfo.',cfg.idCoding)
end
if ~isempty(cfg.exclude)
    idFields = setdiff(idFields,cfg.exclude,'stable');
    if isempty(idFields)
        error('getID:allIdFieldsExcluded', ...
            'All id fields were excluded; nothing left to index by.')
    end
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
    cfg = fillDefaults(cfg);
elseif ischar(ogVars{1})
    if nVars > 3
        error('getID:tooManyInputs','\n--> Too many input parameters <--\n')
    end
    for iVar = nVars+1:3
        ogVars{iVar} = [];
    end
    cfg.exclude = ogVars{1};
    cfg.idCoding = ogVars{2};
    cfg.outType = ogVars{3};
    cfg = fillDefaults(cfg);
else
    error('getID:invalidInput', ...
        'Optional input must be a config struct, or exclude/idCoding/outType as char arrays.')
end

function cfg = fillDefaults(cfg)
defaultFields = {'exclude','idCoding','outType'};
defaultVals = {'','ID','table'};
for iField = 1:numel(defaultFields)
    f = defaultFields{iField};
    if ~isfield(cfg,f) || isempty(cfg.(f))
        cfg.(f) = defaultVals{iField};
    end
end