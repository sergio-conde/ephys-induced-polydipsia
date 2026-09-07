% PSD ANALYSIS OF DIFFERENT BEHAVIORAL WOIs DURING SIP

% Initialize configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc
sip = sip_mainconfig;
sessions = 'early';  % early; late
artefactFile = strcat('lfpArtefacts',upper(sessions(1)),sessions(2:end),'.mat');
load(fullfile(sip.file.support,artefactFile))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Data selection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = strcat(sessions,'_irasa_full_files2.mat');
irasa_files = importdata(fullfile(sip.file.support,filename));
rat_tetrodes = sip.ephys.tetrodes.(sessions);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if strcmp(sessions,'late')
    % remove session 23 from c5w06 -> behavioral outlier
    irasa_files(44) = [];
    % remove cohort 1 -> bad signal
    irasa_files(1:4) = [];
end

psdQuant = [];
psdQuant.cfg.files = irasa_files;
psdQuant.cfg.sessions = sessions;

quantData = struct([]);

iline = 1;
tagStr = ' ... ';
fprintf('\nProcessing file %s',tagStr)
for ifile = 1:length(irasa_files)

    fprintf(repmat('\b',1,length(tagStr)))
    tagStr = sprintf(' %i ',ifile);
    fprintf('%s',tagStr)    
    
    load(irasa_files(ifile).file_path)
    rat_tag = irasa_files(ifile).tag_id;
    
    cue_flags = strcmp(psds.events.woi_label,'cue');
    n_lickplus = sum(cue_flags & strcmp(psds.events.trial_type,'plus'));
    n_lickminus = sum(cue_flags & strcmp(psds.events.trial_type,'minus'));

    for iarea = 1:2

        tet_cfg         = [];
        tet_cfg.tag_id  = irasa_files(ifile).tag_id;
        tet_cfg.area_id = iarea;
        tet_info        = getEntry(rat_tetrodes,tet_cfg);
        tet_label       = strcat('tt',num2str(tet_info.wide));

        rat_psds = psds.(tet_label).oscillatory;
        rat_fractal = psds.(tet_label).fractal;

        art_cfg = psds.ids;
        art_cfg.tet_id = tet_info.wide;
        sess_art = getEntry(artefacts,art_cfg);

        if ismember(irasa_files(ifile).tag_id,[5 6 7 12])
            clean_flags = sess_art.woi_percg < 1;
        else
            clean_flags = true(size(sess_art.woi_percg));
        end

        for ievent = [1 2 3 6 7]
            
            pm_psd = nan(2,size(rat_psds.powspctrm,3));
            psd_fractal = nan(2,size(rat_psds.powspctrm,3));
            for trial_type = 1:2
                lick_label = sip.ephys.trial_type{trial_type};

                ev_flag = ismember(psds.events.woi_label, ...
                    sip.ephys.wois.(lick_label){ievent});

                sel_events = strcmp(psds.events.trial_type,lick_label);
                sel_events = sel_events & clean_flags(:);

                event_data = rat_psds.powspctrm(sel_events & ev_flag,:,:);
                fractal_data = rat_fractal.powspctrm(sel_events & ev_flag,:,:);
                
                pm_psd(trial_type,:) = squeeze(mean(event_data,1,'omitmissing'));
                
                psd_fractal(trial_type,:) = squeeze(mean(fractal_data,1,'omitmissing')); 
            end

            pm_psd = smoothdata(pm_psd,2,"gaussian",60); 
            pm_psd_sm = pm_psd;
            psd_fractal_sm = psd_fractal;

            pm_event = pm_psd(1,:)./pm_psd(2,:);
            pm_ratio = smoothdata(pm_event,"gaussian",25);
            pm_ratio(pm_ratio < 0) = nan;

            norm_psd = pm_psd_sm./(pm_psd_sm + psd_fractal_sm);
            diff_psd = norm_psd(1,:) - norm_psd(2,:);
            
            for iband = 1:size(sip.ephys.band_freq,1)
                
                bandFlags = rat_psds.freq >= sip.ephys.band_freq(iband,1) & ...
                    rat_psds.freq <= sip.ephys.band_freq(iband,2);

                ratio_pow = median(pm_ratio(:,bandFlags),"omitnan");
                pow_diff = median(diff_psd(1,bandFlags),"omitnan");

                plus_osc = sum(pm_psd_sm(1,bandFlags),"omitnan");
                minus_osc = sum(pm_psd_sm(2,bandFlags),"omitnan");
                plus_fractal = sum(psd_fractal_sm(1,bandFlags),"omitnan");
                minus_fractal = sum(psd_fractal_sm(2,bandFlags),"omitnan");
                
                quantData(iline).tagID = rat_tag;
                quantData(iline).rat = sip.analysis.rat_ids.label{rat_tag};
                quantData(iline).group = sip.analysis.rat_ids.drink_gr{rat_tag};
                quantData(iline).session = irasa_files(ifile).session_id;
                quantData(iline).nLickPlus = n_lickplus;
                quantData(iline).nLickMinus = n_lickminus;
                quantData(iline).tetLabel = tet_label;
                quantData(iline).area = tet_info.area;
                quantData(iline).woi = sip.ephys.wois.labels{ievent};
                quantData(iline).band = sip.ephys.band_label{iband};
                quantData(iline).plusOsc = plus_osc;
                quantData(iline).minusOsc = minus_osc;
                quantData(iline).plusFractal = plus_fractal;
                quantData(iline).minusFractal = minus_fractal;
                quantData(iline).powDiff = pow_diff;
                quantData(iline).ratio = ratio_pow;  
                iline = iline + 1;
                
            end
        end
    end
end
psdQuant.data = struct2table(quantData);
%%
woiLabels = {'PreCue','Cue','PreLick','Lick','PostLick'};
for iarea = 1:2
    temFlag = true;
    for iband = 1:length(sip.ephys.band_label)
        for iwoi = 1:length(woiLabels)
            localData = getEntry(psdQuant.data, ...
                'area',sip.ephys.area_label{iarea},...
                'woi',woiLabels{iwoi},...
                'band',sip.ephys.band_label{iband});     
            if temFlag
                bandTable = localData(:,1:4);
                temFlag = false;
            end
            woiDataLabel = strcat(woiLabels{iwoi}, ...
                upper(sip.ephys.band_label{iband}(1)), ...
                sip.ephys.band_label{iband}(2:end));
            
            normPlus = localData.plusOsc./(localData.plusOsc + localData.plusFractal);
            normMinus = localData.minusOsc./(localData.minusOsc + localData.minusFractal);

            bandTable.(strcat(woiDataLabel,'Ratio')) = localData.plusOsc./localData.minusOsc;
            bandTable.(strcat(woiDataLabel,'NormDf')) = normPlus - normMinus;
            bandTable.(strcat(woiDataLabel,'Power')) = localData.ratio;
            bandTable.(strcat(woiDataLabel,'Diff')) = localData.plusOsc - localData.minusOsc;
        end
    end
    psdQuant.(sip.ephys.area_label{iarea}) = bandTable;
end
% filename = strcat('psdQuant',sessions,'.mat');
% save(fullfile(sip.file.proc,filename),"psdQuant")
