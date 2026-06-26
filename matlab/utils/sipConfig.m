function cfg = sipConfig(varargin)

% sip_mainconfig loads the main configuration parameters of the
% schedule-induced polydipsia project. This includes:
%
% file - Paths of the project's folder structure
% task - Parameters of the sip task (e.g, cues, sessions, etc.)
% behavior - Bout definitions

%%%%% possible field parameters to be included %%%%%
fullConfig = {'task', 'behavior', 'video','spike', 'lfp', 'colors'}; 

reqConfig = varargin;
if isempty(reqConfig)
    reqConfig = fullConfig;
end

cfg = []; % Initializing output

% Folder structure as default
% files configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.folder.root           = '\\vs03\VS03-NandB-1\tara\ephys_rat_sip';       % project's root folder
cfg.folder.raw            = [cfg.folder.root '\Data_collection\raw'];       % data's raw matlab files folder
cfg.folder.proc           = [cfg.folder.root '\Data_collection\processed']; % data's preprocessed folder
cfg.folder.analysis       = [cfg.folder.root '\Data_analysis'];             % data's analysis folder
cfg.folder.publications   = [cfg.folder.root '\Publications'];              % data's Publications folder
cfg.folder.support        = [cfg.folder.proc '\support'];                   % data's support files folder
cfg.folder.level_name     = {'cohort','animal','session'};                  % labels of each organization level
cfg.folder.folder_coding  = {'cohort*','w*','*'};                           % string coding for each level (folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw data info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.data.nrats        = 16;
cfg.data.nlynxs_files = {'ntt','csc'};
cfg.data.nlynxs_label = {'TT','CSC'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iParam = 1:length(reqConfig)
  cfg = addConfig(cfg,'file');
end

function cfg = addConfig(cfg,param)

switch param
    case 'task'
    case 'behavior'
    case 'video'
    case 'spike'
    case 'lfp'
    case 'colors'
    otherwise
        warning(['WARNING: Configuration request invalid\n' ...
            'The following field was ignored: \n'])
        sprintf('%s/n/n',param)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load supporting files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load([cfg.file.support '\ch_info.mat'],'ch_info');          % load selected channels
% load([cfg.file.proc '\spike_list.mat'],'spike_list');       % load sorted list files
% load([cfg.file.support '\file_list.mat'],'file_list');      % load the neralynx list files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% supporting file lists %%%%%%%%%%%%%%%%%
% cfg.file_list.nlynx         = file_list;
% cfg.file_list.sorted_files  = spike_list;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% waveclus configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cfg.waveclus        = set_parameters();     % set Waveclu's default parameters 
% cfg.waveclus.w_pre  = 8;                    % samples before the alignment sample
% cfg.waveclus.w_post = 24;                   % samples after the alignment sample
% 
% % visualization %%%
% cfg.waveclus.grph.unit_color    = parula;   % units (clusters) colormap
% cfg.waveclus.grph.elect_color   = jet;      % electrode colormap
% cfg.waveclus.grph.ndims         = 2;        % PCA dimensions to plot
% cfg.waveclus.grph.max_spk       = 200;      % Maximum spike number to plot
% cfg.waveclus.grph.align_sample  = 8;        % Waveform peak (sample) 
% cfg.waveclus.grph.srate         = 30303;    % Sample rate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



cfg.analysis.rat_ids        = rat_ids;                          % 
cfg.analysis.nrats          = size(rat_ids,1);                  % number of rats following the configuration

cfg.analysis.sip_sessions   = 1:25;
cfg.analysis.main_wois      = {'pre_all','pre_event',...
    'pre_cue','cue','intake','event','no_event'};               % main (time) windows of interest
cfg.analysis.events         = {'lick','headent'};               % main behavioral events
cfg.analysis.drink_label    = {'ld','hd'};                      % High and low drinkers label
cfg.analysis.lick_label     = {'plus','minus'};                      % High and low drinkers label

cfg.analysis.manipulations  = {'none','baseline1','baseline2',...
    'habituation','baseline','saline','dry','quinine','adlib',...
    'veh','mtep','extinction'};                                 % manipulation labels
% 
% cfg.analysis.late_sessions        = repmat(23:25,16,1);
% cfg.analysis.late_sessions(3,:)   = 18:20;
% cfg.analysis.late_sessions(4,:)   = 18:20;
% cfg.analysis.late_sessions(16,:)  = [21 22 24];

cfg.analysis.cue_dur        = 5;                                % cue duration in sec
cfg.analysis.int_bout_time  = [1 1.5];                          % maximum time between behavioral events to be considered as part of the same bout
cfg.analysis.min_bout_dur   = [2 1];                            % minimum duration of one bout
cfg.analysis.channels       = ch_info;
cfg.analysis.srate          = 30303; 

cfg.analysis.vrate          = 25;         % video sampling rate in frames/s
cfg.analysis.video_res      = [576 720];  % tracking video resolution
cfg.analysis.box.width      = 32.5;
cfg.analysis.box.length     = 31.5;
cfg.analysis.box.hight      = 40;
cfg.analysis.box.external   = 40;

video_res                   = cfg.analysis.video_res;
cfg.analysis.box.video      = [1 1 video_res(2) video_res(2) 1;1 video_res(1) video_res(1) 1 1];
cfg.analysis.box.grid       = [125 125 465 465 125;85 440 440 85 85];
cfg.analysis.box.cue        = [480 422];
cfg.analysis.box.mag        = [465,270];
cfg.analysis.box.drink      = [75 270];
cfg.analysis.box.max_dist   = 5;  % [cm] distances less than this denote proximity to, for example, the cue

cfg.ephys.area        = {'ofc','str'};                    % brain areas labels
cfg.ephys.area_label  = {'ofc','striatum'};               % brain areas labels
cfg.ephys.cell_types  = {'pyr','int','msn','fsi','cin'};
cfg.ephys.cell_label  = {'Pyramidal','Interneuron','MSN','FSI','Cholinergic'};
cfg.ephys.epochs      = {'early','transition','late'};
cfg.ephys.early       = repmat(1:3,16,1);
cfg.ephys.transition  = repmat(12:14,16,1);
cfg.ephys.late        = [[18 19 20];[21 22 23];repmat(18:20,2,1);[23 24 25];...
                        repmat(23:25,7,1);repmat(23:25,3,1);[21 23 24]];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% graphics configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rat_ref                 = jet(256);
session_ref             = summer(256);
cfg.graph.color.rat     = rat_ref(round(linspace(1,256,cfg.analysis.nrats)),:);
cfg.graph.color.sess    = session_ref(round(linspace(1,256,max(cfg.analysis.sip_sessions))),:);
cfg.graph.color.woi     = [60 101 176;237 123 46]/255;
cfg.graph.color.event   = [14 102 62;163 60 15]/255;
cfg.graph.color.area    = [50 168 82;90 50 168]/255;
cfg.graph.color.ld      = [128 179 255]/255;
cfg.graph.color.hd      = [0 51 128]/255;

cfg.graph.color.plus    = [200 52 2]/255;
cfg.graph.color.minus   = 0.65 * ones(1,3);
cfg.graph.color.gray    = 0.65 * ones(1,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%