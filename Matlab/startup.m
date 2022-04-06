function [] = startup()
%STARTUP Summary of this function goes here
%   Detailed explanation goes here

disp('Startup');

%% Initialization

% Build RealResize if necessary
arithlib_dir = 'dependencies/arithlib/matlab';
if ~isfile([arithlib_dir, '/RealARITH/RealRESIZE.mexa64'])
    base_dir = pwd;
    disp('Building RealRESIZE');
    cd([arithlib_dir, '/RealARITH']);
    build;
    cd(base_dir);
end

%% Setup Matlab PATH
addpath(genpath(arithlib_dir));

end
