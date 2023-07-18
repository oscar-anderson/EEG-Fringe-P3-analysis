%% Set up paths, folders and files.
% Clear windows.
clear
close all

% cd rds/projects/2017/schofiaj-01/Oscar_dissertation

% Add path to FieldTrip toolbox.
restoredefaultpath
addpath('Code');
addpath('Data');
addpath('Code/fieldtrip-20230522');

% Initialise data files.
subject_1 = 'al001.bdf';
subject_2 = 'al002.bdf';
subject_3 = 'al003.bdf';
subject_4 = 'al004.bdf';
subject_5 = 'al005.bdf';
subject_6_trump = '006trump.bdf';
subject_6_markle = '006meg.bdf';
subject_6_incidental = '006unf.bdf';
subject_7_trump = '007trump.bdf';
subject_7_markle = '007meg.bdf';
subject_7_incidental = '007unf.bdf';
subject_8_trump = '008trump.bdf';
subject_8_markle = '008meg.bdf';
subject_8_incidental = '008unf.bdf';
subject_9_trump = '009trump.bdf';
subject_9_markle = '009meg.bdf';
subject_9_incidental = '009unf.bdf';
subject_10 = '010.bdf';
subject_11 = '011.bdf';
subject_12 = '012.bdf';
subject_13 = '013.bdf';
subject_14 = '014.bdf';

% Combine all files into cell array.
allFiles = {subject_1, subject_2, subject_3, subject_4, subject_5, ...
            subject_6_trump, subject_6_markle, subject_6_incidental, ...
            subject_7_trump, subject_7_markle, subject_7_incidental, ...
            subject_8_trump, subject_8_markle, subject_8_incidental, ...
            subject_9_trump, subject_9_markle, subject_9_incidental, ...
            subject_10, subject_11, subject_12, subject_13, subject_14};

% Initialise variables to preprocess and store preprocessed files.
numFiles = length(allFiles);
ppData = cell(1, length(allFiles));

%% Apply preprocessing.
% Preprocess each raw data file to produce a data struct for each.
for iFile = 1:numFiles
    ppData{iFile} = preprocess(allFiles{iFile});
end

%% Append block data structs.
% Append data structs for individual block files to get whole-subject structs.
idxSubject6 = find(contains(allFiles, 'subject_6')); % Find block file indices.
idxSubject7 = find(contains(allFiles, 'subject_7'));
idxSubject8 = find(contains(allFiles, 'subject_8'));
idxSubject9 = find(contains(allFiles, 'subject_9'));

% Assign data structs to variables.
subject_1_data = ppData{1};
subject_2_data = ppData{2};
subject_3_data = ppData{3};
subject_4_data = ppData{4};
subject_5_data = ppData{5};
subject_6_data = ft_appenddata(cfg, ppData{idxSubject6}); % Append block files.
subject_7_data = ft_appenddata(cfg, ppData{idxSubject7});
subject_8_data = ft_appenddata(cfg, ppData{idxSubject8});
subject_9_data = ft_appenddata(cfg, ppData{idxSubject9});
subject_10_data = ppData{end-4};
subject_11_data = ppData{end-3};
subject_12_data = ppData{end-2};
subject_13_data = ppData{end-1};
subject_14_data = ppData{end};

% Update ppData cell array.
ppDataAppended = {subject_1_data, subject_2_data, subject_3_data, subject_4_data ...
          subject_5_data, subject_6_data, subject_7_data, subject_8_data, ...
          subject_9_data, subject_10_data, subject_11_data, subject_12_data, ...
          subject_13_data, subject_14_data};

%% Independent component analysis.
cfg = [];
cfg.method = 'fastica';

comp = ft_componentanalysis(cfg, subject_1_data); % Replace with current subject data variable.

% Inspect components
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

% Reject components.
cfg = [];

cfg.component = [2 8 12 18]; % Replace with current subject data components.

sub_X_data_compOut = ft_rejectcomponent(cfg, comp); % Replace with current subject data variable.

%% Channel/trial-level artifact rejection.
cfg = [];

cfg.method = 'channel';
cfg.channel = {'Fp1', 'AF3', 'F7', 'F3', 'FC1', 'FC5', 'T7', 'C3', 'CP1', 'CP5', 'P7', 'P3', 'Pz', 'PO3', 'O1', 'Oz', 'O2', 'Po4', 'P4', 'P8', 'CP6', 'CP2', 'C4', 'T8', 'FC6', 'FC2', 'F4', 'F8', 'AF4', 'Fp2', 'Fz', 'Cz', 'A1', 'A2', 'LEOG', 'REOG', 'UEOG', 'DEOG', 'EXG7', 'EXG8'};

sub_X_data_noArt = ft_rejectvisual(cfg, sub_X_data_compOut); % Replace with current subject data variable.

%% Generate ERPs.

% Initialise parameters.
numMorphs = 5;
numSubjects = 14;

% Generate ERPs for each subject and collate morph types for grand averaging.
for iMorph = 1:numMorphs
    for iSubject = 1:numSubjects
        subjectData = ppDataAppended{iSubject};

        % Create parent struct to contain subject ERPs.
        % Create new sub-struct for each subject.
        % For each subject, create cell array for each block.
        % Call generateERPs to store morph pair ERPs in cell arrays for critical/control conditions.
        subjectERPs.(sprintf('subject_%d', iSubject)).trump = generateERPs(ppDataAppended{iSubject}, ppDataAppended{iSubject}.trialinfo, 'trump');
        subjectERPs.(sprintf('subject_%d', iSubject)).markle = generateERPs(ppDataAppended{iSubject}, ppDataAppended{iSubject}.trialinfo, 'markle');
        subjectERPs.(sprintf('subject_%d', iSubject)).incidental = generateERPs(ppDataAppended{iSubject}, ppDataAppended{iSubject}.trialinfo, 'incidental');
    
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



