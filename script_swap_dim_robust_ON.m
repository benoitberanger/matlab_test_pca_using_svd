%% init

close all
clear
clc

rng('default') % set RNG to default, to have reproducible RNG


%% parameters

% comment / uncomment below

% EEG realistic values : nSample >> nChannel

% nSample  = 1000    ; % first  dimension / number of lines
% nChannel =   20    ; % second dimension : number of columns
% dt       =    0.010; % seconds
% noise_variance = 0.1;

% fMRI realisitc values : nChannel >> nSample

nSample  =  100    ; % first  dimension : number of lines
nChannel =  500    ; % second dimension : number of columns
dt       =    0.100; % seconds
noise_variance = 1.0;


%% generate known signals

time = (0 : nSample-1) * dt;

% low frequency rectangle
f_low = 0.3; % Hz
a_low = 1; % amplitude
s_low = a_low*square(2*pi*f_low*time)';

% high frequency sinus
f_high = 2; % Hz
a_high = 0.1; % amplitude
s_high = a_high*sin(2*pi*f_high*time)';


%% generate weights and noise

w = rand(2,nChannel);

noise = noise_variance * randn(nSample, nChannel);


%% aggrerate all signals

signal = repmat(s_low, [1 nChannel]) .* w(1,:) + repmat(s_high, [1 nChannel]) .* w(2,:) + noise;

% center it
signal = signal - mean(signal);

% % standardize it
% signal = signal ./ std(signal);


%% SVD

timeseries = signal; 
[eigenvariate, eigenvalues, eigenimage, vairance_explained, mean_across_voxels] = PCA_adapted_from_SPM12( timeseries );


%% plots

% signal we are looking for
figure('NumberTitle','off','Name','target signal')
plot(time, s_low + s_high)

% principal components
f = figure('NumberTitle','off','Name','PCs');
tg = uitabgroup(f);
for i = 1 : size(eigenvariate,2)
    t = uitab(tg);
    t.Title = num2str(i);
    a = axes(t);
    hold(a,'on')
    plot(a, time, eigenvariate(:,i))    
end
