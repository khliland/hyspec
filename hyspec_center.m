function I = hyspec_center(I, varargin)
% I = hyspec_snv(I, varargin)
%
% Centering of spectra (per pixel (per image))
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
fun_ctr = @(block_struct) CTR(block_struct.data);

% Initialize
if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

h = waitbar(0,'Centering', 'Name', 'Centering');
for j=1:i
    waitbar(j/i,h,['Correcting image: ' num2str(j) '/' num2str(i)]);

    % Apply block function
    if isstruct(I)
        I(j).d = blockproc(I(j).d,block,fun_ctr,'UseParallel',parallel);
    else
        I(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_ctr,'UseParallel',parallel);
    end
end
close(h)


%% Centering
function S = CTR(S)
% Centering of individual spectra

S  = bsxfun(@minus,S,mean(S,3));
