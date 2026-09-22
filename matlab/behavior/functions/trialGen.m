function [trl,trlList] = trialGen(cfg)

% This function establishes the trials based on woi, entire sip trials or
% entire session

if ~isfield(cfg,'offset')
    cfg.offset = 0;
end
if ~isfield(cfg,'lickEnd')
    cfg.lickEnd = false;
end

if isnan(cfg.beh.taskEnd)
    cfg.beh.taskEnd = cfg.beh.end;
end

if isnan(cfg.beh.taskStart)
    cfg.beh.taskStart = cfg.beh.start;
end

[~,woiList] = sipWoi(cfg);
cueInfo   = trialList(woiList,cfg);
lickInfo  = woiList(strcmp(woiList.woi_label,'lick'),:);

switch cfg.interval
    case 'woi'
        trlList = woiList;
    case 'sip_trial'
        lickInfo(lickInfo.trial_id == 0,:)   = []; % remove lick before first trial
        trialInfo                            = cueInfo;
        trialInfo.t_end(1:end-1)             = trialInfo.t_start(2:end);
        trialInfo.t_end(end)                 = cfg.beh.taskEnd * 1e6;
        trialInfo.t_start                    = trialInfo.t_start + cfg.offset;
        trialInfo.sample_start               = (trialInfo.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trialInfo.sample_end                 = (trialInfo.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trialInfo.duration                   = trialInfo.t_end - trialInfo.t_start;
        trialInfo.woi_id(:)                  = 0;
        trialInfo.drink(lickInfo.trial_id)   = true;
        trialInfo.end_flag(:)                = false;
        trlList                              = trialInfo;

    case 'lick'

        lickInfo(lickInfo.trial_id == 0,:)  = []; % remove lick before first trial
        lickInfo(lickInfo.nwoi_tr > 1,:)    = []; % take only first lick

        lickInfo.latency     = lickInfo.t_start - cueInfo.t_start(lickInfo.trial_id);
        lickInfo.drink(:)    = true;
        lickInfo.end_flag(:) = false;

       if cfg.lickEnd
            endList              = lickInfo;
            endList.drink(:)     = true;
            endList.end_flag(:)  = true;
            endList.t_start      = lickInfo.t_end;
            endList.t_end        = lickInfo.t_end + abs(cfg.offset);
            endList.sample_start = (endList.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            endList.sample_end   = (endList.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            endList.duration     = endList.t_end - endList.t_start;
            endList.woi_id(:)    = 3;
            endList.woi_label(:) = repmat({"lick"}, height(endList), 1);
            endList.latency(:)   = endList.t_start - cueInfo.t_start(endList.trial_id);

            lMinusEnd              = cueInfo(setdiff(cueInfo.trial_id,lickInfo.trial_id),:);
            lMinusEnd.drink(:)     = false;
            lMinusEnd.end_flag(:)  = true;
            lMinusEnd.t_start      = lMinusEnd.t_start + mean(lickInfo.latency) + mean(lickInfo.duration);
            lMinusEnd.t_end        = lMinusEnd.t_start + max(lickInfo.duration);
            lMinusEnd.sample_start = (lMinusEnd.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            lMinusEnd.sample_end   = (lMinusEnd.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            lMinusEnd.duration     = lMinusEnd.t_end - lMinusEnd.t_start;
            lMinusEnd.woi_id(:)    = 3;
            lMinusEnd.woi_label(:) = repmat({"lick"}, height(lMinusEnd), 1);
            lMinusEnd.latency(:)   = mean(lickInfo.latency);
       else
           endList    = [];
           lMinusEnd  = [];
       end

        lMinus              = cueInfo(setdiff(cueInfo.trial_id,lickInfo.trial_id),:);
        lMinus.end_flag(:)  = false;
        lMinus.t_start      = lMinus.t_start + mean(lickInfo.latency);
        lMinus.t_end        = lMinus.t_start + max(lickInfo.duration);
        lMinus.sample_start = (lMinus.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        lMinus.sample_end   = (lMinus.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        lMinus.duration     = lMinus.t_end - lMinus.t_start;
        lMinus.woi_id(:)    = 3;
        lMinus.woi_label(:) = repmat({"lick"}, height(lMinus), 1);
        lMinus.latency(:)   = mean(lickInfo.latency);

        trlList = [lickInfo;endList;lMinus;lMinusEnd];
        % trlList = sortrows(trlList,"t_start","ascend");

    otherwise
        error('Invalid requested interval')
end

trl        = [trlList.t_start trlList.t_end];
trl(end,3) = 0;

end

function trialInfo = trialList(woiList,cfg)

trialInfo                = woiList(strcmp(woiList.woi_label,'cue'),:);
trialInfo.t_end(1:end-1) = trialInfo.t_start(2:end);
trialInfo.t_end(end)     = cfg.beh.taskEnd;
trialInfo.sample_end     = (trialInfo.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
trialInfo.duration       = trialInfo.t_end - trialInfo.t_start;
trialInfo.woi_id(:)      = 10;
trialInfo.woi_label(:)   = repmat({"trial"}, height(trialInfo), 1);
trialInfo.drink(:)       = false;

end

