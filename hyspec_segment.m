function M = hyspec_segment(I, centers, varargin)
% M = hyspec_segment(I, centers, varargin)
%
% Image segmentation based on cosine similarity to center spectra
% I = array of dimensions (pixels x pixels x spectra (x images))
%     or hyspec_object
% centers = segment centers
% 
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% type (default = 1)
%      1=nearest neighbour, 2=LDA, 3=QVision, 4=Single chanel threshold
% prior (default = [])
%      prior weights for each class/group

% Extra arguments and defaults
names = { 'block_size'  'type' 'prior'};
dflts = {[10000,10000]       1      []};
[block,type,prior] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Rank deficiency
rerank = false;

% Block function
if type == 1 % Nearest neighbour
    fun_segment = @(block_struct) cossim(squeeze(block_struct.data), centers, prior);
elseif type == 2 % LDA
    g = length(centers);
    if isempty(prior)
        prior = ones(g,1)./g;
    end
    Y = [];
    for i = 1:g
        Y = [Y; i*ones(size(centers{i},1),1)]; %#ok<AGROW>
    end
    X = cell2mat(centers);
    if rank(X) < size(X,2)
        rerank = true;
        C = mean(X);
        X = bsxfun(@minus,X,C);
        [X,s,v] = svds(X, max(1,rank(X)-g-1));
    end
    training = struct('X',X, 'Y',Y);
    fun_segment = @(block_struct) ldaB(squeeze(block_struct.data), training, prior);
elseif type == 3 % Qvision 15 ch.
    fun_segment = @(block_struct) qvision(squeeze(block_struct.data));
elseif type == 4 % Single channel cut-off
    fun_segment = @(block_struct) cutoff(block_struct.data, centers);
else
    error('Unkown segmentation type')
end

% Initialize
if isstruct(I)
    i = length(I);
    M = I;
else
    [r,c,p,i] = size(I);
    M = zeros(r,c,i);
end

for j=1:i
    if isstruct(I)
        [r,c,p] = size(I(j).d);
        if rerank
            X = bsxfun(@minus, reshape(I(j).d,[r*c,p]), C);
            X = X*v/s;
            Ivec = reshape(X,[r*c,1,size(s,1)]);
        else
            if type ~= 4
                Ivec = reshape(I(j).d,[r*c,1,p]);
            else
                Ivec = I(j).d;
            end
        end
        
        % Apply block function
        if type ~= 4
            M(j).d = reshape(blockproc(Ivec,block,fun_segment,'UseParallel',parallel), [r,c]);
        else
            M(j).d = blockproc(Ivec,block,fun_segment,'UseParallel',parallel);
        end
        M(j).v = [];
    else
        if rerank
            X = bsxfun(@minus, reshape(I(:,:,:,j),[r*c,p]), C);
            X = X*v/s;
            Ivec = reshape(X,[r*c,1,size(s,1)]);
        else
            if type ~= 4
                Ivec = reshape(I(:,:,:,j),[r*c,1,p]);
            else
                Ivec = I(:,:,:,j);
            end
        end
        
        % Apply block function
        if type ~= 4
            M(:,:,j) = reshape(blockproc(Ivec,block,fun_segment,'UseParallel',parallel), [r,c]);
        else
            M(:,:,j) = blockproc(Ivec,block,fun_segment,'UseParallel',parallel);
        end
    end
end


%% Cosine similarity
function D = cossim(X, C, prior)

Nx = sqrt(sum(X.^2,2));
Nc = sqrt(sum(C.^2,2));

if isempty(prior)
    [~,D] = max((X*C')./(Nx*Nc'),[],2);
