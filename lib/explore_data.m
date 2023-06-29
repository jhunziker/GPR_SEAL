function explore_data(data)
%
% explore_data(data)
% 
% Interactively explore the data in three dimensions. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% 
% Output: 
%   none
%
% Manual: Use the following keys to explore the data:
% - o: Move horizontal slice down
% - l: Move horizontal slice up
% - i: Move vertical slice along inline direction to larger crossline
%      distance. 
% - k: Move vertical slice along inline direction to smaller crossline
%      distance. 
% - u: Move vertical slice along crossline direction to larger inline
%      distance. 
% - j: Move vertical slice along crossline direction to smaller inline
%      distance. 
% - z: Move vertical slice along crossline direction to larger inline
%      distance using large steps. 
% - h: Move vertical slice along crossline direction to smaller inline
%      distance using large steps. 
% - 1: Jump to horizontal slice at the top of data cube. 
% - 2: Jump to horizontal slice at 1/8 depth of data cube. 
% - 3: Jump to horizontal slice at 2/8 depth of data cube. 
% - 4: Jump to horizontal slice at 3/8 depth of data cube. 
% - 5: Jump to horizontal slice at 4/8 depth of data cube. 
% - 6: Jump to horizontal slice at 5/8 depth of data cube. 
% - 7: Jump to horizontal slice at 6/8 depth of data cube. 
% - 8: Jump to horizontal slice at 7/8 depth of data cube. 
% - 9: Jump to horizontal slice at the bottom of data cube. 
% - a: Narrow color scale.
% - y: Broaden color scale.
% - x: Flip crossline direction in horizontal slice. 
% - s: Switch between 3D cube for orientation and colorbar. 
% - t: Switch between GPS and local coordinates
% - g: Switch plot options for guidelines
% - d: Decrease fontsize
% - c: Increase fontsize
% - p: Save a png and a svg file of the current view. 
% - q: Quit the interactive exploration of the data. 
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

current_slice=round(size(data.cube,1)/2);
dim1 = round(size(data.cube,2)/2);
dim2 = round(size(data.cube,3)/2);

