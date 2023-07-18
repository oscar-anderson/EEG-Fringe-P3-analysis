%% Generate ERPs.

% Initialise parameters.
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

% Configure ft_timelockgrandaverage parameters to calculate grand ERPs.
cfg.method = 'across';
cfg.parameter = 'avg';
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};
cfg.latency = 'all'; % Time window of interest.
cfg.keepindividual = 'no'; % Specify whether to keep individual data in cfg.

% Generate grand average ERPs across morphs of all subjects, for each block.
for iGrand = 1:5
    grandERPs.(sprintf('grandCritTrump%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.trump.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlTrump%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.trump.control.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCritMarkle%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.markle.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlMarkle%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.markle.control.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCritIncidental%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.incidental.critical.(sprintf('morph%d', iGrand)));
    grandERPs.(sprintf('grandCtrlIncidental%d', iGrand)) = ft_timelockgrandaverage(cfg, morphERPs.incidental.control.(sprintf('morph%d', iGrand)));
end
