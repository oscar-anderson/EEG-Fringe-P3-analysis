%% RE-REFERENCE DATA.

% Biosemi data is referenced to a CMS and DRL by default. We must
% re-reference this. Alberto's report specified the mastoid, so we will do
% the same.

% Clear configuration struct.
cfg = [];

% Specify to re-reference data.
cfg.reref = 'yes';

% Specify reference as mastoids on Biosemi ActiveTwo 32-channel layout.
cfg.refchannel = {'T7', 'T8'};

% Apply re-referencing and update data.
data = ft_preprocessing(cfg, data);