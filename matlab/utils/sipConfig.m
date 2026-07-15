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
cfg.folder.root          = '\\vs03\VS03-NandB-1\tara\ephys_rat_sip';       % project's root folder
cfg.folder.raw           = [cfg.folder.root '\Data_collection\raw'];       % data's raw matlab files folder
cfg.folder.proc          = [cfg.folder.root '\Data_collection\processed']; % data's preprocessed folder
cfg.folder.analysis      = [cfg.folder.root '\Data_analysis'];             % data's analysis folder
cfg.folder.publications  = [cfg.folder.root '\Publications'];              % data's Publications folder
cfg.folder.support       = [cfg.folder.proc '\support'];                   % data's support files folder
cfg.folder.levelName     = {'cohort','animal','session'};                  % labels of each organization level
cfg.folder.folderCoding  = {'cohort*','w*','*'};                           % string coding for each level (folders)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% raw data info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cfg.data.nRats        = 16;
cfg.data.nlynxsFiles = {'ntt','csc'};
cfg.data.nlynxsLabel = {'TT','CSC'};
% CREATE RAT IDS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for iParam = 1:length(reqConfig)
  cfg = addConfig(cfg,'file');
end

function cfg = addConfig(cfg,param)

switch param
    case 'task'
        cfg.task.sessionEpochs  = {'early','transition','late'};
        cfg.task.cueDuration    = 5;                                % cue duration in sec
        cfg.task.wois = {
            'pre_all', ...
            'pre_event', ...
            'pre_cue', ...
            'cue', ... 
            'intake', ...
            'event', ...
            'no_event'};
        cfg.task.manipulations  = {'none', 'baseline1', 'baseline2',...
            'habituation', 'baseline', 'saline', 'dry', 'quinine', 'adlib',...
            'veh', 'mtep', 'extinction'};

    case 'behavior'
        cfg.behavior.drinkGroup    = {'ld','hd'};                      % High and low drinkers label
        cfg.behavior.lickLabel     = {'plus','minus'};                 % Lick Plus and Minus label
        cfg.behavior.events        = {'lick','headent'};               % main behavioral events
        cfg.behavior.interBout     = [1 1.5];                          % maximum time between behavioral events to be considered as part of the same bout
        cfg.behavior.min_bout_dur  = [2 1];                            % minimum duration of one bout

    case 'video'
        cfg.video.vrate        = 25;         % video sampling rate in frames/s
        cfg.video.videoRes     = [576 720];  % tracking video resolution
        cfg.video.box.width    = 32.5;
        cfg.video.box.length   = 31.5;
        cfg.video.box.hight    = 40;
        cfg.video.box.external = 40;

        video_res                = cfg.video.videoRes;
        cfg.video.box.video      = [1 1 video_res(2) video_res(2) 1;1 video_res(1) video_res(1) 1 1];
        cfg.video.box.grid       = [125 125 465 465 125;85 440 440 85 85];
        cfg.video.box.cue        = [480 422];
        cfg.video.box.mag        = [465,270];
        cfg.video.box.drink      = [75 270];
        cfg.video.box.max_dist   = 5;  % [cm] distances less than this denote proximity to, for example, the cue
    case 'spike'
    case 'lfp'
    case 'colors'
        cfg.color.rat     = jet(16);
        cfg.color.session = summer(25);
        cfg.color.woi     = [60 101 176;237 123 46]/255;
        cfg.color.event   = [14 102 62;163 60 15]/255;
        cfg.color.area    = [50 168 82;90 50 168]/255;
        cfg.color.ld      = [128 179 255]/255;
        cfg.color.hd      = [0 51 128]/255;
        cfg.color.plus    = [200 52 2]/255;
        cfg.color.minus   = 0.65 * ones(1,3);
        cfg.color.gray    = 0.65 * ones(1,3);
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



% cfg.analysis.rat_ids        = rat_ids;                          % 
% cfg.analysis.nrats          = size(rat_ids,1);                  % number of rats following the configuration

cfg.task.sessionEpochs  = {'early','transition','late'};
cfg.task.cueDuration    = 5;                                % cue duration in sec
cfg.task.wois = {
    'pre_all', ...
    'pre_event', ...
    'pre_cue', ...
    'cue', ...
    'intake', ...
    'event', ...
    'no_event'};               
cfg.task.manipulations  = {'none', 'baseline1', 'baseline2',...
    'habituation', 'baseline', 'saline', 'dry', 'quinine', 'adlib',...
    'veh', 'mtep', 'extinction'};  


% cfg.analysis.channels       = ch_info;

cfg.ephys.area       = {'ofc','str'};                    % brain areas labels
cfg.ephys.areaLabel  = {'OFC','Striatum'};               % brain areas labels
cfg.spike.cellTypes  = {'pyr','int','msn','fsi','cin'};
cfg.spike.cellLabel  = {'Pyramidal','Interneuron','MSN','FSI','Cholinergic'};
% cfg.ephys.early       = repmat(1:3,16,1);
% cfg.ephys.transition  = repmat(12:14,16,1);
% cfg.ephys.late        = [[18 19 20];[21 22 23];repmat(18:20,2,1);[23 24 25];...
%                         repmat(23:25,7,1);repmat(23:25,3,1);[21 23 24]];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

