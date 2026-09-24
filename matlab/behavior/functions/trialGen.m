function [trl,trlList] = trialGen(cfg)

% This function establishes the trials based on woi, entire sip trials or
% entire session

if ~isfield(cfg,'offset')
    cfg.offset = 0;
end
if ~isfield(cfg,'lickEnd')
    cfg.lickEnd = false;
end

% if isstruct(cfg.beh)
%     cfg.beh = struct2table(cfg.beh);
% end

if isnan(cfg.beh.taskEnd)
    cfg.beh.taskEnd = cfg.beh.endTime;
end

if isnan(cfg.beh.taskStart)
    cfg.beh.taskStart = cfg.beh.startTime;
end

[~,woiList] = sipWoi(cfg);
cueInfo   = trialList(woiList,cfg);
lickInfo  = woiList(strcmp(woiList.woiLabel,'lick'),:);

switch cfg.interval
    case 'woi'
        trlList = woiList;

    case 'sipTrial'
        lickInfo(lickInfo.trialID == 0,:) = []; % remove lick before first trial
        trialInfo = cueInfo;
        trialInfo.timeEnd(1:end-1) = trialInfo.timeStart(2:end);
        trialInfo.timeEnd(end) = cfg.beh.taskEnd * 1e6;
        trialInfo.timeStart = trialInfo.timeStart + cfg.offset;
        trialInfo.sampleStart = (trialInfo.timeStart - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trialInfo.sampleEnd = (trialInfo.timeEnd - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trialInfo.duration = trialInfo.timeEnd - trialInfo.timeStart;
        trialInfo.woiID(:) = 0;
        trialInfo.drink(lickInfo.trialID) = true;
        trialInfo.end_flag(:) = false;
        trlList = trialInfo;

    case 'lick'

        lickInfo(lickInfo.trialID == 0,:)  = []; % remove lick before first trial
        lickInfo(lickInfo.nwoi_tr > 1,:)    = []; % take only first lick

        lickInfo.latency     = lickInfo.timeStart - cueInfo.timeStart(lickInfo.trialID);
        lickInfo.drink(:)    = true;
        lickInfo.end_flag(:) = false;

        if cfg.lickEnd
            endList              = lickInfo;
            endList.drink(:)     = true;
            endList.end_flag(:)  = true;
            endList.timeStart    = lickInfo.timeEnd;
            endList.timeEnd      = lickInfo.timeEnd + abs(cfg.offset);
            endList.sample_start = (endList.timeStart - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            endList.sample_end   = (endList.timeEnd - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            endList.duration     = endList.timeEnd - endList.timeStart;
            endList.woiID(:)     = 3;
            endList.woiLabel(:)  = repmat({"lick"}, height(endList), 1);
            endList.latency(:)   = endList.timeStart - cueInfo.timeStart(endList.trialID);

            lMinusEnd              = cueInfo(setdiff(cueInfo.trialID,lickInfo.trialID),:);
            lMinusEnd.drink(:)     = false;
            lMinusEnd.end_flag(:)  = true;
            lMinusEnd.timeStart      = lMinusEnd.timeStart + mean(lickInfo.latency) + mean(lickInfo.duration);
            lMinusEnd.timeEnd        = lMinusEnd.timeStart + max(lickInfo.duration);
            lMinusEnd.sample_start = (lMinusEnd.timeStart - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            lMinusEnd.sample_end   = (lMinusEnd.timeEnd - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            lMinusEnd.duration     = lMinusEnd.timeEnd - lMinusEnd.timeStart;
            lMinusEnd.woiID(:)    = 3;
            lMinusEnd.woiLabel(:) = repmat({"lick"}, height(lMinusEnd), 1);
            lMinusEnd.latency(:)   = mean(lickInfo.latency);
       else
           endList    = [];
           lMinusEnd  = [];
       end

        lMinus = cueInfo(setdiff(cueInfo.trialID,lickInfo.trialID),:);
        lMinus.end_flag(:) = false;
        lMinus.timeStart = lMinus.timeStart + mean(lickInfo.latency);
        lMinus.timeEnd = lMinus.timeStart + max(lickInfo.duration);
        lMinus.sample_start = (lMinus.timeStart - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        lMinus.sample_end = (lMinus.timeEnd - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        lMinus.duration = lMinus.timeEnd - lMinus.timeStart;
        lMinus.woiID(:) = 3;
        lMinus.woiLabel(:) = repmat({"lick"}, height(lMinus), 1);
        lMinus.latency(:) = mean(lickInfo.latency);

        trlList = [lickInfo;endList;lMinus;lMinusEnd];
        % trlList = sortrows(trlList,"timeStart","ascend");

    otherwise
        error('Invalid requested interval')
end

trl        = [trlList.timeStart trlList.timeEnd];
trl(end,3) = 0;

end

function trialInfo = trialList(woiList,cfg)

trialInfo                = woiList(strcmp(woiList.woiLabel,'cue'),:);
trialInfo.timeEnd(1:end-1) = trialInfo.timeStart(2:end);
trialInfo.timeEnd(end)     = cfg.beh.taskEnd;
trialInfo.sample_end     = (trialInfo.timeEnd - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
trialInfo.duration       = trialInfo.timeEnd - trialInfo.timeStart;
trialInfo.woiID(:)      = 10;
trialInfo.woiLabel(:)   = repmat({"trial"}, height(trialInfo), 1);
trialInfo.drink(:)       = false;

end

