function data = autostatic(data,refine_factor)
%
% data = autostatic(data,refine_factor)
% 
% Automatic static correction: A mean trace for the complete dataset is
% calculated. Then, each trace is crosscorrelated with that mean trace and
% shifted in time accordingly. To allow small shifts the data is for the
% time being interpolated in time. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - refine_factor: Interpolation factor in time that determines how many
%   more samples the time vector should contain. 
%   CAUTION: A number like 10 produces good results but needs a lot of
%   memory. If you are low on memory use 1. 
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

if refine_factor<1
    error('The refine factor has to be at least 1.')
end

critshift = 100; % Shifts larger than this value are not carried out. 

% Interpolate in the time dimension to allow for shifts of the trace of
% less than the time sampling. 
tvec_fine = linspace(data.tvec(1),data.tvec(end),refine_factor*length(data.tvec));
[in_t,in_x,in_y]=meshgrid(data.xvec,data.tvec,data.yvec);
[out_t,out_x,out_y]=meshgrid(data.xvec,tvec_fine,data.yvec);
cube_fine = interp3(in_t,in_x,in_y,data.cube,out_t,out_x,out_y);

% Calculate mean trace
meantrace = squeeze(mean(mean(cube_fine,2),3));

% Calculate crosscorrelation of each trace with the mean trace and apply
% shift. 
for iy=1:size(cube_fine,3)
    for ix=1:size(cube_fine,2)
        [~,el] = max(xcorr(meantrace,cube_fine(:,ix,iy)));
        shift = el-size(cube_fine,1);
        if abs(shift)>critshift
            shift=0;
        end
        if shift<0
            cube_fine(:,ix,iy) = [squeeze(cube_fine(abs(shift):end,ix,iy));zeros(abs(shift)-1,1)];
        elseif shift>0
            cube_fine(:,ix,iy) = [zeros(shift,1)-1;squeeze(cube_fine(1:end-shift,ix,iy))];
        end
    end
end

% Interpolate data back on the original sampling
data.cube = interp3(out_t,out_x,out_y,cube_fine,in_t,in_x,in_y);
