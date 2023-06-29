function data = align_profiles(data,filenameout)
%
% data = align_profiles(data,filenameout)
% 
% Interactively shift individual profiles to correct for faulty alignment. 
% 
% Input: 
% - data: The data structure that contains the GPR data as well as the
%   corresponding coordinate vectors. 
% - filenameout: Name of the file in which the shifts for each profile are
%   stored. This file is loaded, when the function is called. This allows 
%   to stop working and continue at a later time. Also, when the function 
%   is called, the profiles that were shifted last time, will be shifted 
%   again. So, no manual adjustments need to be redone. The file is
%   automatically saved when one quits the tool by pressing q. 
% 
% Output: 
% - data: The updated data structure that was loaded. 
%
% Manual: Use the following keys to manipulate the data:
% - o: Move horizontal slice down. 
% - l: Move horizontal slice up. 
% - i: Move profile indicator. 
% - k: Move profile indicator. 
% - u: Move indicated profile to the right. 
% - j: Move indicated profile to the left. 
% - 1: Jump to horizontal slice at the top of data cube. 
% - 2: Jump to horizontal slice at 1/8 depth of data cube. 
% - 3: Jump to horizontal slice at 2/8 depth of data cube. 
% - 4: Jump to horizontal slice at 3/8 depth of data cube. 
% - 5: Jump to horizontal slice at 4/8 depth of data cube. 
% - 6: Jump to horizontal slice at 5/8 depth of data cube. 
% - 7: Jump to horizontal slice at 6/8 depth of data cube. 
% - 8: Jump to horizontal slice at 7/8 depth of data cube. 
% - 9: Jump to horizontal slice at the bottom of data cube. 
% - s: Save the shifts to disk. 
% - q: Save the shifts to disk and quit the interactive tool. 
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

if exist(filenameout,'file') % A alignment file exists
    load(filenameout,'align_vec'); % Load alignment file

    % Check if amount of profiles in alignment vector matches actual amount
    % of profiles in data cube. 
    if length(align_vec)~=size(data.cube,3)
        error('Loaded alignment file does not correspond to data loaded.')
    end

    % Apply previously determined alignment
    for ip=1:length(align_vec)
        if align_vec(ip) > 0
            data.cube(:,:,ip) = [zeros(size(data.cube,1),align_vec(ip)),data.cube(:,1:end-align_vec(ip),ip)];
        elseif align_vec(ip) < 0
            data.cube(:,:,ip) = [data.cube(:,1+abs(align_vec(ip)):end,ip),zeros(size(data.cube,1),abs(align_vec(ip)))];
        end
    end
else % If no alignment file exists, initialize alignment vector
    align_vec = zeros(1,size(data.cube,3));
end

current_slice=round(size(data.cube,1)/2);
running = 1;
profisel = 1;
while running == 1

    h = figure(42);
    imagesc(data.xvec,data.yvec,squeeze(data.cube(current_slice,:,:))')
    hold on
    plot([data.xvec(1),data.xvec(end)],data.yvec(profisel)*ones(1,2),'--r')
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
    if sum(strcmp(fieldnames(data),'zvec'))==1
        title(['Depth: ',num2str(data.zvec(current_slice),'%5.3f'),' m'])
    else
        title(['Time: ',num2str(data.tvec(current_slice),'%5.3f'),' ns'])
    end

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

        % Move profile indicator
        case 105 % i
            if profisel < size(data.cube,3)
                profisel=profisel+ 1;
            end

        % Move profile indicator
        case 107 % k
            if profisel > 1
                profisel=profisel - 1;
            end

        % Move indicated profile to the right
        case 117 % u
            align_vec(profisel) = align_vec(profisel) + 1;
            data.cube(:,:,profisel) = [zeros(size(data.cube,1),1),data.cube(:,1:end-1,profisel)];

        % Move indicated profile to the left
        case 106 % j
            align_vec(profisel) = align_vec(profisel) - 1;
            data.cube(:,:,profisel) = [data.cube(:,2:end,profisel),zeros(size(data.cube,1),1)];

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

        % Save amount of alignment
        case 115 % s
            save(filenameout,'align_vec');

        % Quit interactive tool. 
        case 113 % q
            running = 0;
            save(filenameout,'align_vec');
            close(h);
    end
end
