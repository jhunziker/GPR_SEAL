function data = bandpass_filter(data,fstart_bottom,fstart_top,fend_top,fend_bottom)
%
% data = bandpass_filter(data,fstart_bottom,fstart_top,fend_top,fend_bottom)
%
% Remove signal at unwanted low and high frequencies by passing only a band
% of frequencies. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - fstart_bottom: Start frequency of filter slope in MHz: Signal at a 
%   higher frequency is passed at reduced amplitude. 
% - fstart_top: Start frequency of passband in MHz: Signal at a higher
%   frequency is passed at full amplitude. 
% - fend_top: End frequency of passband in MHz: Signal at a higher
%   frequency is passed at reduced amplitude. 
% - fend_bottom: End frequency of filter slope in MHz: Signal at a higher
%   frequency is not passed at all. 
% 
% Output: 
% - data: The updated data structure that was loaded. 
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

% Fourier transformation
dt = (data.tvec(2)-data.tvec(1)); % Time sampling in nanoseconds
fcube =fft(data.cube,[],1)*dt;
df=1/(size(data.cube,1)*dt); % Frequency sampling in Gigahertz
nf=size(data.cube,1);
freqaxis=linspace(0,nf/2+1,nf/2)*df; % Frequency axis in Gigahertz
fcube = fcube(1:length(freqaxis),:,:); % Extract the first half of the spectrum

% Create filter
[~,fstart_bottom_el] = min(abs(freqaxis*1000-fstart_bottom));
[~,fstart_top_el] = min(abs(freqaxis*1000-fstart_top));
[~,fend_top_el] = min(abs(freqaxis*1000-fend_top));
[~,fend_bottom_el] = min(abs(freqaxis*1000-fend_bottom));
bp_filter = zeros(size(freqaxis));
x_slope_template = linspace(0,pi,100);
y_slope_template = ((cos(x_slope_template)+1)/2).^2;
bp_filter(fstart_bottom_el:fstart_top_el) = fliplr(interp1(x_slope_template,y_slope_template,linspace(0,pi,fstart_top_el-fstart_bottom_el+1)));
bp_filter(fstart_top_el+1:fend_top_el-1) = ones(size(bp_filter(fstart_top_el+1:fend_top_el-1)));
bp_filter(fend_top_el:fend_bottom_el) = interp1(x_slope_template,y_slope_template,linspace(0,pi,fend_bottom_el-fend_top_el+1));
fcube = repmat(bp_filter.',[1,size(data.cube,2),size(data.cube,3)]).*fcube;

% Inverse Fourier transformation
addfreq = zeros(size(data.cube));
addfreq(1:length(freqaxis),:,:) = fcube;
data.cube = 2*real(nf*ifft(addfreq,[],1)*df);
