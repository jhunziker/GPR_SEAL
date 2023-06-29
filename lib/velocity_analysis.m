function data = velocity_analysis(data,yfrac,xwin,ant_sep,fs)
%
% data = velocity_analysis(data,yfrac,xwin,ant_sep,fs)
% 
% Interactively fit a hyperbola to a diffraction to estimate the velocity
% of the subsurface in meters per nanoseconds. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - yfrac: Fractional position of measurement line in crossline direction, 
%   where 0 is the first line, 0.5 the middle line and 1 the last line. 
% - xwin: Width of superimposed theoretical diffraction hyperbola in meters
% - ant_sep: Antenna separation (distance between source and receiver) in
%   meters. 
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

if xwin<=0.0
    error('The width of the hyperbola has to be a positive value.')
end

v=0.1; % Starting guess of velocity in m/ns

yel = round(yfrac*size(data.cube,3));
if yel<=0
    yel=1;
end

if yel>size(data.cube,3)
    yel = size(data.cube,3);
end

% Store antenna separation for use in migration
data.ant_sep = ant_sep;

k = 0;
while k~=5

    figure(42);
    imagesc(data.xvec,data.tvec,squeeze(data.cube(:,:,yel)))
    if sum(strcmp(fieldnames(data),'cax'))==1
        caxis(data.cax)
    end
    colormap('gray')
    colorbar
    xlabel('Distance [m]')
    ylabel('Time [ns]')
    title(['v = ',num2str(v),' m/ns'])
    set(gca,'Fontsize',fs)

    if exist('x_hyper','var')
        hold on
        plot(x_hyper,t_hyper,'r','Linewidth',2)
        hold off
    end

    k = menu('Velocity analysis','v +','v -','Pick','Set v','Quit');

    dv = 0.005;
    if k==1
        v = v + dv;
        if v>0.3
            v=0.3;
        end
    elseif k==2
        v = v - dv;
        if v<0.02
            v=0.02;
        end
    elseif k==3
        figure(42)
        title('Please, pick a hyperbola.')
        [xpick,tpick] = ginput(1);
    elseif k==4
        data.v = v;
        % When considering the antenna separation when calculating the
        % depth vector, the depth-increment becomes non-constant and values
        % of time equal to zero or close to zero become complex. Therefore,
        % the antenna separation is here ignored. 
        % data.zvec = sqrt((data.tvec/2*v).^2-(ant_sep/2)^2);
        data.zvec = data.tvec/2*v;
    end

    if exist('xpick','var')
        % Calculate depth
        zpick = real(sqrt((tpick/2*v)^2-(ant_sep/2)^2));
        % Picks close to the surface (close to t = 0) become complex. To
        % avoid any problems related to that, the real part is taken. 

        % Determine window to calculate hyperbola in
        xstart = xpick-xwin/2;
        xend = xpick+xwin/2;
        if xstart<data.xvec(1)
            xstart=data.xvec(1);
        end
        if xend>data.xvec(end)
            xend=data.xvec(end);
        end

        % Calculate hyperbola
        x_hyper = linspace(xstart,xend,100);
        t_hyper = sqrt(zpick^2+(abs(x_hyper-xpick)+ant_sep/2).^2)/v + sqrt(zpick^2+(abs(x_hyper-xpick)-ant_sep/2).^2)/v;
    end
end
