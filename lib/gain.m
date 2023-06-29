function data = gain(data,startgain,lingain,expgain,doplotgain,fs)
%
% data = gain(data,startgain,lingain,expgain,doplotgain,fs)
% 
% Increase the amplitude of later arrivals by multiplying each trace with a
% gain function. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - startgain: Time in nanoseconds after which arrivals should be gained. 
% - lingain: Increase of linear gain (put to 0 to avoid any linear gain)
% - expgain: Increase of exponential gain (put to 0 to avoid any
%   exponential gain)
% - doplotgain: Plot the gain function (1) or not (0)
% - fs: Fontsize for plot of gain function
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

if startgain<0
    error('The starting point of the gain function has to be larger than zero.')
elseif startgain>data.tvec(end)
    error('The starting point of the gain function cannot be later than the last sample of the time vector.')
end

if lingain<0
    error('The linear gain has to be larger or equal to zero.')
end

if expgain<0
    error('The exponential gain has to be larger or equal to zero.')
end

dt = data.tvec(2) - data.tvec(1);
startgainel = round(startgain/dt);
gainfun = ones(size(squeeze(data.cube(:,1,1))));
gaincoords = linspace(1,size(data.cube,1)-startgainel,size(data.cube,1)-startgainel);
gainfun(startgainel+1:end) = gainfun(startgainel+1:end)+(gaincoords*lingain).';
gainfun(startgainel+1:end) = gainfun(startgainel+1:end)+(exp(gaincoords*expgain)-1.0).';

for iy=1:size(data.cube,3)
    for ix=1:size(data.cube,2)
        data.cube(:,ix,iy) = data.cube(:,ix,iy).*gainfun;
    end
end

if doplotgain==1
    figure;
    plot(gainfun,data.tvec,'k')
    ylim([data.tvec(1),data.tvec(end)])
    xlabel('Gain [-]')
    ylabel('Time [ns]')
    set(gca,'YDir','reverse')
    set(gca,'Fontsize',fs)
end
