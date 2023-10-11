%% Extract and organise trials of subjects' individual data.

% Initialise array to store each subject's organised trial data.
trialData = cell(1, 14);

% Iterate through first five whole-subject data structs.
for iSubject = 1:5
    allSubjectData{iSubject} = ppData_noComp{iSubject};
end

% Account for separate block data structs for subjects 6-9.
allSubjectData{6} = {ppData_noComp{6}, ppData_noComp{7}, ppData_noComp{8}};
allSubjectData{7} = {ppData_noComp{9}, ppData_noComp{10}, ppData_noComp{11}};
allSubjectData{8} = {ppData_noComp{12}, ppData_noComp{13}, ppData_noComp{14}};
allSubjectData{9} = {ppData_noComp{15}, ppData_noComp{16}, ppData_noComp{17}};

% Continue with final five whole-subject data structs, following block structs.
for iSubject = 10:14
    allSubjectData{iSubject} = ppData_noComp{iSubject + 8};
end

% Loop through subjects, blocks and pairs to extract trials.
for subjectNo = 1:14
    for iBlock = 1:3
        for pairLevel = 1:5
            
            % Translate block iteration index.
            if iBlock == 1
                block = 'trump';
            elseif iBlock == 2
                block = 'markle';
            elseif iBlock == 3
                block = 'incidental';
            end
            
            % Account for separate block files for subjects 6-9.
            if subjectNo == 6 || subjectNo == 7 || subjectNo == 8 || subjectNo == 9
                data = allSubjectData{subjectNo}{iBlock};
            else
                data = allSubjectData{subjectNo};
            end
            
            % Initialise IDs for specified morph pairs of specified block.
            if strcmp(block, 'trump')
                if pairLevel == 5
                    critMorphIDs = 149:150;
                    ctrlMorphIDs = 119:120;
                elseif pairLevel == 4
                    critMorphIDs = 147:148;
                    ctrlMorphIDs = 117:118;
                elseif pairLevel == 3
                    critMorphIDs = 145:146;
                    ctrlMorphIDs = 115:116;
                elseif pairLevel == 2
                    critMorphIDs = 143:144;
                    ctrlMorphIDs = 113:114;
                elseif pairLevel == 1
                    critMorphIDs = 141:142;
                    ctrlMorphIDs = 111:112;
                else
                    error('pairLevel must be a value from 1:5. ')
                end
            elseif strcmp(block, 'markle')
                if pairLevel == 5
                    critMorphIDs = 159:160;
                    ctrlMorphIDs = 129:130;
                elseif pairLevel == 4
                    critMorphIDs = 157:158;
                    ctrlMorphIDs = 127:128;
                elseif pairLevel == 3
                    critMorphIDs = 155:156;
                    ctrlMorphIDs = 125:126;
                elseif pairLevel == 2
                    critMorphIDs = 153:154;
                    ctrlMorphIDs = 123:124;
                elseif pairLevel == 1
                    critMorphIDs = 151:152;
                    ctrlMorphIDs = 121:122;
                else
                    error('pairLevel must be a value from 1:5. ')
                end
            elseif strcmp(block, 'incidental')
                if pairLevel == 5
                    critMorphIDs = 169:170;
                    ctrlMorphIDs = 139:140;
                elseif pairLevel == 4
                    critMorphIDs = 167:168;
                    ctrlMorphIDs = 137:138;
                elseif pairLevel == 3
                    critMorphIDs = 165:166;
                    ctrlMorphIDs = 135:136;
                elseif pairLevel == 2
                    critMorphIDs = 163:164;
                    ctrlMorphIDs = 133:134;
                elseif pairLevel == 1
                    critMorphIDs = 161:162;
                    ctrlMorphIDs = 131:132;
                else
                    error('pairLevel must be a value from 1:5. ')
                end
            else
                error("Block must be either 'trump', 'markle' or 'incidental'. ")
            end
            
            % Find indices of trials involving selected morph pair.
            critTrialsIdxs = find(data.trialinfo == critMorphIDs(1) | data.trialinfo == critMorphIDs(2));
            ctrlTrialsIdxs = find(data.trialinfo == ctrlMorphIDs(1) | data.trialinfo == ctrlMorphIDs(2));
            
            % Create data struct containing only selected probe trials.
            cfg = [];
            cfg.trials = critTrialsIdxs;
            criticalTrials = ft_selectdata(cfg, data);
            
            % Create data struct containing only selected irrelevant trials.
            cfg = [];
            cfg.trials = ctrlTrialsIdxs;
            controlTrials = ft_selectdata(cfg, data);
            
            % Log subject's probe and irrelevant trial data in corresponding array cell.
            trialData{subjectNo}{iBlock}{pairLevel} = {criticalTrials, controlTrials};

        end
    end
end