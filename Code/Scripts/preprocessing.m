%% Load data.

% Clear windows.
clear
close all

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('fieldtrip-20230522');
addpath('participants');
addpath('morph eeg data');

% Initialise .BDF data file.
dataFile = 'participants\006meg.bdf';

% Assign raw data file to configuration.
cfg.dataset = dataFile;

% Generate data struct from raw data.
data = ft_preprocessing(cfg);

%% Re-referencing.

% Clear configuration.
cfg = [];

% Reassign raw data file to configuration.
cfg.dataset = dataFile;

% Apply re-referencing.
cfg.reref = 'yes';

% Use average of reference channels as reference.
cfg.refmethod = 'avg';

% Specify channels to be re-referenced to reference channels average.
cfg.channel = 'all'; % This includes non-scalp electrodes.

% Specify channels to be re-referenced to reference channels average.
% cfg.channel = {'all', '-A1', '-A2', '-LEOG', '-REOG', '-UEOG', '-DEOG', '-EXG7', '-EXG8', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp', '-Status'};

% Set mastoids as reference channels.
cfg.refchannel = {'T7', 'T8'};

% Generate data struct for re-referenced data. 
data_rereferenced = ft_preprocessing(cfg, data);

%% Filtering.

% Clear configuration.
cfg = [];

% Apply low-pass filter.
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 30; % 30Hz frequency cut-off.
cfg.preproc.lpfilttype = 'but'; % Butterworth filter.

% Apply high-pass filter.
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 0.3; % 0.3Hz frequency cut-off.
cfg.preproc.hpfilttype = 'but'; % Butterworth filter.

% Generate data struct for filtered re-referenced data.
data_r_filtered = ft_preprocessing(cfg, data_rereferenced);

%% Epoching.

% Clear configuration.
cfg = [];

% Re-specify raw data file.
cfg.dataset = dataFile;

% Identify events of interest from raw data file.
cfg.trialdef.eventtype = 'STATUS';
cfg.trialdef.eventvalue = [121:130 151:160];

% Define window of interest as 0.2 secs before - 1 sec after stimulus onset.
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 1;

% Create trial definitions with this configuration.
cfg = ft_definetrial(cfg);

% Store trial definition info for future reference.
trl = cfg.trl;

% Generate data struct for segmented, filtered and re-referenced data.
data_r_f_segmented = ft_redefinetrial(cfg, data_r_filtered);

% Save filtered/re-referenced/segmented data as new file to downsample.
% path = 'participants\006meg_segmented.bdf';
% save(path, 'data_r_f_segmented)')

%% Visualise segmented data.

% Create first figure.
figure(1)

% Orient channel amplitudes around 0.
cfg.preproc.demean = 'yes';

% Specify data browser visualisation settings.
cfg.channel = 'all';
cfg.viewmode = 'vertical';
cfg.ylim = [-10 10];
cfg.fontsize = 8;
cfg.position = [0 0 800 800];
cfg.verticalpadding = 0.1;

% Load data browser.
ft_databrowser(cfg, data_r_f_segmented)

ft_databrowser(cfg, data_r_filtered)

%% Independent Component Analysis.

% Clear configuration.
cfg = [];

% Specify to run ICA.
cfg.method = 'runica';

% Decompose data into independent components.
comp = ft_componentanalysis(cfg, data_r_f_segmented);

%% Inspect components.
% Clear configuration.
cfg = [];

% Specify components (indices) to inspect.
cfg.component = 1:5;

% Specify electrode layout.
cfg.layout = 'biosemi32.lay';

% Plot topographic maps.
ft_topoplotIC(cfg, comp)



