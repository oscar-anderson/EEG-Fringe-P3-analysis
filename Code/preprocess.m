function preprocessedData = preprocess(dataFile)

% Assign raw data file to configuration.
cfg.dataset = dataFile;

%% Band-pass filter.
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.1 30]; % Use range specified by Alberto Aviles.
cfg.bpfilttype = 'fir'; % Butterworth does not work with this lower band.

%% Notch (band-stop) filter.
cfg.bsfreq = [7 8]; % Remove SSVEP of 7.52Hz.

%% Re-reference.
cfg.reref = 'yes';
cfg.refmethod = 'avg'; % Use average.

cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.refchannel = {'T7', 'T8'}; % Use average of mastoids.

%% Segment.
cfg.trialdef.eventtype = 'STATUS'; % Events are marked as type 'STATUS'.
cfg.trialdef.eventvalue = 111:170; % Select events of interest.
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

cfg.artfctdef.threshold.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.artfctdef.threshold.bpfilter = 'no';
cfg.artfctdef.threshold.min = -100;
cfg.artfctdef.threshold.max = 100;

[cfg, artifact] = ft_artifact_threshold(cfg, dataSFR);

preprocessedData = ft_rejectartifact(cfg, dataSFR);

end
