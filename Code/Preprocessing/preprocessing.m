%% Preprocessing.

% Author: Oscar Anderson (MSc student, University of Birmingham)
% Created: 01/04/23
% Updated: 06/07/23

% Description:
    % This script 

%% Load raw data.

% Restore windows.
clear
close all

% Change to relevant directory.
cd('/rds/projects/2017/schofiaj-01/Oscar_dissertation_final/')

% Define necessary paths.
restoredefaultpath
addpath('fieldtrip-20230522');
addpath('Code');
ft_defaults

% Initialise raw data files.
rawData = {'al001.bdf', 'al002.bdf', 'al003.bdf', 'al004.bdf', 'al005.bdf' ...
               '006trump.bdf', '006meg.bdf', '006unf.bdf', ...
               '007trump.bdf', '007meg.bdf', '007unf.bdf', ...
               '008trump.bdf', '008meg.bdf', '008unf.bdf', ...
               '009trump.bdf', '009meg.bdf', '009unf.bdf', ...
               '010.bdf', '011.bdf', '012.bdf', '013.bdf', '014.bdf'};

% Get number of raw data files.
numFiles = length(rawData);

% Prepare array to store preprocessed data.
preProcessed = cell(numFiles);

%% Preprocessing.

% Apply preprocessing.
for iFile = 1:numFiles
    preProcessed{iFile} = preprocess(rawData{iFile});
end

%% Inspect preprocessed data.

% Configure visualisation parameters.
% cfg = [];
% cfg.ylim = [-10 10];

% Visualise particular preprocessed data.
% ft_databrowser(cfg, preProcessed{1}); % < Amend index to select data.

%% Independent Component Analysis: Preparation.

% Initialise cell array to store post-ICA data.
postICA = cell(size(preProcessed));

%% Independent Component Analysis: Identify noise sources.

% Clear configuration.
cfg = [];

% Use 'fastica' algorithm for computational efficiency.
cfg.method = 'fastica';

% Decompose selected data into independent components.
comp = ft_componentanalysis(cfg, preProcessed{1}); % < Amend index to select data.

% Inspect topographies of components.
cfg = []; % Clear configuration.
cfg.layout = 'biosemi32.lay'; % Data uses Biosemi 32-channel scalp layout.
cfg.viewmode = 'component'; % View components.
cfg.component = 1:39; % Show all 39 components in the data.

ft_topoplotIC(cfg, comp);

% Inspect time series of components.
cfg.ylim = [-96 96]; % Adjust y-axis limits for optimal viewing.

ft_databrowser(cfg, comp);

%% Independent Component Analysis: Remove identified noise sources.

% Clear configuration.
cfg = [];

% Select components to remove from selected data.
cfg.component = [];

% Remove components.
postICA{1} = ft_rejectcomponent(cfg, comp); % < Amend index to select data.

%% Channel/trial rejection: Preparation.

% Initialise array to store post-channel/trial-rejection data.
% postProcessed = cell(size(postICA));

%% Channel/trial rejection: Inspect channels/trials.

% Clear configuration.
cfg = [];

% Adjust y-axis limits for optimal viewing.
cfg.ylim = [-10 10];

% Inspect channels/trials in post-ICA data time series.
ft_databrowser(cfg, postICA{1}); % < Amend index to select data.

%% Channel rejection.

% Clear configuration.
cfg = [];

% View all channels per trial in GUI.
cfg.method = 'trial';

% Specify channels to view in GUI.
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz'};

% Open GUI to select and remove bad channels.
postProcessed{1} = ft_rejectvisual(cfg, postICA{1}); % < Amend index to select data.

%% Trial rejection.

% Clear configuration.
cfg = [];

% View all trials per channel in GUI.
cfg.method = 'channel';

% Specify channels to view in GUI.
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz'};

% Open GUI to select and remove bad trials.
postProcessed{1} = ft_rejectvisual(cfg, postProcessed{1}); % < Amend index to select data.
