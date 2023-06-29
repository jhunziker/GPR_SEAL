function data = clean_profile(data,yfrac)
%
% data = clean_profile(data,yfrac)
% 
% Interactively remove and interpolate faulty traces. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - yfrac: Fractional position of measurement line in crossline direction, 
%   where 0 is the first line, 0.5 the middle line and 1 the last line.
% 
% Output: 
% - data: The updated data structure that was loaded. 
%
% Manual: Use the following keys to manipulate the data:
% - o: Move trace selector a small step to the left. 
% - l: Move trace selector a small step to the right. 
% - i: Move trace selector a big step to the left. 
% - k: Move trace selector a big step to the right. 
% - e: Eliminate trace marked by trace selector and replace it with zeros. 
% - r: Reconstruct eliminated traces by linear interpolation. 
% - q: Quit the interactive tool. 
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

tracesel = round(size(data.cube,2)/2);
marker = []; % Empty vector to store marked traces
running = 1;
while running == 1

    figure(42);
    subplot(1,5,[1:4])
    if sum(strcmp(fieldnames(data),'zvec'))==1
        imagesc(data.xvec,data.zvec,squeeze(data.cube(:,:,yel)))
        hold on
        plot(data.xvec(tracesel)*ones(1,2),[data.zvec(1),data.zvec(end)],'r')
        hold off
    else
        imagesc(data.xvec,data.tvec,squeeze(data.cube(:,:,yel)))
        hold on
        plot(data.xvec(tracesel)*ones(1,2),[data.tvec(1),data.tvec(end)],'r')
        hold off
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

    subplot(1,5,5)
    if sum(strcmp(fieldnames(data),'zvec'))==1
        plot(data.cube(:,tracesel,yel),data.zvec,'k','Linewidth',2)
        ylim([data.zvec(1),data.zvec(end)])
        ylabel('Depth [m]')
    else
        plot(data.cube(:,tracesel,yel),data.tvec,'k','Linewidth',2)
        ylim([data.tvec(1),data.tvec(end)])
        ylabel('Time [ns]')
    end
    xlabel('Amplitude [-]')
    title(['Trace at ',num2str(data.xvec(tracesel)),' m'])
    set(gca,'YDir','reverse')

    waitforbuttonpress
    value = double(get(gcf,'CurrentCharacter'));
    switch value
        % Move trace selector a small step to the left
        case 111 % o
            if tracesel > 1
                tracesel=tracesel - 1;
            end

        % Move trace selector a small step to the right
        case 108 % l
            if tracesel < size(data.cube,2)
                tracesel=tracesel + 1;
            end

        % Move trace selector a big step to the left
        case 105 % i
            if tracesel > 10
                tracesel=tracesel - 10;
            end

        % Move trace selector a big step to the right
        case 107 % k
            if tracesel < size(data.cube,2)-9
                tracesel=tracesel + 10;
            end

        % Eliminate a trace
        case 101 % e
            % Check if marker is empty
            if isempty(marker)==1
                marker(end+1) = tracesel;
            % If marker is not empty, check if the current trace has
            % already been added
            elseif min(abs(tracesel-marker))~=0
                marker(end+1) = tracesel;
            end
            marker = sort(marker);
            data.cube(:,tracesel,yel) = 0.0;

        % Replace marked traces with interpolated data
        case 114 % r
            while isempty(marker)==0
                counter = 1;
                if length(marker)>1
                    % Check if there are adjacent traces. 
                    while marker(counter+1)-marker(counter)==1
                        counter = counter + 1;
                        if counter == length(marker)
                            break
                        end
                    end
                end
                if (marker(1)-1>=1 && marker(counter)+1<=size(data.cube,2))
                    xvec_in = [marker(1)-1,marker(counter)+1];
                    zvec_in = linspace(1,size(data.cube,1),size(data.cube,1));
                    [xmesh_in,zmesh_in]=meshgrid(xvec_in,zvec_in);
                    data_temp = squeeze([data.cube(:,marker(1)-1,yel),data.cube(:,marker(counter)+1,yel)]);
                    xvec_out = (marker(1)-1:marker(counter)+1);
                    [xmesh_out,zmesh_out]=meshgrid(xvec_out,zvec_in);
                    data.cube(:,marker(1)-1:marker(counter)+1,yel) = interp2(xmesh_in,zmesh_in,data_temp,xmesh_out,zmesh_out);
                end
                marker(1:counter) = [];
            end

        % Quit tool
        case 113 % q
            running = 0;
    end
end
