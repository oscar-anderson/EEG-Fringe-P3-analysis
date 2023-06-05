%% OPEN/INSPECT BDFs.

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('C:\Users\Oscar\Documents\MSc\Research project\Code\fieldtrip-20211209');
addpath('C:\\Users\Oscar\Documents\MSc\Research project\Code\participants');
addpath('C:\\Users\Oscar\Documents\MSc\Research project\Code\morph eeg data');
ft_defaults

% Initialise .BDF data file.
filename = 'C:\Users\Oscar\Documents\MSc\Research project\Code\participants\006meg.bdf';

% Initialise variable for fieldtrip configuration.
cfg = [];

% Define .BDF file as data in configuration.
cfg.dataset = filename;

% Specify that data is continuous.
cfg.continuous = 'yes';

% Load the BDF file without any pre-processing options applied.
data = ft_preprocessing(cfg);

% Use ft_databrowser to visually inspect the data.
cfg.channel = 'all';
cfg.viewmode = 'vertical';
ft_databrowser(cfg, data);