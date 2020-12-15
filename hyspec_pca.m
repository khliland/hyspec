function [W,T] = hyspec_pca(I, varargin)
% [W,T] = hyspec_pca(I, varargin)
%
% Calculate principal components across all pixels (per image)
% I = array of dimensions (pixels x pixels x spectra (x images))
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc


% Extra arguments and defaults
names = {'block_size' 'ncomp'  'center' 'tol'};
dflts = {   [10000,1]       2         1 10^-5};
[block, ncomp, center, tol] = match_arguments(names,dflts,varargin{:});
block = [prod(block),1];

global parallel
if isempty(parallel)
    parallel = false;
end

% Do centering
if center == 1
    I = hyspec_center(I, 'block_size', block);
end

% Initialize
if isstruct(I)
    i = length(I);
    p = size(I(1).d,3);
else
    [r,c,p,i] = size(I);
end
W = zeros(p,ncomp,i);
if nargout == 2
    T = zeros(r,c,ncomp,i);
end

h = waitbar(0,'PCA', 'Name', 'PCA');
for j=1:i
    if isstruct(I)
        [r,c,~] = size(I(j).d);
        Ivec = reshape(I(j).d,[r*c,1,p]);
    else
        Ivec = reshape(I(:,:,:,j),[r*c,1,p]);
    end
    
    for pc=1:ncomp
        waitbar(((j-1)*ncomp+pc-1)/(ncomp*i),h,['Image: ' num2str(i) ', PC: ' num2str(pc)]);

        % Initialize from first block
        if any(~isfinite(Ivec(:))) % Handle missing
            has_missing = true;
            present = find(isfinite(sum(Ivec,3)));
            [~,~,w] = svds(squeeze(Ivec(present(randsample(length(present),min(block(1),length(present)),true)),1,:)),1);
        else
            has_missing = false;
            [~,~,w] = svds(squeeze(Ivec(randsample(r*c,min(block(1),r*c),true),1,:)),1);
        end
        w0 = zeros(p,1);
        
        k = 1;
        while abs(sum(abs(w)-abs(w0))) > tol && k < 20
            if has_missing
                fun_pca = @(block_struct) pca_fun(block_struct.data,w);
            else
                fun_pca = @(block_struct) (squeeze(block_struct.data)*w)'*(squeeze(block_struct.data));
            end
            P = blockproc(Ivec,block,fun_pca,'UseParallel',parallel);
            w = w0;
            [~,~,w0] = svds(P,1);
            k = k+1;
        end
        W(:,pc,j) = w0;
        if pc < ncomp || nargout == 2 % Deflate
            fun_pca = @(block_struct) squeeze(block_struct.data)*w0;
            t = blockproc(Ivec,block,fun_pca);
            if nargout == 2
                T(:,:,pc,j) = reshape(t,[r,c]);
            end
            Ivec = Ivec - reshape(t*w0',[r*c,1,p]);
        end
    end
end
close(h)

function result = pca_fun(data,w)
present = isfinite(sum(data,3));
result = (squeeze(data(present,:,:))*w)'*(squeeze(data(present,:,:)));