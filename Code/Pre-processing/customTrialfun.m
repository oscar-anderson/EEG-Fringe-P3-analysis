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
    
    % Grab marker value of each iteration.
    iValue = values(iEvent);

    % Grab sample number of each iteration.
    iSample = samples(iEvent);
    
    % If a critical/ctrl marker is found, log start sample, end sample and
    % offset in trl output matrix.
    if ismember(iValue, critMarkers) || ismember(iValue, ctrlMarkers)
       trl(iEvent, 1) = samples(iEvent) + preStim;
       trl(iEvent, 2) = samples(iEvent) + postStim;
       trl(iEvent, 3) = preStim;
    end

end

% Still need to remove zeros (events of no interest) from trl matrix.

end