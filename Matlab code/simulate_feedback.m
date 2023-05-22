% Simulate the feedback

[x1, fs] = audioread('.\examples\ex1.wav');
[x2, ~] = audioread('.\examples\ex2.wav');
[x3, ~] = audioread('.\examples\ex3.wav');
[x4, ~] = audioread('.\examples\ex4.wav');
[x5, fs] = audioread('.\examples\ex5.wav');
x = vertcat(x1, x2, x3, x4, x5);
x = x';

%% Feedback path
fileID = fopen("bcoff_pixel.txt");
A = fscanf(fileID, '%f');
h = A(1533:end)';
figure;plot(h)
frame_processing_time = 0.008;
dt = fs*frame_processing_time;
h = [zeros(1, dt), h];
M = length(h);

%% Frame settings
Nx = length(x);
frame_size = 0.016;
L = fs*frame_size;

N = 2^(ceil(log2(L + M)));
G = 1;
position = 0;
z = zeros(1, N);
H = fft(h, N);
out = [];
y = [];
while position + L <= Nx 
    recording = x(position + (1:L)) + z(1:L);
    y = [y, recording];
    %Process
    recording = G*recording;
    X = fft(recording, N);
    z = [z(L+1:end), zeros(1, L)] + ifft(X.*H, N);
    out = [out, z(1:L)];  
    position = position + L;  
end

out1 = out;

%% With overlap
Nx = length(x);
frame_size = 0.016;
L = fs*frame_size;
win = hanning(L)';
hop = L/2;


N = 2^(ceil(log2(L + M)));
G = 2;
position = 0;
z = zeros(1, N);
H = fft(h, N);
out = [];
y = [];
z = zeros(1, N);
prev_recording = zeros(1, L);
prev_out = zeros(1, L);  

while position + L <= Nx
    recording = x(position + (1:L)) + z(1:L);
    recording = recording.*win;
    overlapped_recording = prev_recording(L/2+1:end) + recording(1:L/2);
    y = [y, overlapped_recording];
    prev_recording = recording;
    
    %Process
    recording = G*recording;
    X = fft(recording, N);
    z = [z(L+1:end), zeros(1, L)] + ifft(X.*H, N);
    overlapped_out = prev_out(L/2+1:end) + z(1:L/2);
    out = [out, overlapped_out];
    prev_out = z(1:L);
    position = position + L/2;  
end

figure;plot(x)
hold on; plot(out)

%%




%% Spectogram
figure;
spectrogram(out/norm(out), hamming(256), 240, 1024*2, fs,'yaxis','reassigned');title('y');

