function T = hyspec_threshold(I, left, right, thr, varargin)
% T = hyspec_threshold(I, varargin)
%
% Thresholding of spectra (per pixel (per image))
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% 
% --= Compulsory argument =--
% left
%      left endpoint of threshold criterion
% right
%      right endpoint of threshold criterion
% thr
%      threshold
% 
% --= Optional arguments =--
% derivative (default = 0)
%      ~= 0 threshold based on 1st derivative spectra
% direction (default = 1)
%      1 = larger than threshold
%     -1 = smaller than threshold
% block_size (default = [100,100]):
%      size of blocks in blockproc

% Extra arguments and defaults
names = {'block_size' 'derivative' 'direction'};
dflts = {   [100,100]            0           1};
[block,derivative,direction] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Block function
fun_threshold = @(block_struct) threshold(block_struct.data, left,right,thr,direction);

% Initialize
if isstruct(I)
    i = length(I);
else
    i = size(I,4);
    T = zeros([size(I,1),size(I,2),i]);
end

% Derivative
if derivative ~= 0
    I = hyspec_derivative(I,1);
end

h = waitbar(0,'Thresholding', 'Name', 'Thresholding');
for j=1:i
    waitbar(j/i,h,['Thresholding image: ' num2str(j) '/' num2str(i)]);

    % Apply block function
    if isstruct(I)
        T(j) = struct('d',blockproc(I(j).d,block,fun_threshold,'UseParallel',parallel));
    else
        T(:,:,j) = blockproc(I(:,:,:,j),block,fun_threshold,'UseParallel',parallel);
    end
end
close(h)


%% Thresholding
function T = threshold(S, left,right,thr,direction)
% Thresholding of individual spectra

dif = max(S(:,:,left:right),[],3) - min(S,[],3);
if direction == 1
    T   = dif > thr;
end
if direction == -1
    T   = dif < thr;
end
