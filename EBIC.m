function [weiadj lambda_optval] = EBIC(fits, sfit, x, gamma, AND)
%Do EBIC on the given fit information and data

%maximum number of selected models for any node
maxlam = max(sfit);

%%calculating penalty on the likelihood
%with the form J*log(n) + 2*gamma*J*log(p)
%where n is number of observations p is number of nodes -1
%and J is the size of each selected model

J = zeros(maxlam, size(x, 2));

for i = 1:size(fits, 2)
    numparam = (fits{i}.beta) ~= 0;
    J(1:size(numparam,2),i) = sum(numparam);
end

penalty = J*log(size(x, 1)) + 2*gamma*J*log(size(x,2)-1);


%%calculating the likelihood
%first calculate (log) probabilities
%then sum over observations
[N nvar] = size(x);
P_M = zeros(N, maxlam, nvar);
logl_Msum = zeros(maxlam, nvar);
for i = 1:nvar
    curBeta = fits{i}.beta;
    curInt = fits{i}.a0;
    y = zeros(N, size(curBeta, 2));
    xi = x;
    xi(:,i) = [];
    NB = size(curBeta, 1); %number of rows in beta
    %calculate regression fitted values without slope
    for bb = 1:NB
        y = y + xi(:,bb)*curBeta(bb,:);
    end
    %add slope
    y = y + repmat(curInt, N, 1);
    %add NaN columns so y will have same number of columns as P_M
    n_NaN = maxlam - size(curBeta, 2);
    if n_NaN > 0
        y = [y NaN(N, n_NaN)];
    end
    %calculate probabilities given y
    P_M(:,:,i) = exp(y.*repmat(x(:,i), 1, maxlam))./(1+exp(y));
    logl_Msum(:,i) = sum(log(P_M(:,:,i)), 1);
    logl_Msum(logl_Msum(:,i) == 0, i) = NaN;
end

EBIC = -2*logl_Msum + penalty;

%get indices for selected tuning parameters
[~,lambda_opt] = min(EBIC);
%save the corresponding optimal tuning parameters, thresholds and beta
%parameters
lambda_optval = zeros(1,nvar);
%thresholds = zeros(1,nvar);
weights_opt = zeros(nvar, nvar);
for i = 1:nvar
    lambda_optval(i) = fits{i}.lambda(lambda_opt(i));
%    thresholds(i) = fits{i}.a0(lambda_opt(i));
    noti = 1:nvar; 
    noti(i) = [];
    weights_opt(i, noti) = fits{i}.beta(:,lambda_opt(i));
end

if AND == true 
    adj = weights_opt~=0;
    adj = adj.*adj.';
    weiadj = weights_opt.*adj;
    weiadj = (weiadj + weiadj.')/2;
else
    weiadj = (weights_opt + weights_opt.')/2;    
end



    
    

end

