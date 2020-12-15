function I = hyspec_derivative(I, order, varargin)
% M = hyspec_derivative(I, varargin)
%
% Standard normal variate correction of spectra (per pixel (per image))
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% 
% --= Compulsory argument =--
% order
%      derivative order
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% points
%      number of smoothing points
% poly
%      degreen of polynomial in derivative

% Extra arguments and defaults
names = {'block_size' 'points' 'poly'};
dflts = {   [100,100]       0       0};
[block, points, poly] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Defaults
if points == 0
    if order == 0
        points = 9;
    elseif order == 1
        points = 9;
    elseif order == 2
        points = 21;
    end
end
if poly == 0
    poly = 3;
end

% Common parameters
G = sgolaycoef(poly,points);

% Block function
fun_deriv = @(block_struct) derivative(block_struct.data, G, points, order);

if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

h = waitbar(0,'Derivative', 'Name', 'Derivative');
for j=1:i
    waitbar(j/i,h,['Derivating image: ' num2str(j) '/' num2str(i)]);

    % Apply block function
    if isstruct(I)
        I(j).d = blockproc(I(j).d,block,fun_deriv,'UseParallel',parallel);
    else
        I(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_deriv,'UseParallel',parallel);
    end
end
close(h)


%% Savitzky-Golay derivative
function M = derivative(X,G,F,Dn)

X = permute(X,[1,3,2]);
[nrow1, ncol, nrow2] = size(X);
M  = zeros([nrow1,nrow2,ncol]);
F1 = (F+1)/2;
F2 = -F1+1:F1-1;

if Dn == 0
    for i=1:nrow2
        for j = F1:ncol-(F-1)/2 %Calculate the n-th derivative of the i-th spectrum
            M(:,i,j) = X(:,j + F2, i)*G(:,1);
        end
    end
else
    G = Dn.*G;
    for i=1:nrow2
        for j = F1:ncol-(F-1)/2 %Calculate the n-th derivative of the i-th spectrum
            M(:,i,j) = X(:,j + F2, i)*G(:,Dn+1);
        end
    end
end
% M = permute(M,[1,3,2]);

%% Parameters
function G = sgolaycoef(k,F)
%sgolaycoef         - Computes the Savitsky-Golay coefficients
%function G = sgolaycoef(k,F) 
%where the polynomial order is K and the frame size is F (an odd number)
%No direct use

W = eye(F);
s = fliplr(vander(-(F-1)/2:(F-1)/2));
S = s(:,1:k+1);   % Compute the Vandermonde matrix
[~,R] = qr(sqrt(W)*S,0);
G = S/(R)*inv(R)'; % Find the matrix of differentiators
% B = G*S'*W; % Compute the projection matrix B
