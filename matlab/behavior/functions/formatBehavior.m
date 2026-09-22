function beh = formatBehavior(events)

% beh = format_behavior(events)
% format_behavior format the information from behavior files extracted
% using event_times function. See also behavior_time.m

%%

% ------------------ include all ID fields ------------------------%
id_fields = fieldnames(events.cfg.id);
for ifield = 1:length(id_fields)
    beh.(id_fields{ifield}) = events.cfg.id.(id_fields{ifield});
end
% ------------------ include all ID fields ------------------------%

beh.start       = events.time_axis(1);                                      % start recording events (also video) in sec
beh.end         = events.time_axis(end);                                    % end recording events (also video) in sec
beh.tsamples    = length(events.time_axis);                                 % number of triggers recorded


if ~isfield(events,'ephys')
    events.ephys = 'yes';
end

switch events.ephys
    case 'yes'
        %----------------------- extract pre_licks information -----------------------%
        switch events.beh_file
            case 'nev'
                beh.pre_start   = events.trig_time.pre(1);
                beh.task_start  = events.trig_time.pre(2);
                beh.task_end    = events.trig_time.pre(3);
                if all(events.trig_time.pre > 0)
                    ev_times      = events.trig_time.lick;
                    pre_flags     = ev_times > beh.pre_start & ev_times < beh.task_start;
                    beh.pre_licks = sum(pre_flags);
                    beh.pre_licks_trgtime = ev_times(pre_flags);
                else
                    beh.pre_licks = -1;
                    beh.pre_licks_trgtime = [];
                end

            case 'medpc'
                beh.pre_start   = -1;
                beh.task_start  = -1;
                beh.task_end    = -1;
                beh.pre_licks   = events.pre_licks;
                beh.pre_licks_trgtime = [];
        end
        %----------------------- extract pre_licks information -----------------------%
        beh.cue_on = events.trig_time.cue_on;                                       % time of each cue presentation in sec
    case 'no'
        beh.pellet = events.trig_time.pellet;
end

beh_fields = fieldnames(events.time);                                       % extract event labels
for ifield = 1:length(beh_fields)
    beh.([beh_fields{ifield} '_trigger'])   = length(events.trigger.(beh_fields{ifield}));  % event triggers
    beh.([beh_fields{ifield} '_trgtime'])   = events.trig_time.(beh_fields{ifield});        % trigger time
    beh.([beh_fields{ifield} '_on'])        = events.time.(beh_fields{ifield}).start;       % event start
    beh.([beh_fields{ifield} '_dur'])       = events.time.(beh_fields{ifield}).duration;    % event duration 
    beh.([beh_fields{ifield} '_trgbout'])   = events.time.(beh_fields{ifield}).trigg_count; % triggers per bout 
end
beh.beh_file = events.beh_file;
beh.file_name = events.cfg.file;


