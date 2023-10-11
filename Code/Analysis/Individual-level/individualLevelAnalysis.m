%% Individual-level analysis.

% Select subject, block and pair of probe and irrelevant trials to contrast.
subjectNo = 4;
blockNo = 2;
pairLevel = 5;

%% Define neighbours.

% Set parameters for neighbour definitions.
cfg = [];
cfg.method = 'distance';
cfg.layout = 'biosemi32.lay';

neighbours = ft_prepare_neighbours(cfg, trialData{subjectNo}{blockNo}{pairLevel}{1});

%% Configure design matrix.

% Get number of trials being contrasted.
numProbeTrials = length(trialData{subjectNo}{blockNo}{pairLevel}{1}.trial);
numIrrelevantTrials = length(trialData{subjectNo}{blockNo}{pairLevel}{2}.trial);

% Define design matrix.
design = [ones(1, numProbeTrials), ones(1, numIrrelevantTrials)*2];

%% Run cluster-based independent samples permutation test.

% Set parameters for statistical test.
cfg = []; % Clear configuration to set test parameters.
cfg.neighbours = neighbours; % Specify defined neighbours of each channel.
cfg.parameter = 'trial'; % Specify that trial field of subject data structs is to be used.
cfg.method = 'montecarlo'; % Use Monte Carlo resampling for permutation.
cfg.statistic = 'indepsamplesT'; % Run paired samples t-test.
cfg.correctm = 'cluster'; % Use cluster-level t as test statistic for MCP correction.
cfg.clusterstatistic = 'maxsum'; % Use max cluster-level t-stat as test statistic.
cfg.clusteralpha = 0.025; % Significance threshold for samples to be included in clusters.
cfg.minnbchan = 0; % Minimum number of significant neighbours required for sample to be included in cluster.
cfg.tail = 1; % One-tailed t-tests (positive).
cfg.clustertail = 1; % One-tailed cluster permutation (positive).
cfg.alpha = 0.05; % Threshold for determining significance of final cluter-level statistic.
cfg.numrandomization = 500; % Start with this number of permutations. Increase if near significance.
cfg.design = design; % Test of difference between specified design conditions (crit/control).
cfg.ivar = 1; % Number of independent variables being compared.
% cfg.uvar = 2; % Number of observations being compared.
cfg.channel = 'all'; % Start with all scalp channels. Later, try only those around Pz.
cfg.latency = 'all'; % Start with full time interval. Later, try period around P300.

% Run permutation test.
individualLevelStats = ft_timelockstatistics(cfg, trialData{subjectNo}{blockNo}{pairLevel}{1}, trialData{subjectNo}{blockNo}{pairLevel}{2});

%% Plot significant clusters.

% Set parameters for cluster plots.
cfg = []; % Clear configuration to set plot parameters.
cfg.alpha = 0.05; % Significance threshold for clusters to be highlighted.
cfg.highlightseries = {'labels', 'labels', 'off', 'off', 'off'}; % Highlight significant clusters by their labels.
cfg.subplotsize = [3, 3]; % Set grid dimensions for plots display.
cfg.layout = 'biosemi32.lay'; % Use Biosemi 32-channel scalp layout.
cfg.toi = 0.3:0.05:1; % Show significant clusters over specified time window.
cfg.colorbar = 'yes'; % Include amplitude colourbar.
cfg.zlim = [-2 4]; % Set limits for amplitude colourbar.

% Plot significant clusters.
ft_clusterplot(cfg, individualLevelStats)
