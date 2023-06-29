function data = add_GPS_grid(data,GPS1,GPS2,GPS3,GPS4)
%
% data = add_GPS_grid(data,GPS1,GPS2,GPS3,GPS4)
% 
% Assign GPS coordinates to each trace by specifying the GPS coordinates
% for the four corners of the measurement area. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - GPS1: GPS coordinate of starting point of first line (North, East). 
% - GPS2: GPS coordinate of end point of first line (North, East). 
% - GPS3: GPS coordinate of end point of last line (North, East). 
% - GPS4: GPS coordinate of starting point of last line (North, East). 
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

% Interpolate the four corners to get the coordinates for each trace
[Y_lines, X_traces] = meshgrid(data.yvec,data.xvec);

data.GPS_x_grid = griddata([data.yvec(1) data.yvec(1) data.yvec(end) data.yvec(end)],...
    [data.xvec(1) data.xvec(end) data.xvec(end) data.xvec(1)],...
    [GPS1(2) GPS2(2) GPS3(2) GPS4(2)],...
    Y_lines, X_traces);

data.GPS_y_grid = griddata([data.yvec(1) data.yvec(1) data.yvec(end) data.yvec(end)],...
    [data.xvec(1) data.xvec(end) data.xvec(end) data.xvec(1)],...
    [GPS1(1) GPS2(1) GPS3(1) GPS4(1)],...
    Y_lines, X_traces);
