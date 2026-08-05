
function coheTrials = trialCoherence(trialLFP,sip)

% trialLFP = lfps;


% clear phases
% for iband = 2%1:3
%     bandLabel = sip.ephys.band_label{iband};
%     filtTraces = eegfilt(trialLFP,...
%         loopLFP.fsample,...
%         sip.ephys.band_freq(iband,1),...
%         sip.ephys.band_freq(iband,2));
% 
%     band.(bandLabel) = filtTraces;
%     phases.(bandLabel) = angle(hilbert(filtTraces')); % phases from the analytical signal
% end
winSize = 3000;
overlap = round(winSize / 2);
% Extract, cut and store beta phase information
coheTrials = cell(height(trialLFP.trialsInfo),1);
for itrial = 1:height(trialLFP.trialsInfo)
    if length(trialLFP.ofc.trial{itrial}) > winSize
        try
            coheTrials{itrial} = mscohere(...
                trialLFP.ofc.trial{itrial},...
                trialLFP.striatum.trial{itrial},...
                winSize,overlap,sip.ephys.psds.foi,3000);
        catch
            coheTrials{itrial} = nan(1,length(sip.ephys.psds.foi));
        end
    end
end
%%
% 
% wfig(1); clf
% 
% plusFalgs = lfps.trialsInfo.drink == 1;
% 
% plusCohere = cat(1,coheTrials{plusFalgs});
% minusCohere = cat(1,coheTrials{~plusFalgs});
% 
% cfg = [];
% cfg.xdata = sip.ephys.psds.foi;
% cfg.ydata = plusCohere;
% avg_err_shade(cfg);
% hold on
% cfg.color_val = 'r';
% cfg.ydata = minusCohere;
% avg_err_shade(cfg);
% hold off
% xlim([0 45])