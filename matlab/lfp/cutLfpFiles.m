% create all the lfp files of every woi


% Initialize configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; ft_defaults
sip = sipConfig('lfp');
load(fullfile(sip.folder.support,'lfpResampFiles.mat'))
load(fullfile(sip.folder.proc,'behavior.mat'))
tetCriteria = 'wide';
saveFolder = fullfile(sip.folder.proc,'lfp/lfpCut/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sessLabel = 'late';  % early; late 
sessions = sip.data.(sessLabel);
tetrodes = sip.data.tetrodes.(sessLabel);

%%
for itag = 1:16

    ratSessions = sessions{itag,:};
    ratSessions(ratSessions <= 3) = [];
    ratTetrodes = getEntry(tetrodes,'tagID',itag);
    ratID.tagID = itag;
    ratID.cohortID = sip.data.ratIds{itag,'cohortID'};
    ratID.animalID = sip.data.ratIds{itag,'animalID'};

    for isession = 1:numel(ratSessions)
        fprintf('\n\n       Processing tag %i, session %i \n\n',...
            itag,ratSessions(isession))

        ratID.sessionID = ratSessions(isession);
        ratFiles = getEntry(lfpFiles,ratID);

        session_folder = set_folder(sip.file.analysis,ratID);

        cfg = [];
        cfg.tet_id = [ratTetrodes.(tetCriteria)];
        tet_files = get_entry(ratFiles,cfg);
        
        if ~isempty(tet_files)
            session_tets = sort([tet_files.tet_id]);
        else
            session_tets = [];
        end
        
        epoch_tets = sort([ratTetrodes.(tetCriteria)]);
        header_file = get_entry(sip.file_list.nlynx.ncs,ratID);

        if ~isempty(header_file) & isequal(session_tets,epoch_tets)

            cfg             = [];
            cfg.header      = ft_read_header(header_file(1).file_path);
            cfg.beh         = get_entry(behavior,ratID);
            cfg.post_dur    = 4;
            [trl, trl_list] = sip_woi_ctrl(cfg);

            cfg.interval = 'sip_trial';
            [trial_trl, trial_list] = trial_gen(cfg);

            for itet = 1:length(ratTetrodes)
                tet_num = tet_files(itet).tet_id;
                tet_label = strcat('tt',num2str(tet_num));

                lfp = load(tet_files(itet).file_path);

                first_time_stamp = lfp.resamp.time{1}(1) * 1e6;

                re_trl      = round((trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = re_trl;
                lfp_woi     = ft_redefinetrial(sip_tr,lfp.resamp);
                
                retrial_trl = round((trial_trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = retrial_trl;
                lfp_trial   = ft_redefinetrial(sip_tr,lfp.resamp);
                
                lfp_woi.cfg.list  = trl_list;
                lfp_trial.cfg.list  = trial_list;

                woi_file = sprintf('c%i_w%i_s%i_tt%i_%s_lfp_woi.mat',...
                    ratID.cohortID,...
                    ratID.animalID,...
                    ratID.sessionID,...
                    tet_num,...
                    sessLabel);

                trial_file = sprintf('c%i_w%i_s%i_tt%i_%s_lfp_trial.mat',...
                    ratID.cohortID,...
                    ratID.animalID,...
                    ratID.sessionID,...
                    tet_num,...
                    sessLabel);
            
                % save(fullfile(saveFolder,woi_file),"lfp_woi")
                % save(fullfile(saveFolder,trial_file),"lfp_trial")
            end
        end
    end
end

%% THIS SECTION CREATES THE FILES FOR EVERY VALID THETRODE OF THE 1ST COHORT 
% SO WE CAN CHECK WHETHER THERE IS ANY GOOD TETRODE

% THIS IS JUST A COPY AND PASTE OF THE CODE ABOVE

% create all the lfp files of every woi


% Initialize configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; ft_defaults
sip = sip_mainconfig;
load(fullfile(sip.file.support,'lfp_resamp_files.mat'))
load(fullfile(sip.file.support,'tetrode_epoch.mat'))
load(fullfile(sip.file.proc,'behavior.mat'))
saveFolder = fullfile(sip.file.proc,'lfp/lfp_cut/');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ch_list = add_tag(sip.analysis.channels,sip.analysis.rat_ids);

sessLabel = 'late';  % early; late 

sessions = sip.ephys.(sessLabel);

for itag = 15%1:2

    ratSessions = sessions(itag,:);
    ratTetrodes = pick_files(ch_list,'tag_id',itag);
    tet_ids = unique([ratTetrodes.tet_id]);
    tet_ids(isnan(tet_ids)) = [];

    ratID.cohortID = sip.analysis.rat_ids{itag,'cohort_id'};
    ratID.animalID = sip.analysis.rat_ids{itag,'animal_id'};

    for isession = 1:3
        fprintf('\n\n       Processing tag %i, session %i \n\n',...
            itag,ratSessions(isession))

        ratID.sessionID = ratSessions(isession);
        ratFiles = get_entry(lfp_files,ratID);

        session_folder = set_folder(sip.file.analysis,ratID);

        cfg = [];
        cfg.tet_id = tet_ids;
        cfg.seseeion_id = ratSessions;
        tet_files = get_entry(ratFiles,cfg);
        
        if ~isempty(tet_files)
            session_tets = sort([tet_files.tet_id]);
        else
            session_tets = [];
        end
        
        epoch_tets = sort(tet_ids);
        header_file = get_entry(sip.file_list.nlynx.ncs,ratID);

        if ~isempty(header_file) & isequal(session_tets,epoch_tets)

            cfg             = [];
            cfg.header      = ft_read_header(header_file(1).file_path);
            cfg.beh         = get_entry(behavior,ratID);
            cfg.post_dur    = 4;
            [trl, trl_list] = sip_woi_ctrl(cfg);

            cfg.interval = 'sip_trial';
            [trial_trl, trial_list] = trial_gen(cfg);

            for itet = 1:length(tet_files)
                tet_num = tet_files(itet).tet_id;
                tet_label = strcat('tt',num2str(tet_num));

                lfp = load(tet_files(itet).file_path);

                first_time_stamp = lfp.resamp.time{1}(1) * 1e6;

                re_trl      = round((trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = re_trl;
                lfp_woi     = ft_redefinetrial(sip_tr,lfp.resamp);
                
                retrial_trl = round((trial_trl - first_time_stamp) * 1e-6 * lfp.resamp.fsample);
                sip_tr      = [];
                sip_tr.trl  = retrial_trl;
                lfp_trial   = ft_redefinetrial(sip_tr,lfp.resamp);
                
                lfp_woi.cfg.list  = trl_list;
                lfp_trial.cfg.list  = trial_list;

                % lfp_woi = z_sip_trial(lfp_woi,lfp_trial);  

                woi_file = sprintf('c%i_w%i_s%i_tt%i_%s_lfp_woi.mat',...
                    ratID.cohortID,...
                    ratID.animalID,...
                    ratID.sessionID,...
                    tet_num,...
                    sessLabel);

                trial_file = sprintf('c%i_w%i_s%i_tt%i_%s_lfp_trial.mat',...
                    ratID.cohortID,...
                    ratID.animalID,...
                    ratID.sessionID,...
                    tet_num,...
                    sessLabel);
            
                % save(fullfile(saveFolder,woi_file),"lfp_woi")
                % save(fullfile(saveFolder,trial_file),"lfp_trial")
            end
        end
    end
end