setydir = 1;
docube = 1;
doguide = 3;
doGPS = 1;
running = 1;
fs = 20;
while running == 1

    figure(42);
    % Horizontal cut
    subplot(3,3,[1,2,4,5])
    imagesc(data.xvec,data.yvec,squeeze(data.cube(current_slice,:,:))')
    hold on
    if doguide>1
        plot(data.xvec,ones(size(data.xvec))*data.yvec(dim2),'b','Linewidth',2)
        plot(ones(size(data.yvec))*data.xvec(dim1),data.yvec,'c','Linewidth',2)
    end
    if doguide>2
        plot(data.xvec,ones(size(data.xvec))*data.yvec(1),'r','Linewidth',2)
        plot(data.xvec,ones(size(data.xvec))*data.yvec(end),'r','Linewidth',2)
        plot(ones(size(data.yvec))*data.xvec(3),data.yvec,'r','Linewidth',2)
        plot(ones(size(data.yvec))*data.xvec(end-2),data.yvec,'r','Linewidth',2)
    end
    hold off
    set(gca,'YDir', 'normal')
    colormap('gray')
    if sum(strcmp(fieldnames(data),'cax'))==1
        caxis(data.cax)
    else
        data.cax = caxis;
    end
    axis image
    xlabel('Inline direction [m]')
    ylabel('Crossline direction [m]')
    if doguide>1
        if (doGPS==1 && sum(strcmp(fieldnames(data),'GPS_x_grid'))==1)
            xcoord = num2str(data.GPS_x_grid(dim1,dim2));
            ycoord = num2str(data.GPS_y_grid(dim1,dim2));
        else
            xcoord = num2str(data.xvec(dim1));
            ycoord = num2str(data.yvec(dim2));
        end
        if sum(strcmp(fieldnames(data),'zvec'))==1
            title(['Depth: ',num2str(data.zvec(current_slice),'%5.3f'),' m (',xcoord,' m, ',ycoord,' m)'])
        else
            title(['Time: ',num2str(data.tvec(current_slice),'%5.3f'),' ns (',xcoord,' m, ',ycoord,' m)'])
        end
    else
        if sum(strcmp(fieldnames(data),'zvec'))==1
            title(['Depth: ',num2str(data.zvec(current_slice),'%5.3f'),' m'])
        else
            title(['Time: ',num2str(data.tvec(current_slice),'%5.3f'),' ns'])
        end
    end
    if setydir==1
        set(gca,'YDir','normal');
    else
        set(gca,'YDir','reverse');
    end
    set(gca,'Fontsize',fs);

    % Vertical cut in inline direction
    subplot(3,3,[7,8])
    if sum(strcmp(fieldnames(data),'zvec'))==1
        imagesc(data.xvec,data.zvec,squeeze(data.cube(:,:,dim2)))
        hold on
        if doguide>1
            plot(data.xvec,ones(size(data.xvec))*data.zvec(current_slice),'r','Linewidth',2)
            plot(data.xvec(dim1)*ones(size(data.zvec)),data.zvec,'c','Linewidth',2)
        end
        if doguide>2
            plot(data.xvec,ones(size(data.xvec))*data.zvec(3),'b','Linewidth',2)
            plot(data.xvec,ones(size(data.xvec))*data.zvec(end-2),'b','Linewidth',2)
            plot(ones(size(data.zvec))*data.xvec(3),data.zvec,'b','Linewidth',2)
            plot(ones(size(data.zvec))*data.xvec(end-2),data.zvec,'b','Linewidth',2)
        end
        hold off
    else
        imagesc(data.xvec,data.tvec,squeeze(data.cube(:,:,dim2)))
        hold on
        if doguide>1
            plot(data.xvec,ones(size(data.xvec))*data.tvec(current_slice),'r','Linewidth',2)
            plot(data.xvec(dim1)*ones(size(data.tvec)),data.tvec,'c','Linewidth',2)
        end
        if doguide>2
            plot(data.xvec,ones(size(data.xvec))*data.tvec(3),'b','Linewidth',2)
            plot(data.xvec,ones(size(data.xvec))*data.tvec(end-2),'b','Linewidth',2)
            plot(ones(size(data.tvec))*data.xvec(3),data.tvec,'b','Linewidth',2)
            plot(ones(size(data.tvec))*data.xvec(end-2),data.tvec,'b','Linewidth',2)
        end
        hold off
    end
    colormap('gray')
    caxis(data.cax)
    xlabel('Inline direction [m]')
    if sum(strcmp(fieldnames(data),'zvec'))==1
        ylabel('Depth [m]')
        % axis image
    else
        ylabel('Time [ns]')
    end
    title(['Crossline direction: ',num2str(data.yvec(dim2)),' m'])
    set(gca,'Fontsize',fs);

    % Vertical cut in crossline direction
    subplot(3,3,[3,6])
    if sum(strcmp(fieldnames(data),'zvec'))==1
        imagesc(data.zvec,data.yvec,squeeze(data.cube(:,dim1,:)).')
        hold on
        if doguide>1
            plot(ones(size(data.yvec))*data.zvec(current_slice),data.yvec,'r','Linewidth',2)
            plot(data.zvec,data.yvec(dim2)*ones(size(data.zvec)),'b','Linewidth',2)
        end
        if doguide>2
            plot(ones(size(data.yvec))*data.zvec(3),data.yvec,'c','Linewidth',2)
            plot(ones(size(data.yvec))*data.zvec(end-2),data.yvec,'c','Linewidth',2)
            plot(data.zvec,ones(size(data.zvec))*data.yvec(1),'c','Linewidth',2)
            plot(data.zvec,ones(size(data.zvec))*data.yvec(end),'c','Linewidth',2)
        end
        hold off
    else
        imagesc(data.tvec,data.yvec,squeeze(data.cube(:,dim1,:)).')
        hold on
        if doguide>1
            plot(ones(size(data.yvec))*data.tvec(current_slice),data.yvec,'r','Linewidth',2)
            plot(data.tvec,data.yvec(dim2)*ones(size(data.tvec)),'b','Linewidth',2)
        end
        if doguide>2
            plot(ones(size(data.yvec))*data.tvec(3),data.yvec,'c','Linewidth',2)
            plot(ones(size(data.yvec))*data.tvec(end-2),data.yvec,'c','Linewidth',2)
            plot(data.tvec,ones(size(data.tvec))*data.yvec(1),'c','Linewidth',2)
            plot(data.tvec,ones(size(data.tvec))*data.yvec(end),'c','Linewidth',2)
        end
        hold off
    end
    if setydir==1
        set(gca,'YDir','normal');
    else
        set(gca,'YDir','reverse');
    end
    colormap('gray')
    caxis(data.cax)
    if sum(strcmp(fieldnames(data),'zvec'))==1
        xlabel('Depth [m]')
        % axis image
    else
        xlabel('Time [ns]')
    end
    ylabel('Crossline direction [m]')
    title(['Inline direction: ',num2str(data.xvec(dim1)),' m'])
    set(gca,'Fontsize',fs);

    subplot(3,3,9)
    if docube==1
        % 3D cube for orientation
        horz_slice_x = [data.xvec(1),data.xvec(end),data.xvec(end),data.xvec(1),data.xvec(1)];
        horz_slice_y = [data.yvec(1),data.yvec(1),data.yvec(end),data.yvec(end),data.yvec(1)];
        if sum(strcmp(fieldnames(data),'zvec'))==1
            horz_slice_z =  data.zvec(current_slice)*ones(size(horz_slice_x));
        else
            horz_slice_z =  data.tvec(current_slice)*ones(size(horz_slice_x));
        end
        inl_slice_x = [data.xvec(1),data.xvec(end),data.xvec(end),data.xvec(1),data.xvec(1)];
        inl_slice_y = data.yvec(dim2)*ones(size(inl_slice_x));
        if sum(strcmp(fieldnames(data),'zvec'))==1
            inl_slice_z = [data.zvec(1),data.zvec(1),data.zvec(end),data.zvec(end),data.zvec(1)];
        else
            inl_slice_z = [data.tvec(1),data.tvec(1),data.tvec(end),data.tvec(end),data.tvec(1)];
        end
        crl_slice_x = data.xvec(dim1)*ones(size(inl_slice_x));
        crl_slice_y = [data.yvec(1),data.yvec(end),data.yvec(end),data.yvec(1),data.yvec(1)];
        if sum(strcmp(fieldnames(data),'zvec'))==1
            crl_slice_z = [data.zvec(1),data.zvec(1),data.zvec(end),data.zvec(end),data.zvec(1)];
        else
            crl_slice_z = [data.tvec(1),data.tvec(1),data.tvec(end),data.tvec(end),data.tvec(1)];
        end
        plot3(horz_slice_x,horz_slice_y,horz_slice_z,'r','Linewidth',2)
        hold on
        plot3(inl_slice_x,inl_slice_y,inl_slice_z,'b','Linewidth',2)
        plot3(crl_slice_x,crl_slice_y,crl_slice_z,'c','Linewidth',2)
        hold off
        xlim([data.xvec(1),data.xvec(end)])
        ylim([data.yvec(1),data.yvec(end)])
        if sum(strcmp(fieldnames(data),'zvec'))==1
            zlim([data.zvec(1),data.zvec(end)])
        else
            zlim([data.tvec(1),data.tvec(end)])
        end
        xlabel('Inline direction [m]')
        ylabel('Crossline direction [m]')
        if sum(strcmp(fieldnames(data),'zvec'))==1
            zlabel('Depth [m]')
        else
            zlabel('Time [ns]')
        end
        if setydir==1
            set(gca,'YDir','normal');
        else
            set(gca,'YDir','reverse');
        end
        set(gca,'ZDir','reverse');
        grid on
    else
        % Colorbar
        cax_vec = linspace(data.cax(1),data.cax(2),512);
        imagesc(cax_vec,1,cax_vec)
        colormap('gray')
        set(gca,'YTick',[]);
        xlabel('Colorbar')
    end
    set(gca,'Fontsize',fs);

    waitforbuttonpress
    value = double(get(gcf,'CurrentCharacter'));
    switch value
        % Move horizontal slice down
        case 111 % o
            if current_slice < size(data.cube,1)
                current_slice=current_slice + 1;
            end

        % Move horizontal slice up
        case 108 % l
            if current_slice > 1
                current_slice=current_slice - 1;
            end

        % Move 1st vertical slice
        case 105 % i
            if dim2 < size(data.cube,3)
                dim2=dim2 + 1;
            end

        % Move 1st vertical slice
        case 107 % k
            if dim2 > 1
                dim2=dim2 - 1;
            end

        % Move 2nd vertical slice
        case 117 % u
            if dim1 < size(data.cube,2)
                dim1=dim1 + 1;
            end

        % Move 2nd vertical slice
        case 106 % j
            if dim1 > 1
                dim1=dim1 - 1;
            end

        % Move 2nd vertical slice in big steps
        case 122 % z
            if dim1 < size(data.cube,2)-9
                dim1=dim1 + 10;
            end

        % Move 2nd vertical slice in big steps
        case 104 % h
            if dim1 > 11
                dim1=dim1 - 10;
            end

        % Jump to top slice
        case 49 % 1
            current_slice=1;

        % Jump to 1/8 of slices
        case 50 % 2
            current_slice=round(1/8*size(data.cube,1));

        % Jump to 2/8 of slices
        case 51 % 3
            current_slice=round(2/8*size(data.cube,1));

        % Jump to 3/8 of slices
        case 52 % 4
            current_slice=round(3/8*size(data.cube,1));

        % Jump to 4/8 of slices
        case 53 % 5
            current_slice=round(4/8*size(data.cube,1));

        % Jump to 5/8 of slices
        case 54 % 6
            current_slice=round(5/8*size(data.cube,1));

        % Jump to 6/8 of slices
        case 55 % 7
            current_slice=round(6/8*size(data.cube,1));

        % Jump to 7/8 of slices
        case 56 % 8
            current_slice=round(7/8*size(data.cube,1));

        % Jump to bottom slice
        case 57 % 9
            current_slice=size(data.cube,1);

        % Reduce colorbar
        case 97 % a
            data.cax = data.cax/2;

        % Extend colorbar
        case 121 % y
            data.cax = data.cax*2.0;

        % Change orientation of crossline direction
        case 120 % x
            setydir = ~setydir;

        % Switch between 3D cube for orientation and colorbar
        case 115 % s
            docube = ~docube;

        % Switch between GPS and local coordinates
        case 116 % t
            doGPS = ~doGPS;

        % Switch guideline modes
        case 103 % g
            doguide = doguide + 1;
            if doguide>3
                doguide=1;
            end

        % Decrease fontsize
        case 100 % d
            fs = fs-2;
            if fs<4
                fs=4;
            end

        % Increase fontsize
        case 99 % c
            fs = fs+2;
            if fs>40
                fs=40;
            end

        case 112 % p
            print('-dpng',['cube_slice',num2str(current_slice),'.png'])
            print('-dsvg',['cube_slice',num2str(current_slice),'.svg'])

        % Quit 3D Browser
        case 113 % q
            running = 0;
    end
end
