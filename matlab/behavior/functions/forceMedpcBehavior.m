function fileData = forceMedpcBehavior(fileIDs)

sip = sipConfig('behavior');
load(fullfile(sip.folder.support,'\rawFilesList.mat'),"behMedFiles");

cfg = sip.medpc;
cfg.id = fileIDs;
cfg.file = getEntry(behMedFiles,fileIDs);
if ~isempty(cfg.file)
    fileData = medEvents(cfg);
else
    fileData.cfg = cfg;
end