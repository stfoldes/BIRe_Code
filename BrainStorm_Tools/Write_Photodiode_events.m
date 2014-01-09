Extract.file_name{1}='ns06s01r13';
Extract.file_path='/home/foldes/Data/MEG/NS06/S01/';
Extract.sample_rate = 1000;

diode_offsetFIFtimeS = Calc_Photodiode_Change_FIFtimeS(Extract);

% DO SOMETHING HERE TO ADJUST POINTS (like taking offset OR onset, removing points)
disp([num2str(length(diode_offsetFIFtimeS)) ' Events found'])
% diode_offsetFIFtimeS(9)=[];
% diff(diode_offsetFIFtimeS)

StretchFigure(2)
Export_Eve_File(diode_offsetFIFtimeS,'photodiode',Extract);



% Markers for movement-cue onset based off of photodiode trigger

relative_movement_onset_timeS = ([1:9]*2)+0; % in seconds

movement_onsetS=[];
for itrial = 1:length(diode_offsetFIFtimeS)
    movement_onsetS = [movement_onsetS diode_offsetFIFtimeS(itrial)+relative_movement_onset_timeS];
end

disp([num2str(length(movement_onsetS)) ' Events found'])
% diff(movement_onsetS')
figure;
stem(movement_onsetS',ones(1,length(movement_onsetS)),'k')


Export_Eve_File(movement_onsetS,'movement_cue',Extract);



