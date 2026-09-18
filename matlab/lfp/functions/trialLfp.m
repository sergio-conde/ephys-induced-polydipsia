function lfpStruct = trialLfp(lfp,behavior)

lfpStruct = behavior;

lfpSamples = numel(lfp.trial{1});
firstTime = double(lfp.hdr.FirstTimeStamp) *1e-6;
lastTime = lfpSamples / lfp.cfg.resamplefs;
lfpTime = linspace(firstTime,lastTime,lfpSamples);

for itrial = 1:length(behavior)
    trialFlags = lfpTime >= behavior(itrial).startTime & ...
        lfpTime <= behavior(itrial).endTime;
    lfpStruct(itrial).lfp = lfp.trial{1}(trialFlags);
end