%% Load data as segmented trials.
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

%% Band-pass filter.
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.3 30]; % Use range specified by Alberto Aviles.
cfg.bpfilttype = 'fir'; % Butterworth does not work with this lower band.

%% Notch (band-stop) filter.
cfg.bsfreq = [7 8]; % Remove SSVEP of 7.52Hz.

%% Re-reference.
cfg.reref = 'yes';
cfg.refmethod = 'avg'; % Use average.
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'}; % Exclude empty channels.
cfg.refchannel = {'T7', 'T8'}; % Use average of mastoids.

%% Segment.
cfg.trialdef.eventtype = 'STATUS'; % Events are marked as type 'STATUS'.
cfg.trialdef.eventvalue = [121:130 151:160]; % Select events of interest.
cfg.trialdef.prestim = 0.5; % Specify time before event to include.
cfg.trialdef.poststim = 1.5; % Specify time after event to include.

cfg = ft_definetrial(cfg);

trials = cfg.trl;

%% Baseline correct.
cfg.preproc.demean = 'yes'; % Subtract window mean from each point.
cfg.baselinewindow = [-0.2 0]; % Use window recommended by Steven Luck.

%% De-trend.
cfg.detrend = 'yes'; % Remove baseline drift.

%% Apply pre-processing.
dataSFR = ft_preprocessing(cfg);

%% Apply objective artifact exclusion threshold.
cfg = [];

cfg.dataset = dataFile;
cfg.trl = trials;
cfg.continuous = 'no';

cfg.artfctdef.threshold.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.artfctdef.threshold.bpfilter = 'no';
cfg.artfctdef.threshold.min = -100;
cfg.artfctdef.threshold.max = 100;

[~, artifact] = ft_artifact_threshold(cfg, dataSFR);

%% Visualise pre-processed data.
figure(1)

cfg = [];

cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.ylim = [-10 10];
cfg.fontsize = 8;

ft_databrowser(cfg, dataSFR)

%% Independent component analysis.
cfg = [];
cfg.method = 'fastica';

comp = ft_componentanalysis(cfg, dataSFR);

%% Inspect components.
cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.viewmode = 'component';
cfg.component = 1:39; % A max of 39 components appear when more is specified.
cfg.fontsize = 8;

figure(3)
ft_databrowser(cfg, comp)

figure(4)
ft_topoplotIC(cfg, comp)

%% Reject components.
cfg = [];

cfg.component = 2;

dataSFRC = ft_rejectcomponent(cfg, comp);

%% Visualise ICA'd data.
cfg = [];

cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};
cfg.ylim = [-10 10];
cfg.fontsize = 8;

ft_databrowser(cfg, dataSFRC)

%% Remove artifact-distorted trials and channels.

cfg = [];

cfg.method = 'channel';
cfg.channel = {'all', '-GSR1', '-GSR2', '-Erg1', '-Erg2', '-Resp', '-Plet' '-Temp' '-Status'};

dataSFRCA = ft_rejectvisual(cfg, dataSFRC);

%% Generate ERPs.

critMorphPairs = {151:152 153:154 155:156 157:158 159:160};
ctrlMorphPairs = {121:122 123:124 125:126 127:128 129:130};

critERPs = cell(1, length(critMorphPairs));
ctrlERPs = cell(1, length(ctrlMorphPairs));

for i = 1:length(critMorphPairs)
    critIdxs = find(ismember(dataSFRCA.trialinfo, critMorphPairs{i}));
    ctrlIdxs = find(ismember(dataSFRCA.trialinfo, ctrlMorphPairs{i}));

    cfg = [];
    cfg.trials = critIdxs;
    critMorphs = ft_selectdata(cfg, dataSFRCA);

    cfg = [];
    cfg.trials = ctrlIdxs;
    ctrlMorphs = ft_selectdata(cfg, dataSFRCA);

    cfg = [];
    critERPs{i} = ft_timelockanalysis(cfg, critMorphs);
    ctrlERPs{i} = ft_timelockanalysis(cfg, ctrlMorphs);

end

% Visualise ERPs as time series.
cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.channel = 'Pz';
cfg.title = 'ERP for combined morphs 1-2';
cfg.linewidth = 1;
cfg.ylim = [-13 13];
ft_singleplotER(cfg, critERPs{1}, critERPs{2})

cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.channel = 'Pz';
cfg.title = 'ERP for combined morphs 3-4';
cfg.linewidth = 1;
cfg.ylim = [-13 13];
ft_singleplotER(cfg, critERPs{2})

cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.channel = 'Pz';
cfg.title = 'ERP for combined morphs 5-6';
cfg.linewidth = 1;
cfg.ylim = [-13 13];
ft_singleplotER(cfg, critERPs{3})

cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.channel = 'Pz';
cfg.title = 'ERP for combined morphs 7-8';
cfg.linewidth = 1;
cfg.ylim = [-13 13];
ft_singleplotER(cfg, critERPs{4})

cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.channel = 'Pz';
cfg.title = 'ERP for combined morphs 9-10';
cfg.linewidth = 1;
cfg.ylim = [-13 13];
ft_singleplotER(cfg, critERPs{5})

% Visualise ERPs as topographic maps.
cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.xlim = [0.2 0.3];
cfg.zlim = [-6 6];
ft_topoplotER(cfg, critERPs{1}, critERPs{2}, critERPs{3}, critERPs{4}, critERPs{5})

figure(8)
cfg = [];
cfg.colorbar = 'yes';
cfg.layout = 'biosemi32.lay';
cfg.xlim = [0.2 0.3];
cfg.ylim = [-13 13];
ft_topoplotER(cfg, ctrlERPs{1}, ctrlERPs{2}, ctrlERPs{3}, ctrlERPs{4}, ctrlERPs{5})









% https://www.fieldtriptoolbox.org/tutorial/eventrelatedaveraging/

