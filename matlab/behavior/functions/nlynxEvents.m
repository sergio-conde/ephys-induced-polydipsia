function nlynxBeh = nlynxEvents(cfg)

% events = event_times(cfg)
% event_times extracts the cue and events (e.g. lick, head entry) times.
% All times were originally in msec in the nlynx files. Here they are
% stracted and stored in seconds.
% It is used in behavior_time.m

TOSECONDS = 1e-6;

% read .eve file
evData = ft_read_event_tara(cfg.file);

% if there is a problem with the neuralynx .eve file
if isempty(evData)
    nlynxBeh = forceMedpcBehavior(cfg.id);
    return
end

nlynxBeh.cfg = cfg;
evLabels = {evData(:).string};

% remove extra TTL triggers
ttlEvents = cellfun(@(x) strfind(x,'TTL'), evLabels,'UniformOutput',false);
ttlIdx = cellfun(@isempty,ttlEvents);
evData(~ttlIdx) = []; % clean event data
evLabels(~ttlIdx) = []; % clean event labels

% extract events from input struct
pelletEvents = find(cellfun(@(x) strcmp(x,'pellet'),evLabels));
preSessionEvents = find(cellfun(@(x) strcmp(x,'start/end (pre)session'),evLabels));
cueEvents = find(cellfun(@(x) strcmp(x,'cue on/off'),evLabels));  % extract cue on and off triggers:

[nlynxBeh.labels,~,nlynxBeh.sequence] = unique(evLabels); % store event labels
nlynxBeh.eventTimes = double([evData(:).timestamp]) * TOSECONDS; % trigger times sequence

% extract pre-session timestamps
nlynxBeh.trigger.pre = preSessionEvents;
preTimes = double([evData(nlynxBeh.trigger.pre).timestamp]) * TOSECONDS;
if length(nlynxBeh.trigger.pre) == 3
    nlynxBeh.timeStamps.pre = preTimes; % pre session trigger times
elseif length(nlynxBeh.trigger.pre) == 2
    if diff(preTimes) > 600 % 10 minutes
      nlynxBeh.timeStamps.pre = [nan preTimes];
    else
      nlynxBeh.timeStamps.pre = [preTimes nan]; 
    end
else
    if preTimes > 600
        nlynxBeh.timeStamps.pre = [nan nan preTimes];
    else
        nlynxBeh.timeStamps.pre = [nan nan nan]; 
    end
end

% extract cue timestamps (there are different originial strings to mark
% cues in the neuralynx files)
if ~isempty(cueEvents)
    eventIntervals = diff(double([evData(cueEvents).timestamp]) * TOSECONDS);   % compute time between triggers
    % ideally, cue triggers should be paired (on-off). However, there are
    % different strategies trhoughtout the sessions to mark the end 
    % of the cue presentation in the .nev files. 
    % This if is ment to deal with that.
    if mean(eventIntervals(1:2:end)) > 6 % unpaired labeling 
        nlynxBeh.trigger.cueOn = cueEvents;
        nlynxBeh.trigger.cueOff = pelletEvents;
    else    % paired labeling
        nlynxBeh.trigger.cueOn = cueEvents(1:2:end);
        nlynxBeh.trigger.cueOff = cueEvents(2:2:end);
    end
else
    nlynxBeh.trigger.cueOn = find(cellfun(@(x) strcmp(x,'cue on'),evLabels));
    nlynxBeh.trigger.cueOff = pelletEvents;
end
cueOnTimeStamps = [evData(nlynxBeh.trigger.cueOn).timestamp];
nlynxBeh.timeStamps.cue = double(cueOnTimeStamps) * TOSECONDS; % cue On timeStamps

% extract behavior events timestamps and bouts
for ievent = 1:length(cfg.events)
    localEvent = cfg.events{ievent};   % event label
   
    nlynxBeh.eventID.([localEvent 'ID']) = find(cellfun(@(x) strcmp(x,localEvent),nlynxBeh.labels));
    nlynxBeh.trigger.(localEvent) = find(cellfun(@(x) strcmp(x,localEvent),evLabels));
    nlynxBeh.timeStamps.(localEvent) = double([evData(nlynxBeh.trigger.(localEvent)).timestamp]) * TOSECONDS;

    if ~isempty(nlynxBeh.timeStamps.(localEvent))
        boutList = extractBouts(nlynxBeh.timeStamps.(localEvent), ...
                cfg.interBout(ievent), ...
                cfg.minBoutDur(ievent));
        nlynxBeh.bout.(localEvent).start  = boutList.boutStart;
        nlynxBeh.bout.(localEvent).duration = boutList.duration;
        nlynxBeh.bout.(localEvent).triggCount = boutList.triggCount; 
    else
        nlynxBeh.bout.(localEvent).start = [];
        nlynxBeh.bout.(localEvent).duration = [];
        nlynxBeh.bout.(localEvent).triggCount = [];
    end    
end
nlynxBeh.fileType = 'nev';