%% init

close all
clear
clc

rng('default') % set RNG to default, to have reproducible RNG


%% parameters

nSample  = 1000    ; % first  dimension : number of lines
nChannel =   20    ; % second dimension : number of columns
% nSample  =   20    ; % first  dimension : number of lines
% nChannel = 1000    ; % second dimension : number of columns
dt       =    0.010; % seconds

time = (0 : nSample-1) * dt;


%% generate known signals

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

noise_variance = 0.1;
noise = noise_variance * randn(nSample, nChannel);


%% aggrerate all signals

signal = repmat(s_low, [1 nChannel]) .* w(1,:) + repmat(s_high, [1 nChannel]) .* w(2,:) + noise;

% center it
signal = signal - mean(signal);

% % standardize it
% signal = signal ./ std(signal);


%% SVD

input = signal            ; tic; [u1,s1,v1] = svd( input , 0); fprintf('svd( s       ) took %7.3fms \n', toc*1000)   % [nSample  x nChannel]
input = signal  * signal' ; tic; [u2,s2,v2] = svd( input , 0); fprintf('svd( s  * s'' ) took %7.3fms \n', toc*1000)  % [nSample  x nSample ]
% input = signal' * signal  ; tic; [u3,s3,v3] = svd( input , 0); fprintf('svd( s'' * s  ) took %7.3fms \n', toc*1000)  % [nChannel x nChannel]

% Sign convention : the max(abs(PCs)) is positive
[~,maxabs_idx] = max(abs(u1));
[m,n]          = size(u1);
idx            = 0:m:(n-1)*m;
val            = u1(maxabs_idx + idx);
sgn            = sign(val);
v1             = v1 .* sgn;
u1             = u1 .* sgn;
[~,maxabs_idx] = max(abs(u2));
[m,n]          = size(u2);
idx            = 0:m:(n-1)*m;
val            = u2(maxabs_idx + idx);
sgn            = sign(val);
v2             = v2 .* sgn;
u2             = u2 .* sgn;


%% plots

% signal we are looking for
figure('NumberTitle','off','Name','target signal')
plot(time, s_low + s_high)

% principal components
f = figure('NumberTitle','off','Name','PCs');
tg = uitabgroup(f);
for i = 1 : nChannel
    t = uitab(tg);
    t.Title = num2str(i);
    a = axes(t);
    
    s = subplot(3,1,[1 2]);
    hold(s,'on')
    plot(s, time, u1(:,i))
    plot(s, time, u2(:,i))
    legend(s, {'s', 'cov(s)'})
    
    s = subplot(3,1,3);
    hold(s,'on')
    plot(s, time, u1(:,i) - u2(:,i))
    legend(s, {'s - cov(s)'})
end
