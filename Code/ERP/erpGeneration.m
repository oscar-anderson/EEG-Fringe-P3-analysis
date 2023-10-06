%% Generate subject-level ERPs from pairs of morph trials.

% Initialise number of pairs to form.
numPairs = 5;

% Initialise arrays to store probe and irrelevant ERPs of each block.
subTrumpProbe = cell(1, numPairs);
subTrumpIrrelevant = cell(1, numPairs);
subMarkleProbe = cell(1, numPairs);
subMarkleIrrelevant = cell(1, numPairs);
subIncidentalProbe = cell(1, numPairs);
subIncidentalIrrelevant = cell(1, numPairs);

% Average across trials of each probe and irrelevant morph pair level.
for iPair = 1:numPairs
    subTrumpProbe{iPair} = generateSubjectERPs(postICA, 'trump', 'probe', iPair);
    subTrumpIrrelevant{iPair} = generateSubjectERPs(postICA, 'trump', 'irrelevant', iPair);
    subMarkleProbe{iPair} = generateSubjectERPs(postICA, 'markle', 'probe', iPair);
    subMarkleIrrelevant{iPair} = generateSubjectERPs(postICA, 'markle', 'irrelevant', iPair);
    subIncidentalProbe{iPair} = generateSubjectERPs(postICA, 'incidental', 'probe', iPair);
    subIncidentalIrrelevant{iPair} = generateSubjectERPs(postICA, 'incidental', 'irrelevant', iPair);
end

%% Tidy up array of ERPs.

% Organise subject-level ERPs to iterate through.
subjectERPs = {subTrumpProbe, subTrumpIrrelevant, subMarkleProbe, subMarkleIrrelevant, subIncidentalProbe, subIncidentalIrrelevant};

% Iterate through probe and irrelevant ERPs.
for iCondition = 1:2:6
    for jPair = 1:5

        % Find cells containing probe and irrelevant ERPs.
        probeCells = find(~cellfun('isempty', subjectERPs{iCondition}{jPair}));
        irrelevantCells = find(~cellfun('isempty', subjectERPs{iCondition}{jPair}));
        commonCells = intersect(probeCells, irrelevantCells);
        
        % Redefine subject-level ERPs array to only contain filled and equivalent probe/irrelevant ERPs. 
        subjectERPs{iCondition}{jPair} = subjectERPs{iCondition}{jPair}(commonCells);
        subjectERPs{iCondition + 1}{jPair} = subjectERPs{iCondition + 1}{jPair}(commonCells);

    end
end

%% Modify latencies of subject-level ERPs, to improve statistical test precision.

% Iterate through probe and irrelevant ERPs.
for jCondition = 1:2:6
    for kPair = 1:5
        numERPs = length(subjectERPs{jCondition}{kPair});
        for iERP = 1:numERPs
            cfg = []; % Clear configuration.
            cfg.latency = [0.3, 1]; % Change latency to 300-1000ms post-stimulus onset.

            % Redefine latency of probe and irrelevant subject-level ERPs.
            subjectERPs{jCondition}{kPair}{iERP} = ft_selectdata(cfg, subjectERPs{jCondition}{kPair}{iERP});
            subjectERPs{jCondition + 1}{kPair}{iERP} = ft_selectdata(cfg, subjectERPs{jCondition + 1}{kPair}{iERP});
        end
    end
end

%% Generate group-level ERPs from subject-level morph pair ERPs.

% Clear configuration.
cfg = [];

% Initialise arrays to store probe and irrelevant ERPs of each block.
groupTrumpProbe = cell(1, numPairs);
groupTrumpIrrelevant = cell(1, numPairs);
groupMarkleProbe = cell(1, numPairs);
groupMarkleIrrelevant = cell(1, numPairs);
groupIncidentalProbe = cell(1, numPairs);
groupIncidentalIrrelevant = cell(1, numPairs);

% Average across all subject-level ERPs of each probe and irrelevant morph pair level.
for jERP = 1:numERPs
    groupTrumpProbe{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{1}{jERP}{:});
    groupTrumpIrrelevant{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{2}{jERP}{:});
    groupMarkleProbe{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{3}{jERP}{:});
    groupMarkleIrrelevant{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{4}{jERP}{:});
    groupIncidentalProbe{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{5}{jERP}{:});
    groupIncidentalIrrelevant{jERP} = ft_timelockgrandaverage(cfg, subjectERPs{6}{jERP}{:});
