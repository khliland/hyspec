function e = hyspec_efa(I, ncomp, sample)
% I = hyspec_efa(I, varargin)
%
% Evolving factor analysis across all images
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% ncomp = #components to be estimated
% 
% --= Optional arguments =--
% sample (default = 100 (random sample evenly sampled from each image)):
%      #spectra to use for estimation
%      or matrix of spectra

% Initialize
if nargin < 3
    sample = 100;
end

if numel(sample) > 1
    % Matrix
    e = efa(sample, ncomp);

else
    % Random sample
    if isstruct(I)
        xyi = 0;
        for j=1:length(I)
            [x,y,p] = size(I(1).d);
            xyi = xyi + x*y;
        end
        if xyi < sample
            sample = xyi;
        end
        
    else
        [x,y,p,i] = size(I);
        xyi = x*y*i;
        if xyi < sample
            sample = xyi;
        end
    end
    
    M = zeros(sample,p);
    where = 1;
    if isstruct(I)
        i = length(I);
        for j=1:i
            [x,y,p] = size(I(j).d);
            n = round(sample/(i-j+1));
            Ij = reshape(I(j).d,[x*y,p]);
            M(where:(where+n-1),:) = Ij(randi(x*y,n,1),:);
            sample = sample-n;
            where = where+n;
        end
    else
        [x,y,p,i] = size(I);
        for j=1:i
            n = round(sample/(i-j+1));
            Ij = reshape(I(:,:,:,j),[x*y,p]);
            M(where:(where+n-1),:) = Ij(randi(x*y,n,1),:);
            sample = sample-n;
            where = where+n;
        end
    end
    
    e = efa(M,ncomp);
end
        

%% Evolving factor analysis
function [e] = efa(x,ncomp)
% function evolving factor analysis efa
% [e,eforward,ebackward] = efa(d,ns)
% d is the original data matrix
% e is the abstract concentration profiles built from the efa results

% disp '% ***********************************************'
% disp '% MATLAB program EFA (evolving factor analysis) *'
% disp '% Group of Chemometrics and Solution Chemistry  *'
% disp '% University of Barcelona                       *'
% disp '% Department of Analytical Chemistry            *'
% disp '% Diagonal 647, Barcelona 08028                 *'
% disp '% e-mail equil@quimio.qui.ub.es                 *'
% disp '% ***********************************************'
% 

[nsoln,~] = size(x);

% ****************
% forward analysis
% ****************

for n=2:nsoln
    svf = svd(x(1:n,:));
    l = svf.*svf;
    nl = size(l);
    
    
    ef(1:nl,n-1) = l(1:nl,1);
end
ef = ef';

% *****************
% backward analysis
% *****************

x = x(nsoln:-1:1,:);
for n=2:nsoln
    svb = svd(x(1:n,:));
    nl = size(svb);
    l = svb.*svb;
    eb(1:nl,n-1) = l(1:nl,1);
end
eb = eb';


nf = ncomp;%input('Number of factors to be considered:? ');
for j = 1:nf
    jj = nf+1-j;
    for i = 1:nsoln-1,
        ii = nsoln-i;
        if ef(i,j) <= eb(ii,jj),
            e(i,j) = ef(i,j);
        else
            e(i,j) = eb(ii,jj);
        end
        if e(i,j) == 0.0
            e(i,j) = 1.0e-30;
        end
    end
end

e(2:nsoln,:) = e(1:nsoln-1,:);
    