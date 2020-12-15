function Q = hyspec_quantile(I, varargin)
% M = hyspec_quantile(I, varargin)
%
% Calculate quantile spectra across all pixels (per image)
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% quant = 0 <= quantiles <= 1

% --= Optional arguments =--
% quant (default = [0.01 0.1 0.5 0.9 0.99])
%       0 <= quantiles <= 1
% doPlot
%       xvalues for quantile plotting

% Extra arguments and defaults
names = {                          'quant' 'doPlot'};
dflts = {[0.01 0.05 0.1 0.5 0.9 0.95 0.99]       []};
[quant, doPlot] = match_arguments(names,dflts,varargin{:});

if any(quant<0) || any(quant>1)
    stop('Quantiles should be between 0 and 1')
end

% Initialize
if isstruct(I)
    i = length(I);
    p = size(I(1).d,3);
else
    [r,c,p,i] = size(I);
end
nq = length(quant);
Q  = zeros(nq,p,i);
for j=1:i
    if isstruct(I)
        [r,c,p] = size(I(j).d);
        J = reshape(I(j).d,[r*c,p]);
    else
        J = reshape(I(:,:,:,j),[r*c,p]);
    end
    Q(:,:,j) = quantile(J,quant);
end

if ~isempty(doPlot)
    for j=1:ceil(nq/2)
        patch([doPlot, reverse(doPlot)],[Q(j,:), reverse(Q(end+1-j,:))],'k','EdgeColor','none')
        alpha(0.05)
    end
end

%% Reverse vector
function rev = reverse(y)
rev = y(end:-1:1);