function data = set_caxis(data,yfrac,fs)
%
% data = set_caxis(data,yfrac,fs)
% 
% Adjust and fix the color scaling in plots. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - yfrac: Fractional position of measurement line in crossline direction, 
%   where 0 is the first line, 0.5 the middle line and 1 the last line. 
% - fs: Fontsize to be used in plots. 
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

yel = round(yfrac*size(data.cube,3));
if yel<=0
    yel=1;
end

if yel>size(data.cube,3)
    yel = size(data.cube,3);
end

k=0;
while k~=3
    h = figure(42);
    if sum(strcmp(fieldnames(data),'zvec'))==1
        imagesc(data.xvec,data.zvec,squeeze(data.cube(:,:,yel)))
    else
        imagesc(data.xvec,data.tvec,squeeze(data.cube(:,:,yel)))
    end
    if sum(strcmp(fieldnames(data),'cax'))==1
        caxis(data.cax)
    end
    colormap('gray')
    colorbar
    xlabel('Distance [m]')
    if sum(strcmp(fieldnames(data),'zvec'))==1
        ylabel('Depth [m]')
    else
        ylabel('Time [ns]')
    end
    title(['Profile at ',num2str(data.yvec(yel)),' m crossline distance'])
    set(gca,'Fontsize',fs)

    k = menu('Color axis','Broaden','Narrower','Quit');

    if k==1
        caxis(caxis*2);
    elseif k==2
        caxis(caxis/2);
    end
    data.cax = caxis;
    
    if k==3
        close(h);
    end
end
