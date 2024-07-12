%-----Processing MEG data-----
cfg = [];
cfg.dataset = 'sample_introduction/data/S01_AEF_20131218_01_600Hz.ds';
cfg.continuous = 'yes';
cfg.channel = 31:304; %MEG channels
data_raw = ft_preprocessing(cfg);

meg_data = data_raw.trial{1}; 


%-----Processing stimulus data-----
cfg = [];
cfg.dataset = 'sample_introduction/data/S01_AEF_20131218_01_600Hz.ds';
cfg.trialdef.eventtype = 'UPPT001';
cfg = ft_definetrial(cfg);
event = ft_read_event(cfg.dataset);

stimDataStandard = zeros(1, size(meg_data, 2));
stimDataDeviant = zeros(1, size(meg_data, 2));

Fs = 600;

for i = 1:length(event)
    %filtering for only beeps
    if strcmp(event(i).type, 'standard') || strcmp(event(i).type, 'deviant')
        samplePoint = round((event(i).sample - data_raw.sampleinfo(1) + 1) * (Fs / data_raw.fsample));
        
        if samplePoint > 0 && samplePoint <= length(stimDataStandard) && samplePoint <= length(stimDataDeviant)
            %assign a value based on the type of beep
            if strcmp(event(i).type, 'standard')
                stimDataStandard(samplePoint) = 1;  % Standard beep
            elseif strcmp(event(i).type, 'deviant')
                stimDataDeviant(samplePoint) = 1;  % Deviant beep
            end
        end
    end
end

meg_data = meg_data';
stimDataStandard = stimDataStandard';
stimDataDeviant = stimDataDeviant';

%-----Using mTRFtoolbox-----
% For standards
modelStandard = mTRFtrain(stimDataStandard, meg_data*0.0313, Fs, 1, -100, 500, 0.1);

% For deviants
modelDeviant = mTRFtrain(stimDataDeviant, meg_data*0.0313, Fs, 1, -100, 500, 0.1);

% Plot TRF for Standard
subplot(2,1,1);
mTRFplot(modelStandard, 'trf', 'all', 85, [-100,500]);
title('Standard Tones TRF (Fz)');
ylabel('Amplitude (a.u.)');
xlabel('Time lags (ms)');


% Plot TRF for Deviant
subplot(2,1,2);
mTRFplot(modelDeviant, 'trf', 'all', 85, [-100,500]);
title('Deviant Tones TRF (Fz)');
ylabel('Amplitude (a.u.)');
xlabel('Time lags (ms)');