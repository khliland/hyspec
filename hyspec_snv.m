function I = hyspec_snv(I, varargin)
% I = hyspec_snv(I, varargin)
%
% Standard normal variate correction of spectra (per pixel (per image))
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% mean (default = 0)
%      ~= 0 omits standardisation (only mean centering)

% Extra arguments and defaults
names = {'block_size' 'mean'};
dflts = {   [100,100]      0};
[block,only_mean] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Block function
if only_mean == 0
    fun_snv = @(block_struct) SNV(block_struct.data);
else
    fun_snv = @(block_struct) omean(block_struct.data);
end

% Initialize
if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

h = waitbar(0,'SNV', 'Name', 'SNV');
for j=1:i
    waitbar(j/i,h,['Correcting image: ' num2str(j) '/' num2str(i)]);

    % Apply block function
    if isstruct(I)
        I(j).d = blockproc(I(j).d,block,fun_snv,'UseParallel',parallel);
    else
        I(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_snv,'UseParallel',parallel);
    end
end
close(h)


%% Standard normal variate
function S = SNV(S)
% Standard normal variate of individual spectra

S  = bsxfun(@minus,S,mean(S,3));
sd = std(S,[],3);
sd(sd==0) = 1;
S  = bsxfun(@times,S,1./sd);


%% Only mean centering
function S = omean(S)
% Standard normal variate of individual spectra

S  = bsxfun(@minus,S,mean(S,3));
