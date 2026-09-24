
clear; clc
ft_defaults                                           

sip = sipConfig('behavior');
fileList = sipFileList(sip.folder.support,'behavior');

%%

iline = 1;
for ifile = 1:numel(fileList.behavior)
    localFile = fileList.behavior(ifile).filePath;
    localIds = getID(fileList.behavior(ifile));
    switch fileList.behavior(ifile).fileType
        case 'eveNlynx'
            cfg = sip.nlynx;
            cfg.file = localFile;
            cfg.id = localIds;
            fileData = nlynxEvents(cfg);
        case 'medpc'
            cfg = sip.medpc;
            cfg.file = localFile;
            cfg.id = localIds;
            fileData = medEvents(cfg);
    end
    fileData.id = getID(fileList.behavior(ifile));
    if isfield(fileData,'eventTimes')
        behavior(iline) = formatBehavior(fileData);

        % include water intake
        % water = [];
        % water.id = localIds;
        % water.file = waterFiles(water.id.cohortID).filePath;
        % behavior(iline).waterIntake = getWaterIntake(localIds);

        iline = iline + 1;
    end
end
% save('M:\GitHub\ephys-induced-polydipsia\example_data\behavior\behavior.mat',"behavior")


