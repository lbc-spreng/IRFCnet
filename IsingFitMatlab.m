function [weiadj lambda_optval] = IsingFitMatlab(x, GLMregions, gamma, AND)
%Do the IsingFit function in Matlab
%this function and the EBIC function heavily lift code from the IsingFit
%package in R, https://cran.r-project.org/web/packages/IsingFit/IsingFit.pdf


%if only x is given, set AND = TRUE
if nargin < 4
    AND = true; 
end

%save number of nodes 
odim = size(x,2); 

%do a loop over each node to ensure variance in each node, and only include
%
NodesToAnalyze = zeros(1,odim);
for a = 1:odim
    res = and(all(x(:,a) == x(1,a)) == 0, sum(a == GLMregions));
    NodesToAnalyze(a) =  res;
end

%indices of nodes with variance are indVar
indVar = find(NodesToAnalyze == 1);
if (isempty(indVar)) 
    error('No variance in dataset')
end

%only look at nodes with variance
x = x(:, indVar);

%number of nodes to be fit
newdim = size(x,2);

%get each node fit and size of each fit
fits = cell(1, newdim);
sfit = zeros(1, newdim);
for i = 1:newdim;
    design = x;
    design(:,i) = [];
    fit = glmnet(design, x(:,i), 'binomial');
    sfit(i) = size(fit.lambda, 1);
    fits{i} = fit;
end

%using the above fit, output weighted adjacency fit, thresholds for
%each node, and tuning parameters for each node via EBIC
[weiadjO lambda_optvalO] = EBIC(fits, sfit, x, gamma, AND);

%get full version of all the output variables
weiadj = zeros(odim); 
weiadj(NodesToAnalyze==1, NodesToAnalyze==1) = weiadjO;
lambda_optval = zeros(1, odim);
lambda_optval(NodesToAnalyze==1) = lambda_optvalO;
%thresholds = zeros(1, odim);
%thresholds(NodesToAnalyze) = thresholdsO;


end

