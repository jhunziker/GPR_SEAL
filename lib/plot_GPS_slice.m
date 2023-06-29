function plot_GPS_slice(data,vertfrac,doscatter,fs)
%
% plot_GPS_slice(data,vertfrac,doscatter,fs)
% 
% Plot a horizontal slice of GPR data in the coordinate grid measured with
% GPS. This function only works if add_GPS_grid has been executed before. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - vertfrac: Fractional position of horizontal slice to be plotted, where
%   0 is the top slice, 0.5 the middle slice and 1 the bottom slice. 
% - doscatter: Show a scatter plot of each measurement position (1) or an
%   image plot of the slice (0). 
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

if sum(strcmp(fieldnames(data),'GPS_x_grid'))~=1
    error('No GPS coordinates. Run add_GPS_grid first.')
end

vertel = round(vertfrac*size(data.cube,1));
if vertel<=0
    vertel=1;
end

if vertel>size(data.cube,1)
    vertel = size(data.cube,1);
end

datatemp = squeeze(data.cube(vertel,:,:));

if doscatter==1
    % Scatter plot

    figure;
    scatter(data.GPS_x_grid(:),data.GPS_y_grid(:),80,datatemp(:),'filled')
    axis image
    colormap('gray')
    caxis(data.cax)
    xlabel('Easting [m]','Fontsize',fs)
    ylabel('Northing [m]','Fontsize',fs)
    if sum(strcmp(fieldnames(data),'zvec'))==1
        title(['Depth: ',num2str(data.zvec(vertel),'%5.3f'),' m'],'Fontsize',fs)
    else
        title(['Time: ',num2str(data.tvec(vertel),'%5.3f'),' ns'],'Fontsize',fs)
    end
    set(gca,'Fontsize',fs)

else
    % Image plot

    % Grid the data on a regular grid
    xtempvec = linspace(min(data.GPS_x_grid(:)),max(data.GPS_x_grid(:)),250);
    ytempvec = linspace(min(data.GPS_y_grid(:)),max(data.GPS_y_grid(:)),250);
    [xtempgrid,ytempgrid] = ndgrid(xtempvec,ytempvec);
    data_grid = griddata(data.GPS_x_grid(:),data.GPS_y_grid(:),datatemp(:),xtempgrid,ytempgrid);

    % After gridding, points outside the area where data were measured are NaN. 
    % Replace them with the value of the upper limit of the colorbar, such
    % that they appear white in the plot and not black. 
    data_grid(isnan(data_grid)) = data.cax(2);

    % Plot the data as an image plot
    figure;
    imagesc(xtempvec,fliplr(ytempvec),flipud(data_grid.'))
    axis image
    colormap('gray');
    caxis(data.cax)
    xlabel('Easting [m]','Fontsize',fs)
    ylabel('Northing [m]','Fontsize',fs)
    if sum(strcmp(fieldnames(data),'zvec'))==1
        title(['Depth: ',num2str(data.zvec(vertel),'%5.3f'),' m'],'Fontsize',fs)
    else
        title(['Time: ',num2str(data.tvec(vertel),'%5.3f'),' ns'],'Fontsize',fs)
    end
    set(gca,'YDir','normal','Fontsize',fs)
end
