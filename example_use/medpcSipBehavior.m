
clear; clc                                
sip = sipConfig('behavior');
behaviorFiles = sipFileList(sip.folder.support,'behavior');

%% generating trial list

% ifile = 85;
ifile = 272;
cfg = sip.medpc;
cfg.medFile = behaviorFiles.medFiles(ifile).file_path;
trialStruct = getTrials(cfg);

%%

evConfig = [];
evConfig.events = {'lick','headEntry'};
evConfig.latency = true;
evConfig.firstEvent = true;
eventList = addEvent(trialStruct,evConfig);

%% Extract bouts from time stamps vector

iTrial = 42;
minInterval = 1;
minDuration = 2;

trialTimes = eventList.trials(iTrial).headEntryTimes;
boutList = extractBouts(trialTimes,minInterval,minDuration);
disp(boutList)

%% Add bouts to event struct

boutCfg.minDuration = [2 2];
boutCfg.minInterval = [1 1.5];

evConfig = [];
evConfig.events = {'lick','headEntry'};
evConfig.latency = true;
evConfig.firstEvent = true;
evConfig.bouts = boutCfg;   
eventList = addEvent(trialStruct,evConfig);

%% compute event histogram

selectCfg = [];
selectCfg.count = 31;
selectCfg.contrast.count = 'higher';

histCfg = [];
histCfg.events = 'headEntry';
histCfg.histBins = 0:5:40;
histCfg.select = selectCfg;
histCfg.plotFlag = true;
histCfg.figNumber = 2;
[histData,plotList] = eventHistogram(eventList,histCfg);
% ylim([0 40])

%% 

lfpList = sipFileList(sip.folder.support,'lfp');
fileIds = getID(behaviorFiles.medFiles(ifile));
% fix lfpList to use ID instead of _id
lfpFiles = lfpList(811:816);

%%

lfp = importdata(lfpFiles(1).file_path);
% add a config to cut by bouts and not by trials
% maybe create a new struct with all bouts concatenated including Ids and
% then run trialLfp
lfpStruct = trialLfp(lfp,behavior);
