% Create PSD files from early, transition and late sessions. 
% It loads the session LFP, and cut it into trials and behavioral epochs. 
% The PSDs are calculated for each epoch normalized by the mean and std 
% (zscore) of the trial it belongs to. 


% Initialize configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; ft_defaults
sip = sipConfig('lfp');

% replace this by a function that loads the required support files
load(fullfile(sip.folder.support,'lfp_resamp_files.mat'))
load(fullfile(sip.folder.support,'tetrode_epoch.mat'))
load(fullfile(sip.folder.proc,'behavior.mat'))
load(fullfile(sip.folder.support,'rawFilesList.mat'),'ncsFiles')

tetSelection = 'wide';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessLabel = 'late';  % early; late

sessions = sip.data.(sessLabel);
tetrodes = tetrode_epoch.(sessLabel);

psdConfig = sip.lfp.psds;
for itag = 16%3:16

    ratSessions = sessions{itag};
    ratTetrodes = pick_files(tetrodes,'tag_id',itag);
    ratId.tag_id = itag;
    ratId.cohort_id = sip.data.ratIds{itag,'cohort_id'};
    ratId.animal_id = sip.data.ratIds{itag,'animal_id'};

    for isession = 1:length(ratSessions)
        fprintf('\n\n       Processing tag %i, session %i \n',...
            itag,ratSessions(isession))
        clear psds

        ratId.session_id = ratSessions(isession);
        psds.ids = ratId;
        rat_files = get_entry(lfp_files,ratId);

        session_folder = set_folder(sip.folder.analysis,ratId);

        cfg = [];
        cfg.tet_id = [ratTetrodes.(tetSelection)];
        psds.files = get_entry(rat_files,cfg);
        psds.tet_crit = tetSelection;

        if ~isempty([psds.files])
            session_tets = sort([psds.files.tet_id]);
        else
            session_tets = [];
        end
        
        epoch_tets = sort([ratTetrodes.(tetSelection)]);
        header_file = get_entry(ncsFiles,ratId);

        if ~isempty(header_file) & isequal(session_tets,epoch_tets)

            cfg             = [];
            cfg.header      = ft_read_header(header_file(1).file_path);
            cfg.beh         = get_entry(behavior,ratId);
            cfg.post_dur    = 4;
            [trl, trl_list] = sip_woi_ctrl(cfg);

            cfg.interval = 'sip_trial';
            [trial_trl, trial_list] = trial_gen(cfg);

            psds.events = trl_list;
            psds.trl = trl;

            for itet = 1:length(ratTetrodes)
                tet_num = psds.files(itet).tet_id;
                tet_label = strcat('tt',num2str(tet_num));

                lfp = load(psds.files(itet).file_path);

                first_time_stamp = lfp.resamp.time{1}(1) * 1e6;

                re_trl      = round((trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = re_trl;
                lfpWoi     = ft_redefinetrial(sip_tr,lfp.resamp);
                
                retrial_trl = round((trial_trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = retrial_trl;
                lfpTrial   = ft_redefinetrial(sip_tr,lfp.resamp);
                
                lfpWoi.cfg.list  = trl_list;
                lfpTrial.cfg.list  = trial_list;
                lfpWoi = z_sip_trial(lfpWoi,lfpTrial);

                psds.(tet_label).area = ratTetrodes.area;
                psds.(tet_label).tet_id = tet_num;

                psdConfig.output = 'original';
                psds.(tet_label).original = ft_freqanalysis(psdConfig, lfpWoi);

                psdConfig.output = 'fractal';
                psds.(tet_label).fractal  = ft_freqanalysis(psdConfig, lfpWoi);

                cfg           = [];
                cfg.parameter = 'powspctrm';
                cfg.operation = 'x2-x1';
                psds.(tet_label).oscillatory = ft_math(cfg, ...
                    psds.(tet_label).fractal, psds.(tet_label).original);
            end

            file_name = sprintf('c%i_w%i_s%i_psd_%s.mat',...
                psds.ids.cohort_id,...
                psds.ids.animal_id,...
                psds.ids.session_id,...
                sessLabel);

            % save(fullfile(session_folder.full,file_name),"psds")
        end
        
    end
end