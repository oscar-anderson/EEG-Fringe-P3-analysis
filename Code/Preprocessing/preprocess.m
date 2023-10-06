%% Preprocess.
function preprocessedData = preprocess(dataFile)

% This function applies all of our chosen initial preprocessing steps to an
% input raw data file, outputting the preprocessed data as a FieldTrip data
% structure with all parameters of this preprocessing pipeline applied.

% Input:
    % dataFile = a raw EEG data file to be preprocessed.

% Output:
    % preprocessedData = a FieldTrip data structure constituting the input
    % data with the specified preprocessing steps applied.

% Required packages:
    % FieldTrip EEG Toolbox (v20230522).

% Author: Oscar Anderson (MSc student, University of Birmingham).
% Created: 01/03/23
% Updated: 16/07/23

%% Assign input raw data file to configuration.
cfg.dataset = dataFile;

%% Segment.
cfg.trialdef.eventtype = 'STATUS'; % Events are marked as type 'STATUS'.
cfg.trialdef.eventvalue = 111:170; % Select events of interest.
cfg.trialdef.prestim = 0.5; % Specify time before event to include.
cfg.trialdef.poststim = 1.5; % Specify time after event to include.

cfg = ft_definetrial(cfg);

%% Baseline correct.
cfg.demean = 'yes';
cfg.baselinewindow = [-0.2 0]; % Use baseline window of -200:0ms pre-stimulus onset.
cfg.detrend = 'yes'; % Remove drift.

%% Band-pass filter.
cfg.bpfilter = 'yes';
cfg.bpfreq = [0.3 30]; % Use range specified by Alberto Aviles.
cfg.bpfilttype = 'fir'; % Butterworth does not work with this lower band.

%% Notch (band-stop) filter.
cfg.bsfilter = 'yes';
cfg.bsfilttype = 'fir'; % Use Finite Impulse Response filter.
cfg.bsfreq = [7 8]; % Remove Steady-State Visual-Evoked Potential of 7.52Hz.

%% Re-reference.
cfg.reref = 'yes';
cfg.refmethod = 'avg'; % Use average of reference channels.
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.refchannel = {'T7', 'T8'}; % Use mastoid channels as reference.

%% Apply above preprocessing steps.
data = ft_preprocessing(cfg);

%% Apply artifact exclusion threshold.
cfg = [];
cfg.artfctdef.threshold.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.artfctdef.threshold.bpfilter = 'no'; % Do not re-apply band-pass filter.
cfg.artfctdef.threshold.min = -100; % Limit acceptable amplitude threshold to -100mv:100mv.
cfg.artfctdef.threshold.max = 100;

[cfg, artifact] = ft_artifact_threshold(cfg, data);

preprocessedData = ft_rejectartifact(cfg, data); % Output preprocessed, thresholded data as FieldTrip struct.

end
