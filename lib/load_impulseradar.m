function data = load_impulseradar(foldername,filenamemat,dy)
%
% data = load_impulseradar(foldername,filenamemat,dy)
%
% Load data files ending on iprh (header file) and iprb (binary data file)
% acquired with the GPR from impulseradar.
% 
% Input: 
% - foldername: Complete path to the folder that contains the data. 
% - filenamemat: Matrix that contains in each line the name of one file to
%   be loaded. Shorter filenames need to be followed by spaces to fill the
%   line. 
% - dy: Crossline distance between lines in meters. 
% 
% Output: 
% - data: Data structure that contains the imported GPR data as well as the
%   corresponding coordinate vectors. 
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

% Extract relevant information from header file
filename = deblank(filenamemat(1,:));
fidhead = fopen([foldername,'/',filename(1:end-1),'h']);
fseek(fidhead,0,'eof');
headersize = ftell(fidhead);
fseek(fidhead,0,'bof');
while(ftell(fidhead)<headersize)
    templine = fgetl(fidhead);
    if length(templine)>10
        if templine(1:10)=='TIMEWINDOW'
            timewindow = str2double(templine(12:end));
        end
    end
    if length(templine)>7
        if templine(1:7)=='SAMPLES'
            nsamples = str2double(templine(9:end));
        end
    end
    if length(templine)>22
        if templine(1:22)=='USER DISTANCE INTERVAL'
            dx = str2double(templine(24:end));
        end
    end
end
fclose(fidhead);

% Find which profile is the longest and how long it is
for ifile=1:size(filenamemat,1)
    filename = deblank(filenamemat(ifile,:));
    fidhead = fopen([foldername,'/',filename(1:end-1),'h']);
    while(ftell(fidhead)<headersize)
        templine = fgetl(fidhead);
        if length(templine)>10
            if templine(1:10)=='LAST TRACE'
                if ifile==1
                    ntraces = str2double(templine(12:end));
                else
                    temp_ntraces = str2double(templine(12:end));
                    if temp_ntraces>ntraces
                        ntraces=temp_ntraces;
                    end
                end
            end
        end
    end
    fclose(fidhead);
end

data.yvec = linspace(0,size(filenamemat,1)-1,size(filenamemat,1))*dy;
data.cube = zeros(nsamples,ntraces,size(filenamemat,1));

for ifile=1:size(filenamemat,1)
    filename = deblank(filenamemat(ifile,:));
    fidhead = fopen([foldername,'/',filename(1:end-1),'h']);
    while(ftell(fidhead)<headersize)
        templine = fgetl(fidhead);
        if length(templine)>10
            if templine(1:10)=='LAST TRACE'
                thisfile_ntraces = str2double(templine(12:end));
            end
        end
    end
    fclose(fidhead);

    fid = fopen([foldername,'/',filename(1:end-1),'b']);
    temp = fread(fid,nsamples*thisfile_ntraces,'int32',0,'ieee-le');
    fclose(fid);
    data.cube(:,1:thisfile_ntraces,ifile) = reshape(temp,[nsamples,thisfile_ntraces]);

    if ifile==1
        data.tvec = linspace(0,timewindow,nsamples);
    end

    if thisfile_ntraces==ntraces
        data.xvec = linspace(0,ntraces-1,ntraces)*dx;
    end
end
