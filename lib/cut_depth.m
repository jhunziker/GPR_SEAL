function data = cut_depth(data,frac_cut)
%
% data = cut_depth(data,frac_cut)
% 
% Delete everything below a fractional depth. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - frac_cut: Fractional cut between 0 and 1. If 1 is chosen, everything is
%   kept. If 0 is chosen, everything is deleted except a minimal amount of
%   data, that is always kept. 
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

delel = round(frac_cut*size(data.cube,1));
if delel<=0
    delel = 20;
end
if delel>size(data.cube,1)
    delel = size(data.cube,1);
end
data.cube(delel:end,:,:) = [];
data.tvec(delel:end) = [];
if sum(strcmp(fieldnames(data),'zvec'))==1
    data.zvec(delel:end) = [];
end
