%%
clear; clc
sip = sip_mainconfig;
sessions = 'late';
filename = strcat('psdQuant',sessions,'.mat');
load(fullfile(sip.file.proc,filename))
% load('C:\Users\scond\OneDrive\Escritorio\psdQuantlate.mat')

%% Test different stats configuration

cfg = [];
cfg.testArea = 'striatum'; % ofc / striatum
cfg.based = 'session'; % animal / session
cfg.testQuant = 'NormDf'; % Diff / Ratio
cfg.testBand = 'Theta';
cfg.model = 'mixed';
if strcmp(cfg.model,'repeated')
    cfg.group = 'hd';
end
cfg.testPsd = psdQuant.(cfg.testArea);

clc
disp(cfg)
psdTest = sipPsdAnova(cfg);


%%
plotData = psdTest.cfg.testPsd;
% Bar graphs
meanData = groupsummary(plotData,...
    'Group', ...
    "mean", ...
    plotData.Properties.VariableNames(3:end));
meanBar = meanData{:,3:end};
hdMean = getEntry(meanData,'Group','hd');
ldMean = getEntry(meanData,'Group','ld');

stdData = groupsummary(plotData,...
    'Group', ...
    "mean", ...
    plotData.Properties.VariableNames(3:end));
errBar = stdData{:,3:end}./sqrt(stdData{:,'GroupCount'});
hdError = getEntry(stdData,'Group','hd');
hdError = hdError{1,3:end}./sqrt(hdError.GroupCount);
ldError = getEntry(stdData,'Group','ld');
ldError = ldError{1,3:end}./sqrt(ldError.GroupCount);
yLabel = strcat('Mean ',testBand,'',testQuant);


hdData = getEntry(testData,'Group','hd');
hdData = hdData{:,3:end};

wfig(2); clf
clear hsp
hsp(2) = subplot(1,3,2);

barCfg = [];
barCfg.position = 1:5;
barCfg.bar_color = sip.graph.color.hd;
barCfg.max_jitter = 0.2;
barCfg.dot_color = sip.graph.color.hd;
barCfg.error = true;
barCfg.paired = false;
barCfg.transparency = 0.5;

bar_disp_dots(hdData,barCfg)

hold off; box off
set(gca,'xtick',1:5,'XTickLabel',testEpochs)
ylabel([yLabel ' - HD'])

ldData = getEntry(testData,'Group','ld');
ldData = ldData{:,3:end};

hsp(3) = subplot(1,3,3);
barCfg = [];
barCfg.position = 1:5;
barCfg.bar_color = sip.graph.color.ld;
barCfg.max_jitter = 0.2;
barCfg.dot_color = sip.graph.color.ld;
barCfg.error = true;
barCfg.paired = false;
barCfg.transparency = 0.6;

bar_disp_dots(ldData,barCfg)

hold off; box off
set(gca,'xtick',1:5,'XTickLabel',testEpochs)
ylabel([yLabel ' - LD'])

subplot(1,3,1);
barWidht = 0.3;
hdBar = bar(1:3:13,mean(hdData), ...
    'FaceColor',sip.graph.color.hd, ...
    'FaceAlpha',0.7,...
    'BarWidth',barWidht);
hold on
ldBar = bar(2:3:14,mean(ldData), ...
    'FaceColor',sip.graph.color.ld, ...
    'FaceAlpha',0.8,...
    'BarWidth',barWidht);
errorbar(1:3:13,hdMean{1,3:end},hdError,'.k')
errorbar(2:3:14,ldMean{1,3:end},ldError,'.k')
hold off; box off
ylabel([yLabel ' @' testArea])
set(gca,'xtick',1.5:3:13.5,'XTickLabel',testEpochs)
legend([hdBar, ldBar],{'HD','LD'}, ...
    'Location','northwest', ...
    'Box','off')

linkaxes(hsp(2:3),'y')