function ERPs = generateERPs(data, trialData, condition)

% Output:
    % A struct containing two 1x5 cell arrays, containing the ERPs for each critical/control morph pair.

if strcmp(condition, 'trump')
    critPairs = [141:142 143:144 145:146 147:148 149:150];
    ctrlPairs = [111:112 113:114 115:116 117:118 119:120];
elseif strcmp(condition, 'markle')
    critPairs = [151:152 153:154 155:156 157:158 159:160];
    ctrlPairs = [121:122 123:124 125:126 127:128 129:130];
elseif strcmp(condition, 'incidental')
    critPairs = [161:162 163:164 165:166 167:168 169:170];
    ctrlPairs = [131:132 133:134 135:136 137:138 139:140];
else
    error('Invalid condition input')
end

criticals = cell(1, length(critPairs));
controls = cell(1, length(ctrlPairs));

for iPair = 1:length(critPairs)
    critIdxs = find(ismember(trialData, critPairs(iPair)));
    ctrlIdxs = find(ismember(trialData, ctrlPairs(iPair)));

    cfg = [];
    cfg.trials = critIdxs;
    critTrials = ft_selectdata(cfg, data);

    cfg = [];
    cfg.trials = ctrlIdxs;
    ctrlTrials = ft_selectdata(cfg, data);

    cfg = [];
    criticals{iPair} = ft_timelockanalysis(cfg, critTrials);
    controls{iPair} = ft_timelockanalysis(cfg, ctrlTrials);

    ERPs.critical = criticals;
    ERPs.control = controls;
end

end