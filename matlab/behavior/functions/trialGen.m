function [trl,trl_list] = trialGen(cfg)

% This function establishes the trials based on woi, entire sip trials or
% entire session

if ~isfield(cfg,'offset')
    cfg.offset = 0;
end
if ~isfield(cfg,'lick_end')
    cfg.lick_end = false;
end

if isnan(cfg.beh.task_end)
    cfg.beh.task_end = cfg.beh.end;
end

if isnan(cfg.beh.task_start)
    cfg.beh.task_start = cfg.beh.start;
end

[~,woi_list] = sip_woi(cfg);
cue_info   = trial_list(woi_list,cfg);
lick_info  = woi_list(strcmp(woi_list.woi_label,'lick'),:);

switch cfg.interval
    case 'woi'
        trl_list = woi_list;
    case 'sip_trial'
        lick_info(lick_info.trial_id == 0,:)    = []; % remove lick before first trial
        trial_info                              = cue_info;
        trial_info.t_end(1:end-1)               = trial_info.t_start(2:end);
        trial_info.t_end(end)                   = cfg.beh.task_end * 1e6;
        trial_info.t_start                      = trial_info.t_start + cfg.offset;
        trial_info.sample_start                 = (trial_info.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trial_info.sample_end                   = (trial_info.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        trial_info.duration                     = trial_info.t_end - trial_info.t_start;
        trial_info.woi_id(:)                    = 0;
        trial_info.drink(lick_info.trial_id)    = true;
        trial_info.end_flag(:)                  = false;
        trl_list                                = trial_info;

    case 'lick'

        lick_info(lick_info.trial_id == 0,:)  = []; % remove lick before first trial
        lick_info(lick_info.nwoi_tr > 1,:)    = []; % take only first lick

        lick_info.latency     = lick_info.t_start - cue_info.t_start(lick_info.trial_id);
        lick_info.drink(:)    = true;
        lick_info.end_flag(:) = false;

       if cfg.lick_end 
            end_list              = lick_info;
            end_list.drink(:)     = true;
            end_list.end_flag(:)  = true;
            end_list.t_start      = lick_info.t_end;
            end_list.t_end        = lick_info.t_end + abs(cfg.offset);
            end_list.sample_start = (end_list.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            end_list.sample_end   = (end_list.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            end_list.duration     = end_list.t_end - end_list.t_start;
            end_list.woi_id(:)    = 3;
            end_list.woi_label(:) = repmat({"lick"}, height(end_list), 1);
            end_list.latency(:)   = end_list.t_start - cue_info.t_start(end_list.trial_id);

            l_minus_end              = cue_info(setdiff(cue_info.trial_id,lick_info.trial_id),:);
            l_minus_end.drink(:)     = false;
            l_minus_end.end_flag(:)  = true;
            l_minus_end.t_start      = l_minus_end.t_start + mean(lick_info.latency) + mean(lick_info.duration);
            l_minus_end.t_end        = l_minus_end.t_start + max(lick_info.duration);
            l_minus_end.sample_start = (l_minus_end.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            l_minus_end.sample_end   = (l_minus_end.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
            l_minus_end.duration     = l_minus_end.t_end - l_minus_end.t_start;
            l_minus_end.woi_id(:)    = 3;
            l_minus_end.woi_label(:) = repmat({"lick"}, height(l_minus_end), 1);
            l_minus_end.latency(:)   = mean(lick_info.latency);
       else
           end_list     = [];
           l_minus_end  = [];
       end

        l_minus              = cue_info(setdiff(cue_info.trial_id,lick_info.trial_id),:);
        l_minus.end_flag(:)  = false;
        l_minus.t_start      = l_minus.t_start + mean(lick_info.latency);
        l_minus.t_end        = l_minus.t_start + max(lick_info.duration);
        l_minus.sample_start = (l_minus.t_start - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        l_minus.sample_end   = (l_minus.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
        l_minus.duration     = l_minus.t_end - l_minus.t_start;
        l_minus.woi_id(:)    = 3;
        l_minus.woi_label(:) = repmat({"lick"}, height(l_minus), 1);
        l_minus.latency(:)   = mean(lick_info.latency);

        trl_list = [lick_info;end_list;l_minus;l_minus_end];
        % trl_list = sortrows(trl_list,"t_start","ascend");

    otherwise
        error('Invalid requested interval')
end

trl        = [trl_list.t_start trl_list.t_end];
trl(end,3) = 0;

end

function trial_info = trial_list(woi_list,cfg)

trial_info                = woi_list(strcmp(woi_list.woi_label,'cue'),:);
trial_info.t_end(1:end-1) = trial_info.t_start(2:end);
trial_info.t_end(end)     = cfg.beh.task_end;
trial_info.sample_end     = (trial_info.t_end - double(cfg.header.FirstTimeStamp))./cfg.header.TimeStampPerSample + 1;
trial_info.duration       = trial_info.t_end - trial_info.t_start;
trial_info.woi_id(:)      = 10;
trial_info.woi_label(:)   = repmat({"trial"}, height(trial_info), 1);
trial_info.drink(:)       = false;

end

