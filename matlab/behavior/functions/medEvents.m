function events = medEvents(cfg)

% Event stamps ( array E )
% \    1   = Rightpress
% \    2   = cue on
% \    5   = Pellet reinforcement delivery
% \    6   = Water spout lick/beam break
% \    7   = Head entry into food pellet tray
% \    34  = Houselight on
% \    35  = Houselight off
% \    100 = Mark end of session
% \   Variables
% \   A(0) = Session length (min)
% \   A(1) = Dummy variable for menu
% \   A(2) = Dummy variable for menu
% \   A(3) = Pick from R list for VI
% \
% \   B(0) = Binary cue approaches
% \   B(1) = Probability cue approach
% \   B(2) = Binary HE during cue
% \   B(3) = Probability HE during cue
% \   B(4) = Total latency cue approach
% \   B(5) = Average latency cue approach
% \   B(6) = Total Latency HE during cue
% \   B(7) = Average latency HE during cue
% \
% \   C()  = Counters
% \   C(0) = Number of head entries into food pellet magazine
% \   C(1) = Number of pellets delivered
% \   C(2) = Number of licks
% \   C(3) = Number of trials
% \   C(4) = Number of lever presses
% \   C(5) = Number of head entries during cue presentation
% \   C(6) = Number of pre-session licks
% \
% \   E() = Event identity stamps
% \   G   = Event and time stamp counter
% \   H   = Session timer in centiseconds
% \   J   = Timer last 30 s
% \   M   = Event counter latency cue approach
% \   N   = Latency cue approach
% \   P   = Latency timer cue approach
% \   T() = Event time stamps
% \   U   = Latency timer head entry
% \   V   = Event counter latency head entry
% \   W   = Latency HE during cue
% \   Y   = Trial counter for latencies and probabilities

events.cfg = cfg;

events.eventID.leverpressID   = 1;
events.eventID.cueID          = 2;
events.eventID.pelletID       = 5;
events.eventID.lickID         = 6;
events.eventID.headentID      = 7;

events.sequence  = cfg.data.E;
events.timeAxis = cfg.data.T * 1e-2; % medpc resolution is 10ms

cueFlags = events.sequence == events.eventID.cueID;
events.trigTime.cueOn = events.timeAxis(cueFlags);

pelletFlags = events.sequence == events.eventID.pelletID;
events.trigTime.pellet = events.timeAxis(pelletFlags);

lickFlags = events.sequence == events.eventID.lickID;
events.trigTime.lick = events.timeAxis(lickFlags);

events.preLicks = cfg.data.C(7);

for ievent = 1:length(cfg.events)
    localEvent = cfg.events{ievent};   % event label

    eventFlags = events.sequence == events.eventID.([localEvent 'ID']);
    events.trigger.(localEvent) = find(eventFlags);
    events.trigTime.(localEvent) = events.timeAxis(eventFlags);

    eventTimes = events.trigTime.(localEvent);

    if ~isempty(eventTimes)

        diffEvent  = [cfg.interBout(ievent) + 1 diff(eventTimes)] > cfg.interBout(ievent);
        startTimes = eventTimes(diffEvent);
        endTimes   = eventTimes([diffEvent(2:end) true]);
        duration    = endTimes - startTimes;
        triggCount = diff(find([diffEvent true]));

        triggCount(duration < cfg.minDuration(ievent)) = [];
        startTimes(duration < cfg.minDuration(ievent)) = [];
        duration(duration < cfg.minDuration(ievent)) = [];

        events.time.(localEvent).start       = startTimes;
        events.time.(localEvent).duration    = duration;
        events.time.(localEvent).triggCount = triggCount;
    else
        events.time.(localEvent).start       = [];
        events.time.(localEvent).duration    = [];
        events.time.(localEvent).triggCount = [];
    end
    
end
events.fileType = 'medpc';
