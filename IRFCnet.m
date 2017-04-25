function [weiadj lambda_optval PvalNet ObNet] = IRFCnet(workdir, parcels, GLMregions, subjectID, condName, baseName, gamma, bonf)
%fmriNetFit runs the Interregional Functional Connectivity (IRFC) approach
%and outputs a weighted adjacency matrix corresponding to the fitted
%netowrk

cd(workdir);

%fix condName used to be called eventName
eventName = condName;

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
[weiadj lambda_optval] = IsingFitMatlab(ObNet.', GLMregions, gamma);

end
