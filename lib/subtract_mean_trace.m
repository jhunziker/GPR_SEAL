function data = subtract_mean_trace(data,xwin,tstart,tend)
%
% data = subtract_mean_trace(data,xwin,tstart,tend)
%
% Subtract a mean trace in the time window defined by tstart and tend. 
% xwin is the distance in meters to be used to calculate the mean trace. 
% tstart is the start time from which onwards the mean trace is subtracted.
% tend is the end time before which the mean trace is subtracted. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - xwin: The size of the moving window in meters. Traces inside this
%   window are taken into account to calculate the mean trace. 
% - tstart: Start time in nanoseconds from which onwards the mean trace is 
%   subtracted. 
% - tend: End time in nanoseconds before which the mean trace is
%   subtracted.
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

if xwin<=0.0
    error('The size of the moving window has to be a positive value.')
end

if tstart>tend
    temp = tend;
    tend = tstart;
    tstart = temp;
end

dx = data.xvec(2)-data.xvec(1);
xwinel = round(xwin/dx);
dt = data.tvec(2)-data.tvec(1);
tstartel = round(tstart/dt);
tendel = round(tend/dt);

if tstartel<1
    tstartel=1;
end

if tendel>size(data.cube,1)
    tendel=size(data.cube,1);
end

for iy=1:size(data.cube,3)
    for ix=1:size(data.cube,2)
        if (ix-round(xwinel/2)<1 && ix+round(xwinel/2)>size(data.cube,2))
            meantrace = mean(squeeze(data.cube(:,:,iy)),2);
        elseif ix-round(xwinel/2)<1
            meantrace = mean(squeeze(data.cube(:,1:ix+round(xwinel/2),iy)),2);
        elseif ix+round(xwinel/2)>size(data.cube,2)
            meantrace = mean(squeeze(data.cube(:,ix-round(xwinel/2):end,iy)),2);
        else
            meantrace = mean(squeeze(data.cube(:,ix-round(xwinel/2):ix+round(xwinel/2),iy)),2);
        end

        data.cube(tstartel:tendel,ix,iy) = data.cube(tstartel:tendel,ix,iy)-meantrace(tstartel:tendel);
    end
end
