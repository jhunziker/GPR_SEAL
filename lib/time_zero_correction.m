function data = time_zero_correction(data,tshift)
%
% data = time_zero_correction(data,tshift)
%
% Delete or add samples before the first arrival in order to have time zero
% positioned correctly. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - tshift: The time shift in nanoseconds. A negative time shift removes
%   the samples at the top, a positive time shift adds samples at the top. 
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

if abs(tshift)>data.tvec(end)
    error('Supplied time shift is larger than length of time vector.')
end

dt = data.tvec(2)-data.tvec(1);
elshift = round(abs(tshift)/dt);

if tshift < 0
    data.cube(1:elshift,:,:) = [];
else
    data.cube = [zeros(elshift,size(data.cube,2),size(data.cube,3));data.cube];
end
data.tvec = linspace(0,size(data.cube,1)-1,size(data.cube,1))*dt;

if sum(strcmp(fieldnames(data),'zvec'))==1
    data.zvec = data.tvec/2*data.v;
end
