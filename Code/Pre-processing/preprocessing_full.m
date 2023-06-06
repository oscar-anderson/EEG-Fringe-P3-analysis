%% Load data.

% Clear workspace.
clear
close all

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('fieldtrip-20230522');
addpath('participants');
addpath('morph eeg data');
ft_defaults

% Initialise .BDF data file.
dataFile = 'participants\006meg.bdf';

% Feed data file to configuration struct.
cfg.dataset = dataFile;

% Specify that data is continuous.
cfg.continuous = 'yes';

%% Pre-processing.

%       THIS DOESN'T WORK, UNSURE WHY:

% Band pass filter (as in Alberto's report).
% band = [0.1 30];
% cfg.bpfilter = 'yes';
% cfg.bpfreq = band;

% Low-pass filter.
cfg.preproc.lpfilter = 'yes';
cfg.preproc.lpfreq = 30;

%       ISSUES WITH THIS, SPECIFICALLY:

% High-pass filter.
% cfg.preproc.hpfilter = 'yes';
% cfg.preproc.hpfreq = 0.1;

%% Re-referencing.

% Re-reference to mastoids (T7 & T8 in Biosemi ActiveTwo 32-channel system).
cfg.preproc.reref = 'yes';
cfg.preproc.refchannel = {'T7', 'T8'};

% Load cfg into data struct.
data = ft_preprocessing(cfg);

%% Downsample data.

% Define new sampling rate.
cfg.resamplefs = 512;

% Remove linear trend/gradual drift from ERPs.
cfg.preproc.detrend = 'no';

% Demeaning baseline correction.
cfg.preproc.demean = 'yes';

% Define stimulus presentation time window, to subtract pre-stimulus
% baseline activity from, to distinguish signal from noise.
cfg.preproc.baselinewindow = 'all'; % Data not yet segmented, no trials defined yet.

% Set whether to display progress feedback during resampling.
cfg.feedback = 'no';

% Define subset of trials from input data struct to be sampled.
cfg.trials = 'all'; % Data has not yet been segmented, there is only one.

% Set whether to add channel with original sample indices.
cfg.sampleindex = 'no'; % Data has not yet been segmented, samples don't have separate indices.

% Resample and update data struct.
dsData = ft_resampledata(cfg, data);

%% Segment data.

% Presumably, the events are marked within the data using the markers
% (given in markers.csv)?

% USE IF NEED TO CHECK EVENTTYPE/EVENTVALUE:
% cfg.dataset = dataFile;
% cfg.trialdef.eventtype = '?';
% dataTrials = ft_definetrial(cfg)

% Feed data file to configuration struct.
cfg.dataset = dataFile;

% Specify type of events in data.
cfg.trialdef.eventtype = 'STATUS';

% Define time windows of interest around stimulus presentations (seconds).
cfg.trialdef.pre = 0.2;
cfg.trialdef.post = 1;
% (Taken from Alberto's report).

% Specify custom function for defining trials/epochs.
cfg.trialfun = 'segmentMarkle';
% This function should identify the events of interest, as indicated by the
% markers in the values field of the ft_read_events output struct which
% match the markers given in markers.csv.

% Set format of trl output ('numeric' or 'table').
cfg.representation = 'numeric';

% Define trials, from downsampled data, with specified configuration settings.
cfg = ft_definetrial(cfg);

% This outputs the cfg struct with the field 'trl', which contains a matrix
% of the begin sample, end sample, the offset and the condition.

%        HOW IS THIS CFG FIELD USED ON THE DATA?
%        THIS DOESN'T WORK ANYMORE:
% cfg.channel = 'all';
% cfg.continuous = 'yes';
% dsDataSeg = ft_preprocessing(cfg);

%% Independent component analysis.

% Run ICA with downsampled, segmented data.
cfg = [];
cfg.method = 'runica';
comp = ft_componentanalysis(cfg, dsDataSeg);

% Specify components to be plotted.
cfg.component = 

% Load Biosemi 32 layout.
cfg.layout = 'biosemi32.lay';

% Plot topographic map to inspect components.
cfg.comment = 'no';
ft_topoplotIC(cfg, comp)

% Further inspect components.
cfg = [];
cfg.layout = 'biosemi32.lay';
cfg.viewmode = 'component';
ft_databrowser(cfg, comp)

% Specify and remove artifacts found from visual inspection.
cfg = [];
cfg.component = [ ];
dsDataSegClean = ft_rejectcomponent(cfg, comp, dsDataSeg);


%% Visualise data.

cfg.channel = 'all';
cfg.viewmode = 'vertical';
cfg.ylim = [-10 10];
cfg.fontsize = 8;
cfg.position = [0 0 800 800];
ft_databrowser(cfg, dsData)

%% Trialfun
function [trl, event] = segmentMarkle(cfg)

% This function should execute the selection of the specific events of
% interest (i.e. those indicated by the markers provided by Alberto),
% corresponding to the critical/control morph face stimuli presentations.
% This will then be fed into the ft_definetrial function to define the time
% windows around these events (i.e. the trials) for the analysis.

% Outputs:
%   trl = should be an Nx3 matrix where:
%       Each row = single epoch of interest.
%       First column = start of epoch (sample number)
%       Second column = end of epoch (sample number)
%       Third column = offset of start sample of epoch, relative to time point 0 of that epoch (sample number)
%   event = optional output struct, to allow for own reference of original events.

% Get event information from data.
event = ft_read_event(cfg.dataset);

% Get header information from data.
hdr = ft_read_header(cfg.dataset);

% Get markers and sample information for read events.
values = [event(find(strcmp('STATUS', {event.type}))).value]';
samples = [event(find(strcmp('STATUS', {event.type}))).sample]';

% Calculate number of samples before/after event, using pre-stim/post-stim seconds.
preStim = -round(cfg.trialdef.pre * hdr.Fs); % (Use negative to ensure pre).
postStim = round(cfg.trialdef.post * hdr.Fs); % (Use positive to ensure post).
% (Multiplying seconds by sampling rate gives number of samaples).

% Prepare trl matrix to contain event-of-interest information.
trl = [];

% Specify markers for events of interest (critical stimuli presentation).
critMarkers = [151:160];

% Specify markers for events of interest (control stimuli presentation).
ctrlMarkers = [121:130];

% Iterate through all events in data.
for iEvent = 1:length(values)
    
    % Grab marker value of each event.
    iValue = values(iEvent);

    % Grab sample number of each event.
    iSample = samples(iEvent);
    
    % If a critical/ctrl marker is found, log start sample, end sample and
    % offset in trl output matrix.
    if ismember(iValue, critMarkers) || ismember(iValue, ctrlMarkers)
       trl(iEvent, 1) = samples(iEvent) + preStim;
       trl(iEvent, 2) = samples(iEvent) + postStim;
       trl(iEvent, 3) = preStim;
    end

end

% Remove zeros (events of no interest) from trl matrix.
eventsOfInterest = trl(:, 1) ~= 0;
trl = trl(eventsOfInterest, :);

end
