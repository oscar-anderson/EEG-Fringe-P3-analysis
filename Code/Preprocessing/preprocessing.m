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

%% Visualise raw data.

figure(1)
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.demean = 'yes';
cfg.ylim = [-10 10];
cfg.fontsize = 8;
ft_databrowser(cfg, data)

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
% cfg.channel = 'all'; % This includes all non-scalp electrodes.

% Exclude reference non-scalp channels that were not used during data acquisition.
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};

% Set mastoids as reference channels.
cfg.refchannel = {'T7', 'T8'};

% Generate data struct for re-referenced data. 
data_rereferenced = ft_preprocessing(cfg, data);

%% Visualise re-referenced data.

figure(2)
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.demean = 'yes';
cfg.ylim = [-10 10];
cfg.fontsize = 8;
cfg.position = [0 0 800 800];
ft_databrowser(cfg, data_rereferenced)

%% Low pass filtering.

% Clear configuration.
cfg = [];

% Apply low-pass filter.
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 30; % 30Hz frequency cut-off.
cfg.preproc.lpfilttype = 'but'; % Butterworth filter.

data_r_lpfiltered = ft_preprocessing(cfg, data_rereferenced);

%% Visualise low-pass filtered, re-referenced data.

figure(3)
cfg.demean = 'yes';
cfg.ylim = [-10 10];
ft_databrowser(cfg, data_r_lpfiltered)

%% High pass filtering.

cfg = [];

% Apply high-pass filter.
cfg.preproc.hpfilter = 'yes';
cfg.preproc.hpfreq = 0.3; % 0.3Hz frequency cut-off.
cfg.preproc.hpfilttype = 'fir'; % FIR filter.

% Generate data struct for fully filtered re-referenced data.
data_r_filtered = ft_preprocessing(cfg, data_r_lpfiltered);

%% Visualise filtered, re-referenced data.
figure(4)
cfg.demean = 'yes';
cfg.ylim = [-10 10];
ft_databrowser(cfg, data_r_filtered)

%% Epoching.

% Clear configuration.
cfg = [];

% Re-specify raw data file.
cfg.dataset = dataFile;

% Identify events of interest from raw data file.
cfg.trialdef.eventtype = 'STATUS';
cfg.trialdef.eventvalue = [121:130 151:160]; % Select control + critical stimuli presentation events.

% Define window of interest as 0.2 secs before - 1 sec after stimulus onset.
cfg.trialdef.prestim = 0.5;
cfg.trialdef.poststim = 1.5;

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

% Initialise figure.
figure(5)

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

%% Independent component analysis.

cfg = [];
cfg.method = 'fastica';
cfg.numcomponent = 39;

comp = ft_componentanalysis(cfg, data_r_f_segmented);

%% Inspect components.

cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.viewmode = 'component';
cfg.component = 1:39; % A max of 39 components appear when more specified.
cfg.fontsize = 8;

figure(6)
ft_databrowser(cfg, comp)

figure(7)
ft_topoplotIC(cfg, comp)

%% Reject components.

% Specify components to remove.
cfg.component = [4 8 39]; % [Eyes, unknown, electrical noise].

% Remove components.
ppData_noComp = ft_rejectcomponent(cfg, comp);

%% Remove artifact-distorted trials and channels.

% Clear configuration.
cfg = [];

cfg.preproc.demean = 'yes';

% Specify trials to inspect (1xN vector, or 'all').
cfg.trials = 'all';

% Specify channels to inspect.
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};

% Specify method for using removal tool.
% cfg.method = 'summary'; % Show a single number for each channel and trial.
cfg.method = 'channel'; % Show data per channel, all trials at once.
% cfg.method = 'trial'; % Show data per trial, all channels at once.

% Use ft_rejectvisual to remove artifact-distorted whole trials/channels.
ppData_noArt = ft_rejectvisual(cfg, ppData_noComp);

% https://www.fieldtriptoolbox.org/tutorial/visual_artifact_rejection/


%% Generate ERPs.

% For now, generate ERPs across all morphs.

% Critical morph condition.
cfg = [];
cfg.trials = data_r_f_segmented.trialinfo >= 151 & data_r_f_segmented.trialinfo <= 160;
allCritMorphs = ft_selectdata(cfg, data_r_f_segmented);

% Control morph condition.
cfg = [];
cfg.trials = data_r_f_segmented.trialinfo >= 121 & data_r_f_segmented.trialinfo <= 130;
allCtrlMorphs = ft_selectdata(cfg, data_r_f_segmented);

% % Save across-condition data structs as files.
% save allCritMorphs allCritMorphs
% save allCtrlMorphs allCtrlMorphs

% % Load across-condition data structs.
% load allCritMorphs
% load allCtrlMorphs

% Use ft_timelockanalysis to average over all trials in data struct.
cfg = [];
avgCritMorphs = ft_timelockanalysis(cfg, allCritMorphs);
avgCtrlMorphs = ft_timelockanalysis(cfg, allCtrlMorphs);

%% Visualise ERPs.

% Plot critical condition ERP topographic map.
figure
cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
ft_topoplotER(cfg, avgCritMorphs)

% Plot critical condition ERP time series.
figure
cfg = [];
cfg.preproc.demean = 'yes';
cfg.xlim = [-0.5 1.5];
cfg.channel = 'Pz';
ft_singleplotER(cfg, avgCritMorphs);

% Plot critical condition ERP topographic map.
figure
cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
ft_topoplotER(cfg, avgCtrlMorphs)

% Plot control condition ERP time series.
figure
cfg = [];
cfg.preproc.demean = 'yes';
cfg.xlim = [-0.5 1.5];
cfg.channel = 'Pz';
ft_singleplotER(cfg, avgCtrlMorphs);

% Critical morph 1 (10%).
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 151;

% Critical morph 2.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 152;

% Critical morph 3.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 153;

% Critical morph 4.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 154;

% Critical morph 5.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 155;

% Critical morph 6.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 156;

% Critical morph 7.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 157;

% Critical morph 8.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 158;

% Critical morph 9.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 159;

% Critical morph 10 (100%).
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 160;



% Control morph 1 (10%).
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 121;

% Control morph 2.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 122;

% Control morph 3.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 123;

% Control morph 4.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 124;

% Control morph 5.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 125;

% Control morph 6.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 126;

% Control morph 7.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 127;

% Control morph 8.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 128;

% Control morph 9.
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 129;

% Control morph 10 (100%).
% cfg = [];
% cfg.trials = data_r_f_segmented.trialinfo == 130;






% https://www.fieldtriptoolbox.org/tutorial/eventrelatedaveraging/

