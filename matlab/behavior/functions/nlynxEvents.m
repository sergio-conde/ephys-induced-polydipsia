function nlynxBehavior = nlynxEvents(cfg)

% events = event_times(cfg)
% event_times extracts the cue and events (e.g. lick, head entry) times.
% All times were originally in msec in the nlynx files. Here they are
% stracted and stored in seconds.
% It is used in behavior_time.m

%%
nlynxBehavior.cfg = cfg;
ev_data = cfg.data;

%--------------------- removing TTL extra triggers -----------------------------------%
ttl_entries = cellfun(@(x) strfind(x,'TTL'),{ev_data(:).string},'UniformOutput',false);
ttl_entries_idx = cellfun(@isempty,ttl_entries);
ev_data(~ttl_entries_idx) = [];
%--------------------- removing TTL extra triggers -----------------------------------%


evLabels = {ev_data(:).string};
[nlynxBehavior.labels,~,nlynxBehavior.sequence] = unique(evLabels);                          % extract event labels
cue_triggers = find(cellfun(@(x) strcmp(x,'cue on/off'),{ev_data(:).string}));  % extract cue on and off triggers:

if ~isempty(cue_triggers)

    trigger_intervals = diff(double([ev_data(cue_triggers).timestamp])*1e-6);   % compute time between triggers

    % ideally, cue triggers should be paired (on-off). However, there are
    % different strategies trhoughtout th sessions of signalizing the end 
    % of the cue presentation in the .nev files. 
    % This if is ment to deal with that.
    
    if mean(trigger_intervals(1:2:end)) > 6 % unpaired labeling 
        nlynxBehavior.trigger.cue_on   = cue_triggers;
        nlynxBehavior.trigger.cue_off  = find(cellfun(@(x) strcmp(x,'pellet'),evLabels));
    else    % paired labeling
        nlynxBehavior.trigger.cue_on   = cue_triggers(1:2:end);
        nlynxBehavior.trigger.cue_off  = cue_triggers(2:2:end);
    end
else
    nlynxBehavior.trigger.cue_on   = find(cellfun(@(x) strcmp(x,'cue on'),evLabels));
    nlynxBehavior.trigger.cue_off  = find(cellfun(@(x) strcmp(x,'pellet'),evLabels));
end

nlynxBehavior.trigger.pre = find(cellfun(@(x) strcmp(x,'start/end (pre)session'),evLabels));
pre_times          = double([ev_data(nlynxBehavior.trigger.pre).timestamp])*1e-6;
if length(nlynxBehavior.trigger.pre) == 3
    nlynxBehavior.trig_time.pre = pre_times; % pre session trigger times
elseif length(nlynxBehavior.trigger.pre) == 2
    if diff(pre_times) > 600 % 10 minutes
      nlynxBehavior.trig_time.pre = [nan pre_times];
    else
      nlynxBehavior.trig_time.pre = [pre_times nan]; 
    end
else
    if pre_times > 600
        nlynxBehavior.trig_time.pre = [nan nan pre_times];
    else
        nlynxBehavior.trig_time.pre = [nan nan nan]; 
    end
end
% events.trigger.pre = find(cellfun(@(x) strcmp(x,'start/end (pre)session'),ev_labels));
% if length(events.trigger.pre) == 3
%     events.trig_time.pre = double([ev_data(events.trigger.pre).timestamp])*1e-6; % pre session trigger times
% else
%     events.trig_time.pre = [-1 -1 -1];
% end


nlynxBehavior.trig_time.cue_on = double([ev_data(nlynxBehavior.trigger.cue_on).timestamp])*1e-6; % cue presentation times
for ievent = 1:length(cfg.events)
    local_event = cfg.events{ievent};   % event label

    nlynxBehavior.event_id.([local_event '_id'])   = find(cellfun(@(x) strcmp(x,local_event),nlynxBehavior.labels));
    nlynxBehavior.trigger.(local_event)            = find(cellfun(@(x) strcmp(x,local_event),evLabels));
    nlynxBehavior.trig_time.(local_event)          = double([ev_data(nlynxBehavior.trigger.(local_event)).timestamp]) * 1e-6;

    ev_times    = nlynxBehavior.trig_time.(local_event);

    if ~isempty(ev_times)

        diff_event  = [cfg.inter_bout(ievent) + 1 diff(ev_times)] > cfg.inter_bout(ievent);
        start_times = ev_times(diff_event);
        end_times   = ev_times([diff_event(2:end) true]);
        duration    = end_times - start_times;
        trigg_count = diff(find([diff_event true]));

        trigg_count(duration < cfg.min_dur(ievent)) = [];
        start_times(duration < cfg.min_dur(ievent)) = [];
        duration(duration < cfg.min_dur(ievent))    = [];
        

        nlynxBehavior.time.(local_event).start       = start_times;
        nlynxBehavior.time.(local_event).duration    = duration;
        nlynxBehavior.time.(local_event).trigg_count = trigg_count;
    else
        nlynxBehavior.time.(local_event).start       = [];
        nlynxBehavior.time.(local_event).duration    = [];
        nlynxBehavior.time.(local_event).trigg_count = [];
    end
    
end
nlynxBehavior.time_axis = double([ev_data(:).timestamp])*1e-6; % trigger times sequence
nlynxBehavior.beh_file = 'nev';