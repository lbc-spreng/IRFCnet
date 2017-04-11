function [weiadj thresholds lambda_optval] = IRFCnet(workdir, parcels, subjectID, eventName, baseName, gamma, bonf)
%fmriNetFit runs the Interregional Functional Connectivity (IRFC) approach
%and outputs a weighted adjacency matrix corresponding to the fitted
%netowrk

cd(workdir);

%get pvalue network
PvalNet = Pnet(parcels, subjectID, eventName, baseName);
NetSize = size(PvalNet);

%if gamma bonf not given, set defaults
if nargin < 5
    error('not enough arguments')
elseif nargin < 6
    gamma = 0.25;
    bonf = NetSize(1);
%if only bonf not given, set defaults
elseif nargin < 7
    bonf = NetSize(1);
end

%threshold pvalue network to get region states
ObNet = PvalNet < 0.05/bonf;
%obtain fitted adjacency matrix
[weiadj thresholds lambda_optval] = IsingFitMatlab(ObNet, gamma);

end
