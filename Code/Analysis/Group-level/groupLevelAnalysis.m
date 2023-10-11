%% Group-level statistical analysis: Cluster-based paired-sample permutation test.

%% Define neighbours for each electrode in contrast data.

% Clear configuration
cfg = [];
cfg.method = 'distance';
cfg.layout = 'biosemi32.lay';

% Generate neighbours for each contrast.
for iPairLevel = 1:5
    groupTrumpNeighbours{iPairLevel} = ft_prepare_neighbours(cfg, groupTrumpProbe{iPairLevel});
    groupMarkleNeighbours{iPairLevel} = ft_prepare_neighbours(cfg, groupMarkleProbe{iPairLevel});
    groupIncidentalNeighbours{iPairLevel} = ft_prepare_neighbours(cfg, groupIncidentalProbe{iPairLevel});
end
% Note that if no neighbours are defined for a channel in a data struct
% that is subsequently included in the contrast, that channel will be
% excluded from the contrast.

%% Initialise cell arrays to store contrast statistics for each condition.
groupTrumpStats = cell(1, 5);
groupMarkleStats = cell(1, 5);
groupIncidentalStats = cell(1, 5);

%% Configure design matrix.

% Specify block to select subject-level probe ERPs from.
contrastBlock = 'trump';
pairLevel = 5;

% Select indices to use based on above parameters.
if strcmp(contrastBlock, 'trump')
    probeBlock = 1;
    irrelevantBlock = 2;
    statsArray = groupTrumpStats;
elseif strcmp(contrastBlock, 'markle')
    probeBlock = 3;
    irrelevantBlock = 4;
    statsArray = groupMarkleStats;
elseif strcmp(contrastBlock, 'incidental')
    probeBlock = 5;
    irrelevantBlock = 6;
    statsArray = groupIncidentalStats;
end

% Select all subject-level probe and irrelevant ERPs for given block and pair level.
subjectProbeERPs = {subjectERPs{probeBlock}{pairLevel}{:}}; 
subjectIrrelevantERPs = {subjectERPs{irrelevantBlock}{pairLevel}{:}};

% Get number of subject-level ERPs in the probe/irrelevant contrast variables.
numSubjectProbeERPs = size(subjectProbeERPs);
numSubjectIrrelevantERPs = size(subjectIrrelevantERPs);

% Number of observations in each paired-samples permutation test variable should be the same.
if numSubjectProbeERPs ~= numSubjectIrrelevantERPs
    error('Unequal number of subject-level ERPs being contrasted.')
else
    numSubjectERPs = numSubjectProbeERPs;
end

% Define design matrix accordingly (independent variables/units of observation).
design = [ones(1, numSubjectERPs), 2*ones(1, numSubjectERPs); 1:numSubjectERPs, 1:numSubjectERPs];

%% Run cluster-based paired-samples permutation test.

cfg = []; % Clear configuration for test parameters.
cfg.neighbours = groupTrumpNeighbours{5}; % Select predefined channel neighbours to use.
cfg.parameter = 'avg'; % Specify to use .avg field 
cfg.method = 'montecarlo'; % Use Monte Carlo resampling for permutation.
cfg.statistic = 'depsamplesT'; % Run paired-samples t-tests.
cfg.correctm = 'cluster'; % Use cluster-based multiple comparisons correction.
cfg.clusterstatistic = 'maxsum'; % Use maximum sample-level t-value as cluster-level t value.
cfg.clusteralpha = 0.025; % Significance threshold for samples to be included in clusters.
cfg.minnbchan = 0; % Minimum number of significant neighbours required for sample to be included in cluster.
cfg.tail = 1; % Positive one-tailed sample-level t-tests.
cfg.clustertail = 1; % Positive one-tailed cluster-level permutation test.
cfg.alpha = 0.05; % Threshold for determining significance of final cluter-level statistic.
cfg.numrandomization = 500; % Start with this number of permutations. Increase if near sig.
cfg.design = design; % Test of difference between two input conditions (crit/control).
cfg.ivar = 1; % Indicate independent variables design matrix row.
cfg.uvar = 2; % Indicate units of observation design matrix row.
cfg.channel = 'all'; % Perform analysis across all channels.
cfg.latency = 'all'; % Perform analysis across full latency of epochs.

statsArray{pairLevel} = ft_timelockstatistics(cfg, subjectERPs{probeBlock}{pairLevel}{:}, subjectERPs{irrelevantBlock}{pairLevel}{:});

%% Plot cluster-based paired-samples permutation test results.

cfg = []; % Clear configuration for cluster plot parameters.
cfg.alpha = 0.05; % Specify threshold for determining cluster significance.
cfg.highlightseries = {'labels', 'labels', 'off', 'off', 'off'}; % Highlight significant clusters with channel labels.
cfg.subplotsize = [3, 3]; % Specify dimensions of plot grid.
cfg.layout = 'biosemi32.lay'; % Use Biosemi 32-channel layout.
cfg.toi = 0.3:0.05:1; % Specify time window to view within -0.5:1.5s of data.
cfg.colorbar = 'yes'; % Include amplitude colourbar.
cfg.zlim = [-2 4]; % Specify amplitude range to view.

ft_clusterplot(cfg, statsArray{pairLevel});
