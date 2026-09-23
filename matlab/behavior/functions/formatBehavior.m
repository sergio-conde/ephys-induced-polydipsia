function beh = formatBehavior(cfg)

% beh = format_behavior(events)
% format_behavior format the information from behavior files extracted
% using event_times function. See also behavior_time.m

%%
% include all ID fields 
idFields = cfg.id.Properties.VariableNames;
for ievent = 1:length(idFields)
    beh.(idFields{ievent}) = cfg.id.(idFields{ievent});
end

% include session information
beh.startTime = cfg.eventTimes(1); % start recording events (also video) in sec
beh.endTime = cfg.eventTimes(end); % end recording events (also video) in sec
beh.Ntrigger = length(cfg.eventTimes); % number of triggers recorded

%  extract preLicks information 
switch cfg.fileType
    case 'nev'
        beh.preStart = cfg.timeStamps.pre(1);
        beh.taskStart = cfg.timeStamps.pre(2);
        beh.taskEnd = cfg.timeStamps.pre(3);
        if all(cfg.timeStamps.pre > 0)
            ev_times = cfg.timeStamps.lick;
            pre_flags = ev_times > beh.preStart & ev_times < beh.taskStart;
            beh.preLicks = sum(pre_flags);
            beh.preLicksTime = ev_times(pre_flags);
        else
            beh.preLicks = -1;
            beh.preLicksTime = [];
        end
    case 'medpc'
        beh.preStart   = -1;
        beh.taskStart  = -1;
        beh.taskEnd    = -1;
        beh.preLicks   = cfg.cfg.data.C(7); % dedicated counter
        beh.preLicksTime = [];
end

% include cue information 
beh.cueOn = cfg.timeStamps.cue; % time of each cue presentation in sec

% include behavior events information 
eventLabels = fieldnames(cfg.bout); % extract event labels
for ievent = 1:length(eventLabels) 
    % format original head entry label from nlynx files
    localEvent = eventLabels{ievent};
    if strcmp(localEvent,'headent')
        localLabel = 'headEntry';
    else
        localLabel = localEvent;
    end
    beh.([localLabel 'Ntrg']) = length(cfg.trigger.(localEvent));  % event triggers
    beh.([localLabel 'TrgTime']) = cfg.timeStamps.(localEvent);        % trigger time
    beh.([localLabel 'On']) = cfg.bout.(localEvent).start;       % event start
    beh.([localLabel 'Duration']) = cfg.bout.(localEvent).duration;    % event duration 
    beh.([localLabel 'BoutTrg']) = cfg.bout.(localEvent).triggCount; % triggers per bout 
end
beh.fileType = cfg.fileType;
beh.fileName = cfg.cfg.file;


