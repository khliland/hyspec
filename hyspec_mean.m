function M = hyspec_mean(I, varargin)
% M = hyspec_mean(I, varargin)
%
% Calculate the mean spectrum across all pixels (per image)
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
    p = size(I(1).d,3);
else
    i = size(I,4);
    p = size(I,3);
end
M = zeros(i,p);

% Block function
% fun_sum = @(block_struct) squeeze(sum(sum(block_struct.data),2));
fun_sum = @(block_struct) squeeze(nanmean(nanmean(block_struct.data),2));

for j=1:i
    % Apply block function
    if isstruct(I)
        I2 = blockproc(I(j).d,block,fun_sum,'UseParallel',parallel);
    else
        I2 = blockproc(I(:,:,:,j),block,fun_sum,'UseParallel',parallel);
    end
    
    % Determine size and collect block calculations
    reps   = size(I2,1)/p;
%     M(j,:) = sum(reshape(I2,p,reps*size(I2,2)),2)./(r*c);
    M(j,:) = nanmean(reshape(I2,p,reps*size(I2,2)),2);
end