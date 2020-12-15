function I = hyspec_ref2abs(I, varargin)
% I = hyspec_ref2abs(I, varargin)
%
% Reflectance to absorbacne (per pixel (per image))
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

% Block function
fun_ref2abs = @(block_struct) ref2abs(block_struct.data);

% Initialize
if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

h = waitbar(0,'Reflectance to absorbance', 'Name', 'Reflectance to absorbance');
for j=1:i
    waitbar(j/i,h,['Converting image: ' num2str(j) '/' num2str(i)]);
    % Apply block function
    if isstruct(I)
        I(j).d = blockproc(I(j).d,block,fun_ref2abs,'UseParallel',parallel);
    else
        I(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_ref2abs,'UseParallel',parallel);
    end
end
close(h)


%% -log10
function X = ref2abs(X)
X(X <= 0) = eps;
X = -log10(X);
% X(~isreal(X)) = 0;