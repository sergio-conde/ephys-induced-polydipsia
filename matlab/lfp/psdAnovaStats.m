%%
clear; clc
sip = sip_mainconfig;
sessions = {'early','late'};
for isessions = 1:2
    filename = strcat('psdQuant',sessions{isessions},'.mat');
    load(fullfile(sip.file.proc,filename));
    psdContrast.(sessions{isessions}) = psdQuant;
end
% load('C:\Users\scond\OneDrive\Escritorio\psdQuantlate.mat')


%% Test different stats configurations for early and late sessions

contrastVari = 'Diff'; % Diff | Ratio | NormDf | Power
anovaModel = 'mixed'; % mixed | repeated
anovaBased = 'session'; % animal | session

bandLabels = {'Delta','Theta','Beta'};
summaryAnova = struct([]);
nLine = 1;
for isessions = 1:2
    for iband = 1:numel(bandLabels)
        for iarea = 1:2
            cfg = [];
            cfg.sessions = sessions{isessions};
            cfg.testArea = sip.ephys.area_label{iarea}; % ofc / striatum
            cfg.based = anovaBased; 
            cfg.testQuant = contrastVari;
            cfg.testBand = bandLabels{iband};
            cfg.model = anovaModel;
            cfg.testPsd = psdContrast.(sessions{isessions}).(cfg.testArea);
            psdTest = sipPsdAnova(cfg); % main ANOVA function
            cfg.testBand = bandLabels;
            idLabels = setdiff(fieldnames(psdTest.cfg),{'display'});
            for iIdVar = 1:numel(idLabels)
                summaryAnova(nLine).(idLabels{iIdVar}) = psdTest.cfg.(idLabels{iIdVar});
            end
            for iModelVar = 1:numel(psdTest.anova.tableLabels)
                modelLabel = psdTest.anova.modelLabels{iModelVar};
                tableLabel = strcat('pVal',psdTest.anova.tableLabels{iModelVar});
                summaryAnova(nLine).(tableLabel) = psdTest.anova.mainTest{modelLabel,'pValue'};
            end
            for iCompVar = 1:numel(psdTest.anova.multLabels)
                compLabel = psdTest.anova.multLabels{iCompVar};
                summaryAnova(nLine).(compLabel) = psdTest.anova.(compLabel);
            end
            nLine = nLine + 1;
        end
    end
end
clc
psdTest.cfg.testBand = bandLabels;
disp(psdTest.cfg)
printSipAnova(summaryAnova)


%% Compare early and late HD

clc
cfg = [];
cfg.testArea = 'ofc'; % ofc / striatum
cfg.testGroup = 'hd';
cfg.based = 'animal'; % animal | session | earlyLate
cfg.testQuant = 'Diff';
cfg.testBand = 'Theta';
cfg.model = 'earlyLate';
cfg.testPsd = psdContrast;





