function [trlSamples, resampTable] = resampTrl(timeIn,trlTable,startTime,srate)

% timeIn: in seconds
% startTime: in seconds

% these are samples
% trl is in microsecs, minus the refrence, and expressed in sec.

trlSamples = round((timeIn - startTime) * srate);

resampTable = trlTable;
resampTable.t_start = timeIn(:,1);
resampTable.t_end = timeIn(:,2);
resampTable.sample_start = trlSamples(:,1);
resampTable.sample_end = trlSamples(:,2);
resampTable.duration = resampTable.t_end - resampTable.t_start;