else
    [~,D] = max(bsxfun(@times,(X*C')./(Nx*Nc'),(prior(:))'),[],2);
end


%% Linear discriminant analysis
function D = ldaB(Xt,T,prior)

D = lda(T.X,T.Y,Xt,prior);


%% Qvision
function D = qvision(X)
lowlim = 0.1;
D = (X(:,4)<X(:,1) & X(:,4)<X(:,12) & X(:,12)>X(:,15) & X(:,10)> lowlim) + 1;


%% LDA function
function [group,d,dist] = lda(X,Y,varargin)

[Yd,m] = dummy(Y); % Dummy respons and number of classes
m = m+1;
Y = Yd*(1:m)';

if isempty(varargin)
    Xnew  = X;
    Prior = ones(m,1)./m;
elseif length(varargin) == 1
    Xnew  = varargin{1};
    Prior = ones(m,1)./m;
else
    Xnew  = varargin{1};
    Prior = varargin{2}';
end

% Dimensions
[n,p] = size(X);
n2    = size(Xnew,1);

Xs = (Yd'*Yd)\Yd'*X;   % Mean for each group
Xc = X-Xs(Y,:);        % Centering
S  = Xc'*Xc./(n-m);    % Common covariance matrix

% Fast LDA without posterior probabilities
if nargout == 1
    % Common element across all observations
    R1 = Xs/S;  % '/' is faster, 'pinv' more robust
    R2 = - 0.5*diag(R1*Xs') + log(Prior);
    d  = Xnew*R1' + repmatS(R2',[n2,1]);

% Full LDA with posterior values
else
    Sib = zeros(m*p,m*p); % Block diagonal sparse matrix contianing all Si
    Si  = inv(S);         % 'inv' is faster, 'pinv' more robust
    for i=1:m
        Sib((i-1)*p+(1:p),(i-1)*p+(1:p)) = Si;
    end
    Xst = Xs';                                       % Transposed means
    R = repmatS(Xnew',[m,1])-repmatS(Xst(:),[1,n2]); % Center using all groups
    Q = R.*(Sib*R);                                  % Core: (x-mu)*S^-1*(x-mu)

    d = zeros(n2,m);
    r = -0.5*reshape(sum(reshape(Q(:),p,m*n2),1),[m,n2])';
    
    % Alternative calculations for extreme observations, i.e. when r<-700
    q = max(r,[],2) < -700; 
    if any(q)
        nq = sum(q);
        d1 = zeros(nq,m);
        r1 = r(q,:) + repmatS(log(Prior'),[nq,1]);
        for i=1:m
            d1(:,i) = sum(exp(r1-repmatS(r1(:,i),[1,m])),2);
        end
        d(q,:) = 1./d1;
    end

    % Ordinary calculation
    PSa = repmatS(Prior',[n2-sum(q),1]);
    d(~q,:) = PSa.*exp(r(~q,:));
    if nargout == 3
        dist = d;
    end
    d = d./repmatS(sum(d,2),[1,m]);
end

[~,group] = max(d,[],2);  % Finds the most probable group


%% Single channel cut-off
function C = cutoff(X, cutoff)

if cutoff(2) == 0
    C = (X(:,:,cutoff(1)) > cutoff(3)) * 1;
else
    C = ((X(:,:,cutoff(1))./X(:,:,cutoff(2))) > cutoff(3))*1;
end


%% Dummy function
% function [dum,p] = dummy(Y)
% 
% n = size(Y,1);
% p = max(Y);
% 
% dum = zeros(n,p);
% 
% for i=1:n
%     dum(i,Y(i))=1;
% end
function [dY,m] = dummy(Y)
% Rutinen konverterer en vektor Y
% av K (uordnede) klasselabler 
% til en N*K indikatormatrise
Ys  = sort(Y(:));
dYs = [0;diff(Ys)];
s   = Ys(dYs~=0); % Tilsvarer sort(unique(Y))
m   = length(s);

dY = zeros(size(Y,1),m+1);
dY(:,1) = Y==Ys(1);
for i = 1:m
    dY(:,i+1) = Y==s(i);
end


%% Shorter repmat
function B = repmatS(A,siz)
[m,n] = size(A);
if (m == 1 && siz(2) == 1)
    B = A(ones(siz(1), 1), :);
elseif (n == 1 && siz(1) == 1)
    B = A(:, ones(siz(2), 1));
else
    mind = (1:m)';
    nind = (1:n)';
    mind = mind(:,ones(1,siz(1)));
    nind = nind(:,ones(1,siz(2)));
    B = A(mind,nind);
end