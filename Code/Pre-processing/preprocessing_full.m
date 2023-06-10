%% Load data.

% Clear workspace.
clear
close all

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('fieldtrip-20230522');
addpath('participants');
addpath('morph eeg data');

% Initialise .BDF data file.
dataFile = 'participants\006meg.bdf';

cfg.dataset = dataFile;

data = ft_preprocessing(cfg);

%% Re-referencing.

cfg = [];

cfg.dataset = dataFile;
cfg.reref = 'yes';
cfg.channel = 'all';
cfg.implicitref = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz'};
cfg.refchannel = {'T7', 'T8'};

data_rereferenced = ft_preprocessing(cfg, data);

%% Filtering.

cfg = [];

% Low-pass filter.
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 30;

% High-pass filter.
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 0.3;

data_r_filtered = ft_preprocessing(cfg, data_rereferenced);

%% Epoching.

cfg = [];

cfg.dataset = dataFile;
cfg.trialdef.eventtype = 'STATUS';
cfg.trialdef.eventvalue = [121:130 151:160];
cfg.trialdef.prestim = 0.2;
cfg.trialdef.poststim = 1;

cfg = ft_definetrial(cfg);

trl = cfg.trl;

data_r_f_segmented = ft_redefinetrial(cfg, data_r_filtered);

%% Visualise segmented data.
figure(1)

cfg.demean = 'yes';

cfg.channel = 'all';
cfg.viewmode = 'vertical';
cfg.ylim = [-10 10];
cfg.fontsize = 8;
cfg.position = [0 0 800 800];
cfg.verticalpadding = 0.1;
ft_databrowser(cfg, data_r_f_segmented)
