%% DOWNSAMPLE BDF.

% BDF data automatically uses a high sampling rate (~2000Hz min.). This is
% unnecessary for our purposes and causes issues with RAM. We will
% therefore downsample to the standard level of 512Hz.
    
% Clear configuration struct.
cfg = [];

% Specify data.
cfg.dataset = filename;

% Define new sampling rate.
cfg.resamplefs = 512;

% Remove linear trend/gradual drift from ERPs.
cfg.detrend = 'no';

% Demeaning baseline correction.
cfg.demean = 'yes';

% Define stimulus presentation time window, to subtract pre-stimulus
% baseline activity from, to distinguish signal from noise.
cfg.baselinewindow = 'all'; % Data not yet segmented, no trials defined yet.

% Set whether to display progress feedback during resampling.
cfg.feedback = 'no';

% Define subset of trials from input data struct to be sampled.
cfg.trials = 'all'; % Data has not yet been segmented, there is only one.

% Set whether to add channel with original sample indices.
cfg.sampleindex = 'no'; % Data has not yet been segmented, samples don't have separate indices.

% Set whether to apply low pass filter.
cfg.lpfilter = 'yes';

% Set low-pass filter of 30Hz, as in Alberto's report.
cfg.lpfreq = 30;

% Specify type of low-pass filter (default determined in ft_resampledata).
% cfg.lpfilttype = 

% Specify order of low-pass filter (default determined in ft_resampledata).
% cfg.lpfiltord = 

% Resample and update data struct.
data = ft_resampledata(cfg, data);