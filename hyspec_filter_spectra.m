function I = hyspec_filter_spectra(I, varargin)
% M = hyspec_filter_spectra(I, varargin)
%
% Filtering of spectra, e.g. median filter (per pixel (per image))
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% f
%      filter length

% Extra arguments and defaults
names = {'block_size' 'f'};
dflts = {   [100,100]   3};
[block, f] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Block function
fun_filter = @(block_struct) filter_func(block_struct.data, f);

if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

h = waitbar(0,'Filtering', 'Name', 'Filter');
for j=1:i
    waitbar(j/i,h,['Filtering image: ' num2str(j) '/' num2str(i)]);

    % Apply block function
    if isstruct(I)
        I(j).d = blockproc(I(j).d,block,fun_filter,'UseParallel',parallel);
    else
        I(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_filter,'UseParallel',parallel);
    end
end
close(h)


%% 1D median filter
function X = filter_func(X,f)

X = permute(X,[1,3,2]);
for i=1:size(X,3)
    X(:,:,i) = medfilt2(X(:,:,i), [1 f]);
end
X = permute(X,[1,3,2]);
