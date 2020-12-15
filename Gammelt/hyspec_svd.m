function [W,T] = hyspec_svd(I, varargin)
% [W,T] = hyspec_svd(I, varargin)
%
% Calculate principal components across all pixels (per image)
% I = array of dimensions (pixels x pixels x spectra (x images))
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% UseParallel (default = false):
%     use parallel computations from Parallel Computing Toolbox


% Extra arguments and defaults
names = {'block_size' 'ncomp'  'tol' 'UseParallel'};
dflts = {   [10000,1]       2  10^-5         false};
[block, ncomp, tol, parallel] = match_arguments(names,dflts,varargin{:});
block = [prod(block),1];

[r,c,p,i] = size(I);
W = zeros(p,ncomp,i);
if nargout == 2
    T = zeros(r,c,ncomp,i);
end

for j=1:i
    Ivec = reshape(I(:,:,:,i),[r*c,1,p]);
    
    for pc=1:ncomp
        % Initialize from first block
        [~,~,w] = svds(squeeze(Ivec(randsample(r*c,min(block(1),r*c),true),1,:)),1);
        w0 = zeros(p,1);
        
        k = 1;
        while abs(sum(abs(w)-abs(w0))) > tol && k < 20
            fun_snv = @(block_struct) (squeeze(block_struct.data)*w)'*(squeeze(block_struct.data));
            P = blockproc(Ivec,block,fun_snv,'UseParallel',parallel);
            w = w0;
            [~,~,w0] = svds(P,1);
            k = k+1;
        end
        W(:,pc,j) = w0;
        if pc < ncomp || nargout == 2 % Deflate
            fun_snv = @(block_struct) squeeze(block_struct.data)*w0;
            t = blockproc(Ivec,block,fun_snv);
            if nargout == 2
                T(:,:,pc,j) = reshape(t,[r,c]);
            end
            Ivec = Ivec - reshape(t*w0',[r*c,1,p]);
        end
    end
end
