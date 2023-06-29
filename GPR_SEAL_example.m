% This script is an example for a simple processing flow using GPR_SEAL. 
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

clear all; close all; clc;

% Add folder that contains the GPR_SEAL functions to the Matlab search
% path, such that Matlab finds the functions called. 
addpath('./lib');

% Folder where the data are located. 
foldername = './data';

% Create a matrix that contains the names of all the profile files
filecounter=1;
for ifile=1:40
    if ifile<10
        filenamemat(filecounter,:) = ['beach_000',num2str(ifile),'_0.iprh'];
    else
        filenamemat(filecounter,:) = ['beach_00',num2str(ifile),'_0.iprh'];
    end
    filecounter=filecounter+1;
end

% Import the data
data = load_impulseradar(foldername,filenamemat,0.2);

% Correct time zero, such that the direct wave arrives at the correct time
data = time_zero_correction(data,-8);

% Subtract a mean trace in a moving window to suppress the direct wave. 
data = subtract_mean_trace(data,2,0,8.5);

% Increase the amplitude of late arrivals
data = gain(data,8.5,0.25,0.02,0,12);

% Adjust colorbar interactively 
data = set_caxis(data,0.5,12);

% Estimate velocity by interactive parabola fitting
data = velocity_analysis(data,0.5,4,0.23,12);

% Increase crossline sampling by interpolation
data = crossline_interpolation(data,2);

% Explore the data in all three dimensions
explore_data(data)