function M = hyspec_smoothness(I, varargin)
% M = hyspec_smoothness(I, varargin)
%
% Calculate the smoothness of each spectrum (per image)
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc

% Extra arguments and defaults
names = {'block_size'};
dflts = {   [100,100]};
[block] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Initialize
if isstruct(I)
    i = length(I);
    M = [];
else
    [r,c,~,i] = size(I);
    M = zeros(r,c,i);
end

% Block function
fun_corr = @(block_struct) smoothness(block_struct.data);

h = waitbar(0,'Smoothness', 'Name', 'Smoothness');
for j=1:i
    waitbar(j/i,h,['Calculating for image: ' num2str(j) '/' num2str(i)]);
    % Apply block function
    if isstruct(I)
        M(j).d = blockproc(I(j).d,block,fun_corr,'UseParallel',parallel);
    else
        M(:,:,j) = blockproc(I(:,:,:,j),block,fun_corr,'UseParallel',parallel);
    end
end
close(h)

%% Smoothness by neighbour correlation
function S = smoothness(I)

A = I(:,:,1:end-1);
B = I(:,:,2:end);
A = bsxfun(@minus, A, mean(A,3));
B = bsxfun(@minus, B, mean(B,3));

S = sum(A.*B,3) ./ (sqrt(sum(A.^2,3)) .* sqrt(sum(B.^2,3)));
