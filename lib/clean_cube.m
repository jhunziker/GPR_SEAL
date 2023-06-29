function data = clean_cube(data,filenameout)
%
% data = clean_cube(data,filenameout)
% 
% Interactively remove and interpolate faulty traces. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - filenameout: Name of the file in which the number of the deleted traces 
%   are stored. This file is loaded, when the function is called. This 
%   allows to stop working and continue at a later time. Also, when the 
%   function is called, the traces that were interpolated last time, will 
%   be interpolated again. So, no picks need to be redone. The file is
%   automatically saved when one quits the tool by pressing q. 
% 
% Output: 
% - data: The updated data structure that was loaded. 
%
% Manual: Use the following keys to manipulate the data:
% - o: Move trace selector a small step to the left. 
% - l: Move trace selector a small step to the right. 
% - i: Move trace selector a big step to the left. 
% - k: Move trace selector a big step to the right. 
% - u: Move one profile forward. 
% - j: Move one profile backward. 
% - e: Eliminate trace marked by trace selector and replace it with zeros. 
% - r: Reconstruct eliminated traces by linear interpolation. 
% - s: Save the eliminated traces to disk. 
% - q: Save the elimianted traces to disk and quit the interactive tool. 
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

if exist(filenameout,'file') % A marker file exists
    load(filenameout,'marker'); % Load marker file

    % Replace all marked traces
    for ip=1:size(data.cube,3)
        marker(ip).new = marker(ip).all;
        while isempty(marker(ip).new)==0
            counter = 1;
            if length(marker(ip).new)>1
                % Check if there are adjacent traces.
                while marker(ip).new(counter+1)-marker(ip).new(counter)==1
                    counter = counter + 1;
                    if counter == length(marker(ip).new)
                        break
                    end
                end
            end
            if (marker(ip).new(1)-1>=1 && marker(ip).new(counter)+1<=size(data.cube,2))
                xvec_in = [marker(ip).new(1)-1,marker(ip).new(counter)+1];
                zvec_in = linspace(1,size(data.cube,1),size(data.cube,1));
                [xmesh_in,zmesh_in]=meshgrid(xvec_in,zvec_in);
                data_temp = squeeze([data.cube(:,marker(ip).new(1)-1,ip),data.cube(:,marker(ip).new(counter)+1,ip)]);
                xvec_out = (marker(ip).new(1)-1:marker(ip).new(counter)+1);
                [xmesh_out,zmesh_out]=meshgrid(xvec_out,zvec_in);
                data.cube(:,marker(ip).new(1)-1:marker(ip).new(counter)+1,ip) = interp2(xmesh_in,zmesh_in,data_temp,xmesh_out,zmesh_out);
            end
            marker(ip).new(1:counter) = [];
        end
    end
else % No marker file exists. The marker structure needs to be initialized.
    for ip=1:size(data.cube,3)
        marker(ip).all = [];
        marker(ip).new = [];
    end
end

profisel = 1;
tracesel = round(size(data.cube,2)/2);
running = 1;
while running == 1

    h=figure(42);
    subplot(1,5,[1:4])
    if sum(strcmp(fieldnames(data),'zvec'))==1
        imagesc(data.xvec,data.zvec,squeeze(data.cube(:,:,profisel)))
        hold on
        plot(data.xvec(tracesel)*ones(1,2),[data.zvec(1),data.zvec(end)],'r')
        hold off
    else
        imagesc(data.xvec,data.tvec,squeeze(data.cube(:,:,profisel)))
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
    title(['Profile fraction ',num2str(profisel/size(data.cube,3),'%.2f')])

    subplot(1,5,5)
    if sum(strcmp(fieldnames(data),'zvec'))==1
        plot(data.cube(:,tracesel,profisel),data.zvec,'k','Linewidth',2)
        ylim([data.zvec(1),data.zvec(end)])
        ylabel('Depth [m]')
    else
        plot(data.cube(:,tracesel,profisel),data.tvec,'k','Linewidth',2)
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

        % Move profile selector a step ahead
        case 117 % u
            if profisel < size(data.cube,3)
                profisel=profisel + 1;
            end

        % Move profile selector a step back
        case 106 % j
            if profisel > 1
                profisel = profisel - 1;
            end

        % Eliminate a trace
        case 101 % e
            % Check if marker is empty
            if isempty(marker(profisel).all)==1
                marker(profisel).all(end+1) = tracesel;
                marker(profisel).new(end+1) = tracesel;
            % If marker is not empty, check if the current trace has
            % already been added
            elseif min(abs(tracesel-marker(profisel).all))~=0
                marker(profisel).all(end+1) = tracesel;
                marker(profisel).new(end+1) = tracesel;
            end
            marker(profisel).all = sort(marker(profisel).all);
            marker(profisel).new = sort(marker(profisel).new);
            data.cube(:,tracesel,profisel) = 0.0;

        % Replace marked traces with interpolated data
        case 114 % r
            for ip=1:size(data.cube,3)
                while isempty(marker(ip).new)==0
                    counter = 1;
                    if length(marker(ip).new)>1
                        % Check if there are adjacent traces.
                        while marker(ip).new(counter+1)-marker(ip).new(counter)==1
                            counter = counter + 1;
                            if counter == length(marker(ip).new)
                                break
                            end
                        end
                    end
                    if (marker(ip).new(1)-1>=1 && marker(ip).new(counter)+1<=size(data.cube,2))
                        xvec_in = [marker(ip).new(1)-1,marker(ip).new(counter)+1];
                        zvec_in = linspace(1,size(data.cube,1),size(data.cube,1));
                        [xmesh_in,zmesh_in]=meshgrid(xvec_in,zvec_in);
                        data_temp = squeeze([data.cube(:,marker(ip).new(1)-1,ip),data.cube(:,marker(ip).new(counter)+1,ip)]);
                        xvec_out = (marker(ip).new(1)-1:marker(ip).new(counter)+1);
                        [xmesh_out,zmesh_out]=meshgrid(xvec_out,zvec_in);
                        data.cube(:,marker(ip).new(1)-1:marker(ip).new(counter)+1,ip) = interp2(xmesh_in,zmesh_in,data_temp,xmesh_out,zmesh_out);
                    end
                    marker(ip).new(1:counter) = [];
                end
            end

        % Save marker
        case 115 % s
            save(filenameout,'marker');

        % Quit tool
        case 113 % q
            running = 0;
            save(filenameout,'marker');
    end
end
close(h);
