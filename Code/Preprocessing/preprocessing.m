%% Load data as segmented trials.
% Clear windows.
clear
close all

% cd rds/projects/2017/schofiaj-01/Oscar_dissertation

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('Code');
addpath('Data');
addpath('Code/fieldtrip-20230522');

% Initialise .BDF data file.
dataFile = 'Data/al001.bdf';

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

[~, artifact] = ft_artifact_threshold(cfg, dataSFR);

%% Visualise pre-processed data.
cfg = [];
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
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
cfg.channel = 'all';
cfg.viewmode = 'component';
cfg.component = 1:39; % A max of 39 components appear when more is specified.
cfg.fontsize = 8;

figure(3)
ft_databrowser(cfg, comp)

figure(4)
ft_topoplotIC(cfg, comp)

%% Reject components.
cfg = [];

cfg.component = [2 8 12 18]; % Components change. Specify with each ICA run!

dataSFRC = ft_rejectcomponent(cfg, comp);

%% Visualise post-ICA data.
cfg = [];
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.ylim = [-10 10];
cfg.fontsize = 8;

ft_databrowser(cfg, dataSFRC)

%% Remove artifact-distorted trials and channels.
cfg = [];

cfg.method = 'channel';
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};

dataSFRCA = ft_rejectvisual(cfg, dataSFRC);

%% Save pre-processed data as new file.


%% Generate ERPs.

numMorphs = 5;
numSubjects = 14;

% Generate ERPs for each subject, and retrieve morph-level ERPs for grand averaging.
for iMorph = 1:numMorphs
    for iSubject = 1:numSubjects
    % Load and read preprocessed data files for each subject.
    file = sprintf('sub%d_pp.bdf', iSubject);
    subjectData = ft_preprocessing(cfg, file);

    % Create parent struct to contain subject ERPs.
    % Create new sub-struct for each subject.
    % For each subject, create cell array for each block.
    % Call generateERPs to store morph pair ERPs in cell arrays for critical/control conditions.
    subjectERPs.(sprintf('sub%d', iSubject)).trump = generateERPs(subjectData, subjectData.trialinfo, 'trump');
    subjectERPs.(sprintf('sub%d', iSubject)).markle = generateERPs(subjectData, subjectData.trialinfo, 'markle');
    subjectERPs.(sprintf('sub%d', iSubject)).incidental = generateERPs(subjectData, subjectData.trialinfo, 'incidental');
    
    % Create new parent struct to contain morph ERPs.
    % Create new sub-struct for each block.
    % Create cell array for current morph type.
    % Retrieve all morphs of that type from across current participant's data.

    % Index into each subject's ERPs, pull out morph type ERP of current iteration.
    
    % Critical morphs.
    morphERPs.trump.critical.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).trump.critical{iMorph}};

    morphERPs.markle.critical.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).markle.critical{iMorph}};

    morphERPs.incidental.critical.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).incidental.critical{iMorph}};

    % Control morphs.
    morphERPs.trump.control.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).trump.control{iMorph}};

    morphERPs.markle.control.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).markle.control{iMorph}};

    morphERPs.incidental.control.(sprintf('morph%d', iMorph)){iSubject} = ...
        {subjectERPs.(sprintf('sub%d', iSubject)).incidental.control{iMorph}};
    end
end

% Here, we end up with six morph structs, which each contain all of the
% morphs of a certain type, from every condition, block and subject.

% Generate grand averages across morph types of all subjects.
cfg.method = 'across';
cfg.parameter = 'avg';
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.latency = 'all'; % Time window of interest.
cfg.keepindividual = 'no'; % Specify whether to keep individual data in cfg.

for iGrand = 1:5
    grandERPs.(sprintf('grandCritTrump%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.trump.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlTrump%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.trump.control.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCritMarkle%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.markle.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlMarkle%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.markle.control.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCritIncidental%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.incidental.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlIncidental%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.incidental.control.(sprintf('morph%d', iGrand)));
end








% https://www.fieldtriptoolbox.org/tutorial/eventrelatedaveraging/