end

%% Visualise group-level ERPs.

% Specify channel to plot.
electrode = 'Pz'; % < Amend to select channel.
electrodeIdx = find(strcmp(ERPdata{pair}.label, electrode));

% Plot all group-level Trump probe morph pair ERPs.
plot(groupTrumpProbe{5}.time, groupTrumpProbe{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupTrumpProbe{4}.time, groupTrumpProbe{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupTrumpProbe{3}.time, groupTrumpProbe{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupTrumpProbe{2}.time, groupTrumpProbe{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupTrumpProbe{1}.time, groupTrumpProbe{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Trump block probe morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

% Plot all group-level Trump irrelevant morph pair ERPs.
plot(groupTrumpIrrelevant{5}.time, groupTrumpIrrelevant{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupTrumpIrrelevant{4}.time, groupTrumpIrrelevant{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupTrumpIrrelevant{3}.time, groupTrumpIrrelevant{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupTrumpIrrelevant{2}.time, groupTrumpIrrelevant{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupTrumpIrrelevant{1}.time, groupTrumpIrrelevant{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Trump block irrelevant morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

% -------------------------------------------------------------------------

% Plot all group-level Markle probe morph pair ERPs.
plot(groupMarkleProbe{5}.time, groupMarkleProbe{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupMarkleProbe{4}.time, groupMarkleProbe{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupMarkleProbe{3}.time, groupMarkleProbe{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupMarkleProbe{2}.time, groupMarkleProbe{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupMarkleProbe{1}.time, groupMarkleProbe{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Markle block probe morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

% Plot all group-level Markle irrelevant morph pair ERPs.
plot(groupMarkleIrrelevant{5}.time, groupMarkleIrrelevant{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupMarkleIrrelevant{4}.time, groupMarkleIrrelevant{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupMarkleIrrelevant{3}.time, groupMarkleIrrelevant{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupMarkleIrrelevant{2}.time, groupMarkleIrrelevant{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupMarkleIrrelevant{1}.time, groupMarkleIrrelevant{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Markle block irrelevant morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

% -------------------------------------------------------------------------

% Plot all group-level Incidental probe morph pair ERPs.
plot(groupIncidentalProbe{5}.time, groupIncidentalProbe{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupIncidentalProbe{4}.time, groupIncidentalProbe{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupIncidentalProbe{3}.time, groupIncidentalProbe{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupIncidentalProbe{2}.time, groupIncidentalProbe{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupIncidentalProbe{1}.time, groupIncidentalProbe{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Incidental block probe morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

% Plot all group-level Incidental irrelevant morph pair ERPs.
plot(groupIncidentalIrrelevant{5}.time, groupIncidentalIrrelevant{5}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [1, 0.5, 0.2])
hold on
plot(groupIncidentalIrrelevant{4}.time, groupIncidentalIrrelevant{4}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.85, 0.3, 0.35]);
plot(groupIncidentalIrrelevant{3}.time, groupIncidentalIrrelevant{3}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.7, 0.38, 0.9]);
plot(groupIncidentalIrrelevant{2}.time, groupIncidentalIrrelevant{2}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.3, 0.3, 1]);
plot(groupIncidentalIrrelevant{1}.time, groupIncidentalIrrelevant{1}.avg(electrodeIdx, :), 'LineWidth', 3, 'Color', [0.2, 0.75, 0.45]);
leg = legend('Morphs 9-10', 'Morphs 7-8', 'Morphs 5-6', 'Morphs 3-4', 'Morphs 1-2', 'FontSize', 15);
title('Across-subject ERPs at Pz for Incidental block irrelevant morph pairs', 'FontSize', 13);
xlabel('Time (seconds)', 'FontSize', 16);
ylabel('Amplitude (\muV)', 'FontSize', 16);
xlim([-0.2 1.5]);
ylim([-6 8]);
leg.AutoUpdate = 'off';
xline(0, '--', 'LineWidth', 1.5);
yline(0, '--', 'LineWidth', 1.5);
box off
ax = gca;
ax.FontSize = 14;

