function data = crossline_interpolation(data,refine_factor)
%
% data = crossline_interpolation(data,refine_factor)
% 
% As the sampling in crossline direction is less than in inline direction,
% the crossline sampling can be increased by interpolating profiles between
% the measurement lines. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - refine_factor: Interpolation factor in crossline direction that 
%   determines how many more profiles are added. To avoid a too heavy load
%   on the memory, do not use a too high factor. 2 is a good choice. 
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

dy = data.yvec(2)-data.yvec(1);
dy_fine = dy/refine_factor;

yvec_fine = data.yvec(1):dy_fine: data.yvec(end);
[in_t,in_x,in_y]=meshgrid(data.xvec,data.tvec,data.yvec);
[out_t,out_x,out_y]=meshgrid(data.xvec,data.tvec,yvec_fine);
data.cube = interp3(in_t,in_x,in_y,data.cube,out_t,out_x,out_y);
if sum(strcmp(fieldnames(data),'GPS_x_grid'))==1
    [in_y_2d,in_x_2d]=meshgrid(data.yvec,data.xvec);
    [out_y_2d,out_x_2d]=meshgrid(yvec_fine,data.xvec);
    data.GPS_x_grid = interp2(in_y_2d,in_x_2d,data.GPS_x_grid,out_y_2d,out_x_2d);
    data.GPS_y_grid = interp2(in_y_2d,in_x_2d,data.GPS_y_grid,out_y_2d,out_x_2d);
end
data.yvec = yvec_fine;
