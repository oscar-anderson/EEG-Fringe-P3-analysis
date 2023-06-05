%% SEGMENT DATA/DEFINE TRIALS.

% Presumably, the events are marked within the data using the markers
% (given in markers.csv)?

% USE IF NEED TO CHECK EVENTTYPE/EVENTVALUE:
% cfg = [];
% cfg.dataset = filename;
% cfg.trialdef.eventtype = '?';
% dataTrials = ft_definetrial(cfg)

% Clear configuration struct.
cfg = [];

% Specify data.
cfg.dataset = filename;

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

% Define trials with specified configuration settings.
cfg = ft_definetrial(cfg);

% This outputs the cfg struct with the field 'trl', which contains a matrix
% of the begin sample, end sample, the offset and the condition.

% Display output.
disp(cfg.trl);