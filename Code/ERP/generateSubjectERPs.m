function ERPs = generateSubjectERPs(dataset, block, criticality, pairLevel)

% Specify markers for critical and control morphs for given block.
if strcmp(block, 'trump')
    if strcmp(criticality, 'critical')
        if pairLevel == 1
            morphs = [141 142];
        elseif pairLevel == 2
            morphs = [143 144];
        elseif pairLevel == 3
            morphs = [145 146];
        elseif pairLevel == 4
            morphs = [147 148];
        elseif pairLevel == 5
            morphs = [149 150];
        end
    elseif strcmp(criticality, 'control')
        if pairLevel == 1
            morphs = [111 112];
        elseif pairLevel == 2
            morphs = [113 114];
        elseif pairLevel == 3
            morphs = [115 116];
        elseif pairLevel == 4
            morphs = [117 118];
        elseif pairLevel == 5
            morphs = [119 120];
        end
    end
elseif strcmp(block, 'markle')
    if strcmp(criticality, 'critical')
        if pairLevel == 1
            morphs = [151 152];
        elseif pairLevel == 2
            morphs = [153 154];
        elseif pairLevel == 3
            morphs = [155 156];
        elseif pairLevel == 4
            morphs = [157 158];
        elseif pairLevel == 5
            morphs = [159 160];
        end
    elseif strcmp(criticality, 'control')
        if pairLevel == 1
            morphs = [121 122];
        elseif pairLevel == 2
            morphs = [123 124];
        elseif pairLevel == 3
            morphs = [125 126];
        elseif pairLevel == 4
            morphs = [127 128];
        elseif pairLevel == 5
            morphs = [129 130];
        end
    end
elseif strcmp(block, 'incidental')
    if strcmp(criticality, 'critical')
        if pairLevel == 1
            morphs = [161 162];
        elseif pairLevel == 2
            morphs = [163 164];
        elseif pairLevel == 3
            morphs = [165 166];
        elseif pairLevel == 4
            morphs = [167 168];
        elseif pairLevel == 5
            morphs = [169 170];
        end
    elseif strcmp(criticality, 'control')
         if pairLevel == 1
            morphs = [131 132];
        elseif pairLevel == 2
            morphs = [133 134];
        elseif pairLevel == 3
            morphs = [135 136];
        elseif pairLevel == 4
            morphs = [137 138];
        elseif pairLevel == 5
            morphs = [139 140];
         end
    end
end

numSubjects = length(dataset);
ERPs = cell(1, numSubjects);

for iSubject = 1:numSubjects
    disp(['Getting trials and pair level ERP for subject ', num2str(iSubject)])
    cfg = [];
    morphIdxs = dataset{iSubject}.trialinfo == morphs(1) | dataset{iSubject}.trialinfo == morphs(2);
    if any(morphIdxs)
        disp(['Trials for morphs ', num2str(morphs), ' found, producing data struct restricted to these trials.'])
        cfg.trials = morphIdxs;
        erpData = ft_selectdata(cfg, dataset{iSubject});
        cfg = [];
        cfg.preproc.demean = 'yes';
        cfg.preproc.baselinewindow = [-0.2, 0];
        ERPs{iSubject} = ft_timelockanalysis(cfg, erpData);
    else
        disp(['No trials for morphs ', num2str(morphs), ' found. Skipping to next subject...'])
        continue
    end
end