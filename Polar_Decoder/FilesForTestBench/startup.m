function [] = startup()
%STARTUP Summary of this function goes here
%   Detailed explanation goes here

disp('Startup');

%% Initialization

% Build RealResize if necessary
arithlib_dir = 'C:\Users\arlin\Desktop\polar_codes1\nr-polar\FilesForTestBench\ArithLib-master\matlab';
if ~isfile([arithlib_dir, '/RealARITH/RealRESIZE.m'])
    base_dir = pwd;
    disp('Building RealRESIZE');
    cd([arithlib_dir, '/RealARITH']);
    build;
    cd(base_dir);
end

%% Setup Matlab PATH
addpath(genpath(arithlib_dir));

end
