function data = subtract_mean(data,twin)
%
% data = subtract_mean(data,twin)
%
% Subtract a mean value in a moving window from each trace to remove a
% constant offset (DC shift) of the trace. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - twin: The size of the moving window in nanoseconds to calculate the 
%   mean value to be subtracted. 
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

if twin<=0.0
    error('The time window has to be a positive value.')
end

dt = data.tvec(2)-data.tvec(1);
twinel = round(twin/dt);

for iy=1:size(data.cube,3)
    for ix=1:size(data.cube,2)
        for it=1:size(data.cube,1)
            if (it-round(twinel/2)<1 && it+round(twinel/2)>size(data.cube,1))
                temp = mean(data.cube(:,ix,iy));
            elseif it-round(twinel/2)<1
                temp = mean(data.cube(1:it+round(twinel/2),ix,iy));
            elseif it+round(twinel/2)>size(data.cube,1)
                temp = mean(data.cube(it-round(twinel/2):end,ix,iy));
            else
                temp = mean(data.cube(it-round(twinel/2):it+round(twinel/2),ix,iy));
            end
            data.cube(it,ix,iy) = data.cube(it,ix,iy)-temp;
        end
    end
end
