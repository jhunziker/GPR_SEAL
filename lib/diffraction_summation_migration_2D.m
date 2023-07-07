function diffraction_summation_migration_2D(data,yfrac,xwin,fs)
%
% diffraction_summation_migration_2D(data,yfrac,xwin,fs)
% 
% Performs a diffraction summation migration on a profile. This is the
% simplest possible form of migration. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - yfrac: Fractional position of measurement line in crossline direction, 
%   where 0 is the first line, 0.5 the middle line and 1 the last line. 
% - xwin: Summation width in meters
% - fs: Fontsize to be used in plots. 
% 
% Output: 
%   none
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

if sum(strcmp(fieldnames(data),'v'))==0
    error('No velocity defined. Run first velocity_analysis to set the velocity.')
end

yel = round(yfrac*size(data.cube,3));
if yel<=0
    yel=1;
end

if yel>size(data.cube,3)
    yel = size(data.cube,3);
end

if xwin<=0.0
    error('The width of the hyperbola has to be a positive value.')
end

% How many elements consist half of the spatial window?
half_xwin_el = round(xwin/2/(data.xvec(2)-data.xvec(1)));
% Element number in local coordinate system
x_hyper_el = linspace(-half_xwin_el,half_xwin_el,2*half_xwin_el+1);
% Spatial distance in local coordinate system
x_hyper = linspace(-half_xwin_el,half_xwin_el,2*half_xwin_el+1)*(data.xvec(2)-data.xvec(1));

fprintf('2D Diffraction Summation Migration       ')
mig = zeros(length(data.zvec),length(data.xvec));
for iz=1:length(data.zvec)
    % Calculate hyperbola
    t_hyper = sqrt(data.zvec(iz)^2+(x_hyper+data.ant_sep/2).^2)/data.v + sqrt(data.zvec(iz)^2+(x_hyper-data.ant_sep/2).^2)/data.v;
%     r_vec = data.zvec(iz)^2+x_hyper.^2+0.01;
%     costheta = data.zvec(iz)./r_vec;
    for ix=1:length(data.xvec)
        % Element number in global coordinate system
        x_hyper_el_global = ix+x_hyper_el;
        for ix_hyper=1:length(x_hyper_el)
            if (x_hyper_el_global(ix_hyper)>0 && x_hyper_el_global(ix_hyper)<=length(data.xvec))
                % Find the element in the time vector that is closest to
                % the arrival time given by the theoretical hyperbola. 
                [~,tel] = min(abs(data.tvec-t_hyper(ix_hyper)));
                if (tel>1 && tel<length(data.tvec))
                    if data.tvec(tel)>t_hyper(ix_hyper)
                        % Linear interpolation between the two closest
                        % elements in time
                        dt1 = t_hyper(ix_hyper)-data.tvec(tel-1);
                        dt2 = data.tvec(tel)-t_hyper(ix_hyper);
                        w1 = dt1/(dt1+dt2);
                        w2 = dt2/(dt1+dt2);
                        % Summation over hyperbola
%                         mig(iz,ix) = mig(iz,ix) + costheta(ix_hyper)/sqrt(data.v*r_vec(ix_hyper))*(w2*data.cube(tel-1,x_hyper_el_global(ix_hyper),yel)+w1*data.cube(tel,x_hyper_el_global(ix_hyper),yel));
                        mig(iz,ix) = mig(iz,ix) + (w2*data.cube(tel-1,x_hyper_el_global(ix_hyper),yel)+w1*data.cube(tel,x_hyper_el_global(ix_hyper),yel));
                    else
                        % Linear interpolation between the two closest
                        % elements in time
                        dt1 = t_hyper(ix_hyper)-data.tvec(tel);
                        dt2 = data.tvec(tel+1)-t_hyper(ix_hyper);
                        w1 = dt1/(dt1+dt2);
                        w2 = dt2/(dt1+dt2);
                        % Summation over hyperbola
%                         mig(iz,ix) = mig(iz,ix) + costheta(ix_hyper)/sqrt(data.v*r_vec(ix_hyper))*(w2*data.cube(tel,x_hyper_el_global(ix_hyper),yel)+w1*data.cube(tel+1,x_hyper_el_global(ix_hyper),yel));
                        mig(iz,ix) = mig(iz,ix) + (w2*data.cube(tel,x_hyper_el_global(ix_hyper),yel)+w1*data.cube(tel+1,x_hyper_el_global(ix_hyper),yel));
                    end
                    
                end
            end
        end
    end
    fprintf('\b\b\b\b\b\b%6.2f',iz/length(data.zvec)*100)
end
fprintf('\n')

figure(42);
subplot(2,1,1)
imagesc(data.xvec,data.zvec,squeeze(data.cube(:,:,yel)))
if sum(strcmp(fieldnames(data),'cax'))==1
    caxis(data.cax)
end
colormap('gray')
colorbar
xlabel('Distance [m]')
ylabel('Depth [m]')
title('Unmigrated profile')
set(gca,'Fontsize',fs)

subplot(2,1,2)
imagesc(data.xvec,data.zvec,mig)
if sum(strcmp(fieldnames(data),'cax'))==1
    temp = squeeze(data.cube(:,:,yel));
    caxis(data.cax*mean(mig(:))/mean(temp(:)))
end
colormap('gray')
colorbar
xlabel('Distance [m]')
ylabel('Depth [m]')
title('Migrated profile')
set(gca,'Fontsize',fs)
