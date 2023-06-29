function plot_trace(data,xfrac,yfrac,fs)
%
% plot_trace(data,xfrac,yfrac,fs)
% 
% Plot a single trace of the measurements and its corresponding amplitude 
% spectrum. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - xfrac: Fractional position of trace in inline direction, where 0 refers
%   to the first trace, 0.5 the middle trace and 1 the last trace. 
% - yfrac: Fractional position of trace in crossline direction, where 0 
%   refers to the first trace, 0.5 the middle trace and 1 the last trace. 
% - fs: Fontsize to be used in plots. 
% 
% Output: 
%   none
%
% This file is part of GPR_SEAL. GPR_SEAL is free software: you can 
% redistribute it and/or modify it under the terms of the GNU General 
% Public License as published by the Free Software Foundation, either 
% version 3 of the License, or (at your option) any later version. 
% GPR_SEAL is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for 
% more details. You should have received a copy of the GNU General Public 
% License along with GPR_SEAL. If not, see 
% <https://www.gnu.org/licenses/>. 

xel = round(xfrac*size(data.cube,2));
if xel<=0
    xel=1;
end

if xel>size(data.cube,2)
    xel = size(data.cube,2);
end

yel = round(yfrac*size(data.cube,3));
if yel<=0
    yel=1;
end

if yel>size(data.cube,3)
    yel = size(data.cube,3);
end

% Calculate the frequency spectrum of the selected trace
dt = data.tvec(2)-data.tvec(1); % Time sampling in nanoseconds
ftrace = fft(squeeze(data.cube(:,xel,yel)))*dt;
df=1/(size(data.cube,1)*dt); % Frequency sampling in Gigahertz
nf=size(data.cube,1);
freqaxis=linspace(0,nf/2+1,nf/2)*df; % Frequency axis in Gigahertz
ftrace = ftrace(1:length(freqaxis)); % Extract the first half of the spectrum

figure; 
subplot(121)
plot(zeros(size(data.tvec)),data.tvec,'r','Linewidth',2)
hold on
plot(data.cube(:,xel,yel),data.tvec,'k','Linewidth',2)
hold off
ylim([data.tvec(1),data.tvec(end)])
xlabel('Amplitude [-]')
ylabel('Time [ns]')
set(gca,'YDir','reverse')
set(gca,'Fontsize',fs)

subplot(122)
plot(abs(ftrace),freqaxis*1000,'k','Linewidth',2)
ylim([freqaxis(1)*1000,freqaxis(end)*1000])
xlabel('Amplitude [-]')
ylabel('Frequency [MHz]')
set(gca,'YDir','reverse')
set(gca,'Fontsize',fs)
