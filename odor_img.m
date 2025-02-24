function odor_img(runID)
%%% play inose stories and send DAQ pulse at the beginning of each story 
%%% eg. "story 1. You open a bag of potato chips, and the salty, fried
%%% aroma escapes." 7s ISI

%% 
% for debug purpose
% winsize = [10, 10, 800, 600];% chicken debug 
% winsize = [50, 50, 1600, 1200]; % desktop debug

% full-scrren mode
 winsize = [];

% Background color: choose a number from 0 (black) to 255 (white)
backgroundColor = 195;


% Text color: choose a number from 0 (black) to 255 (white)
textColor = 0;
textSize = 40;

% minimal inter-trial interval, must be no smaller than response time out, in
% seconds
min_iti = 5;
% maximal inter-trial interval, in seconds
max_iti = 9;
% mean inter-trial interval, in seconds
avg_iti = 7;

% 'yes' | 'no'
hide_cursor = 'no';

% 'yes' | 'no'
email_results = 'no';

% ports for digitial and analog outputs
daq_dport = 0;

pulse_dur = 0.3;
pulse_dur_sniff = 0.5;
inter_pulse_dur = 0.1;
countdown_dur = 1;


%% make sure randomly gen erated iti have means of ms 
avg_iti = round( avg_iti*1000);
dyn_iti = round( max_iti - min_iti) * 1000;
meanIti = 0;
while abs( meanIti - avg_iti) > eps
    iti = round( min_iti*1000 + dyn_iti*rand( totalTrials-1, 1));
    meanIti = mean( iti);
end
% convert back to seconds
iti = iti/1000;
iti = [min_iti; iti];

%% Set up screen
PsychDefaultSetup( 2);
Screen( 'Preference', 'SkipSyncTests', 2);
whichScreen = max( Screen( 'Screens'));
[w, rect] =  PsychImaging( 'OpenWindow', whichScreen, backgroundColor, winsize);
slack = Screen( 'GetFlipInterval', w)/2;
W = rect( RectRight); % screen width
H = rect( RectBottom); % screen height
if strcmpi( hide_cursor, 'yes')
    HideCursor;
end
Screen('TextSize', w, textSize);
Screen( w, 'FillRect', backgroundColor);
Screen('Flip', w);

[blk_crs_rect, blk_crs_color] = PT_Cross( rect, 50, 4, [0, 0, 0]);

blk_crs_dur = 2;

%% Initilize daq
[daq, err] = TwoDaqsIndex() ;


%% set up stumuli 
datadir = []; 
odorimg_cuelist = fullfile(datadir, ); % fill in file name here 
cuelist = load(odorimg_cuelist);
cuelist = cuelist.cuelist; 

%% initializing
% fixation cross
[fixCr, fixCross] = drawCross( w, backgroundColor);
pos_cross = imageCenter( fixCr, W, H);


%% real experiment

DrawFormattedText( w, 'imagery task. change this as needed', 'center', 'center', textColor);
Screen('Flip',w);

%%% 
KbReleaseWait; 

while true
    [~,kb] = KbWait;
    if kb( KbName( 'space'))==1
        break;
    end
end

%%%% 2 pulses at the beginning of experiment 
DaqDOut( daq(1), daq_dport, 1); WaitSecs( pulse_dur); DaqDOut( daq(1), daq_dport, 0); WaitSecs( inter_pulse_dur);
DaqDOut( daq(1), daq_dport, 1); WaitSecs( pulse_dur); DaqDOut( daq(1), daq_dport, 0); WaitSecs( inter_pulse_dur);


%% play audio 

for i = 1: length(cuelist)

     % draw cross
    Screen( 'FillRect', w, blk_crs_color, blk_crs_rect);
    %     DrawFormattedText( w, sprintf(instructions{5}), W/2-160, 4*H/5-30, textColor);
    Screen( 'Flip', w);
    if i == 1
        WaitSecs( 2);
    else
        WaitSecs( iti(n));
    end

    afname = fullfile(datadir, cuelist{i});
    [wY, wFREQ] = audioread(afname);
    play_sound(afname);

    % single pulse to indicate cue onset 
    DaqDOut( daq(1), daq_dport, 1);
    WaitSecs( pulse_dur);
    DaqDOut( daq(1), daq_dport, 0);

    WaitSecs((length(wY)/wFREQ)+1);

    
end 


%% subfunctions 

function audio_start_time = play_sound(wavfilename_in)

% audiodev = 1; %{'Built-in Output'}
audiodev = 0; % headphone. FOR SCANNER
[y, freq] = audioread(wavfilename_in);
wavedata = y';
nrchannels = size(wavedata,1); % Number of rows == number of channels.

if nrchannels < 2 % make sure the sound has two channels per demo code
    wavedata = [wavedata ; wavedata];
    nrchannels = 2;
end

InitializePsychSound;
pahandle = PsychPortAudio('Open', audiodev, [], 0, freq, nrchannels);
PsychPortAudio('FillBuffer', pahandle, wavedata);

audio_start_time = PsychPortAudio('Start', pahandle, 1, 0, 1); 
end
end 