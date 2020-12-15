function [C,S] = hyspec_mcr(I, ncomp, varargin)
%% Multivariate Curve Resolution hyperspectral images
% [corrected, parameters, par_names, model] = hyspec_mcr(I, ncomp, varargin)
%
% --= Compulsory argument =--
% I:
%     an array of size pixels x pixels x spectra (x images)
%     or hyspec_object
% ncomp:
%     #components
%
% --= Optional arguments =--
% block_size (default = [100,100]):
%      size of blocks in blockproc
% non_neg (default = [0 0]):
%      non-negativity (number of conc. and spectra (-1=all))
% unimod (default = [0 0]):
%      unimodality    (number of conc. and spectra (-1=all))
% initial (default = 0 (automatic concentrations estimates)):
%      initial estimates (matrix of spectra or concentrations)
% max_iter (default = 50):
%      maximum number of ALS iterations
% sig_tol (default = 0.1):
%      sigma tolerance (in percent change per iteration)
% sample (default = 200):
%      which spectra to estimate MCR from: 0 = all,
%      >0 = evenly sampled from images, a matrix = set of spectra

%
% --= Output =--
% corrected:
%     corrected spectra from EMSC
% parameters:
%     estimated EMSC parameters per spectrum
% par_names:
%     names of parameters in EMSC model
% model:
%     model spectra used in the EMSC

% Extra arguments and defaults
names = {'block_size' 'non_neg' 'unimod' 'initial' 'max_iter' 'sig_tol' 'sample'};
dflts = { [1000,1000]     [0,0]    [0,0]         0         50       0.1      400};
[block, non_neg, unimod, initial, max_iter, sig_tol, sample] = match_arguments(names,dflts,varargin{:});

global parallel
if isempty(parallel)
    parallel = false;
end

% Handle non-finite values
J = I;
if isstruct(I)
    i = length(I);
    finitemap = cell(i,2);
    for j=1:i
        [x,y,p] = size(I(j).d);
        J(j).d  = reshape(I(j).d, [x*y,1,p]);
        avail   = isfinite(sum(J(j).d,3));
        I(j).d  = J(j).d(avail,1,:);
        finitemap{j,2} = [x,y,p];
        finitemap{j,1} = avail;
    end
else
    [x,y,p,i] = size(I,4);
    Ir = reshape(I,[x*y,1,p,i]);
    finitemap = cell(i,1);
    J = []; J.d = []; I = J;
    for j=1:i
        J(j).d  = Ir(:,:,:,i); %#ok<AGROW>
        avail   = isfinite(sum(J(j).d,3));
        I(j).d  = J(j).d(avail,1,:);
        finitemap{j,1} = avail;
    end
end

% Samples to use for MCR
if numel(sample) > 1
    % Matrix
    X = sample;
    
else
    % Random sample
    if isstruct(I)
        xyi = 0;
        for j=1:length(I)
            [x,y,p] = size(I(1).d);
            xyi = xyi + x*y;
        end
        if sample < 1 || xyi < sample
            sample = xyi;
        end
        
    else
        [x,y,p,i] = size(I);
        xyi = x*y*i;
        if sample < 1 || xyi < sample
            sample = xyi;
        end
    end
    
    X = zeros(sample,p);
    nleft = sample;
    where = 1;
    if isstruct(I)
        i = length(I);
        for j=1:i
            [x,y,p] = size(I(j).d);
            n = round(nleft/(i-j+1));
            Ij = reshape(I(j).d,[x*y,p]);
            X(where:(where+n-1),:) = Ij(randi(x*y,n,1),:);
            nleft = nleft-n;
            where = where+n;
        end
    else
        [x,y,p,i] = size(I);
        for j=1:i
            n = round(nleft/(i-j+1));
            Ij = reshape(I(:,:,:,j),[x*y,p]);
            X(where:(where+n-1),:) = Ij(randi(x*y,n,1),:);
            nleft = nleft-n;
            where = where+n;
        end
    end
end

% Initial concentration/profiles
if initial == 0
    initial = hyspec_efa(I, ncomp, sample);
end

% MCR-ALS
h = waitbar(0,'Creating MCR model', 'Name', 'MCR');
[~,S,~,~,~,~,convergence] = als(X,initial,max_iter,sig_tol,non_neg,unimod);
if convergence == -1
    warndlg('MCR-ALS did not converge')
end

if isstruct(I)
    i = length(I);
else
    i = size(I,4);
end

% Block function
fun_als = @(block_struct) als_block(block_struct.data, S,1,sig_tol,non_neg,unimod);

% Correction
if isstruct(I)
    C = I;
    
    for j=1:i
        waitbar(j/i,h,['Estimating concentrations for image: ' num2str(j) '/' num2str(i)]);
        
        % Apply block function
        C(j).d = blockproc(I(j).d,block,fun_als, 'UseParallel', parallel);
        C(j).v = 1:ncomp;
    end
else
    [r,c,~,~] = size(I);
    C = zeros(r,c,ncomp,i);
    
    for j=1:i
        waitbar(j/i,h,['Estimating concentrations for image: ' num2str(j) '/' num2str(i)]);
        
        % Apply block function
        C(:,:,:,j) = blockproc(I(:,:,:,j),block,fun_als, 'UseParallel', parallel);
    end
end
close(h)

% Handle non-finite values
if exist('Ir','var')
    for j=1:i
        J(j).d(finitemap{j,1},1,:) = C(j).d;
        Ir(:,:,:,j) = J(j).d;
    end
    C = reshape(Ir,[x,y,p,i]);
else
    for j=1:i
        J(j).d(finitemap{j,1},1,1:ncomp) = C(j).d;
        C(j).d = reshape(J(j).d(:,1,1:ncomp), [finitemap{j,2}(1:2),ncomp]);
    end
end

%% Multivariate Curve Resolution (MCR) - Alternating Least Squares (ALS)
function copt = als_block(d,x0,nit,tolsigma,non_neg,unimod)
% Wrapper for blockproc
[r,c,p] = size(d);
ncomp   = size(x0,1);
d = reshape(d,r*c,p);
[copt,~,~,~,~,~,~] = als(d,x0,nit,tolsigma,non_neg,unimod);
copt = reshape(copt,r,c,ncomp);


function [copt,sopt,sdopt,ropt,areaopt,rtopt,convergence] = als(d,x0,nit,tolsigma,non_neg,unimod)
%** Multivariate Curve Resolution (MCR) - Alternating Least Squares (ALS) *********************
%
%function [copt,sopt,sdopt,ropt,areaopt,rtopt] = als(d,x0,nexp,nit,tolsigma,isp,csel,ssel,vclos1,vclos2);
%
%      where
%
% INPUT VALUES:
%
%       d : experimental data matrix
%       x0: initial estimates of the concentration profiles
%           or of the species spectra
%     nexp: number of data matrices analyzed simultaneously
%      nit: maximum number of iterations (50 is the default)
% tolsigma: convergence criterion in the difference of sd of residuals
%           between iterations (0.1% is the default)
%      isp: correspondence among the species in the experiments
%     csel: matrix including the equality constraints (selective channels
%           or known values) in the conc matrix
%           0 values  =  non-present; >0 known  or selective values; 'inf' or 'NaN' unknown values
%     ssel: matrix including the equality constraints (selective channels
%           or known values) in the abss matrix
%           0 values  =  non-present; >0 known or selective  values; 'inf' or 'NaN' unknown values
%    vclos1: vector of variable closure constants for conc profiles
%    vclos2: the same as vclos2 when two closure conditions are applied
%
% OUTPUT VALUES:
%
%       copt: optimized species concentrations
%       sopt: optimized species spectra
%       ropt: residuals d - copt*sopt at the optimum
%      sdopt: standard deviation of fitting residuals at the optimum
%    areaopt: areas of concentration profiles (only for quantitation)
%      rtopt: ratio of areas (only for quantitation)
%
%function [copt,sopt,sdopt,ropt,areaopt,rtopt] = als(d,x0,nexp,nit,tolsigma,isp,csel,ssel,vclos1,vclos2);
%
%*****************************************************************************

%*****************************************************************************
% other important variables
% nrow number of rows (spectra) in d
% ncol number of columns (channels, wavelengths) in d
% ils kind of initial estimate provided from efa;
%     ils  =  1 initial estimates of concentrations;
%     ils  =  2 initial estimates of spectra
% nsign is the total number of significant species
% nexp number of experiments simultaneously analyzed
% nspec number of species in each experiment
% ishape  =  0,1,2 data structure (see below)

nexp = 1;
isp  = ones(1,min(size(x0)));
% csel = [];
% ssel = [];
% vclos1 = 0;
% vclos2 = 0;
ialgs  = 2; % 1=nnls, 2=fnnls
ialg   = 2;
cmod   = 1; % Unimodality implementation: vertical (0), horizontal (1), average (2)
inorm  = 2; % normalization 0, 1 or 2: 0=none, 1=spectra (rows) equal height
                                            % 2=spectra (rows) equal length

% clc;close
%
% disp ('% ***********************************************')
% disp ('% MATLAB program MCR-ALS:                       *')
% disp ('% multivariate curve resolution (MCR)           *')
% disp ('% alternating least squares (ALS)               *')
% disp ('% written by Roma Tauler and Anna de Juan       *')
% disp ('% last update, December 2003                    *')
% disp ('% Chemometrics and Solution Equilibria group    *')
% disp ('% University of Barcelona                       *')
% disp ('% Department of Analytical Chemistry            *')
% disp ('% Diagonal 647, Barcelona 08028                 *')
% disp ('% e-mail roma@quimio.qui.ub.es                  *')
% disp ('% ***********************************************')

% A) DATA PREPARATION AND INPUT

% if nargin<2,
% 	disp(' ');disp(' ');disp(' ');disp(' ');
% 	disp('Input arguments are lower than needed to start == ')
% 	disp('At least two input arguments are needed')
% 	disp('Syntax: [copt,sopt,sdopt,rtopt,ropt] = als(d,x0,nit,tolsigma,isp,msel,E,vclos);')
% 	disp(' ');disp(' ');disp(' ');disp(' ');
% 	return
% end

[nrow,ncol] = size(d);

% check dimensions of initial estimates

[nrow2,ncol2] = size(x0);

if nrow2 == nrow,	nsign = ncol2; ils = 1;end
if ncol2 == nrow, nsign = nrow2; x0 = x0'; ils = 1; end

if ncol2 == ncol, nsign = nrow2; ils = 2;end
if nrow2 == ncol, nsign = ncol2; x0 = x0'; ils = 2; end

% *****************
% PLOT THE RAW DATA
% *****************

% subplot(2,1,2);plot(d);title('Columns of raw data matrix');
% subplot(2,1,1);plot(d');title('Rows (spectra) of raw data matrix');
%
% disp('****** Press any key to continue ******');pause;

% close

if ils == 1,
    conc = x0;
    [nrow,nsign] = size(conc);
    abss = conc\d;
end

if ils == 2,
    abss = x0;
    [nsign,ncol] = size(abss);
%     conc = d/abss;
end

% **************************************************************
% PLOT INITIAL ESTIMATIONS OF CONCENTRATION AND SPECTRA PROFILES
% **************************************************************

% if ils == 1,
% subplot(2,1,1);plot(conc);title('Initial estimates of the concentration profiles')
% subplot(2,1,2);plot(abss');title('Unconstrained spectra calculated by LS (iteration 1)')
% end
%
% if ils == 2,
% subplot(2,1,2);plot(abss');title('Initial estimates of the spectra')
% subplot(2,1,1);plot(conc);title('Unconstrained concentration profiles calculated by LS (iteration 1)')
% end
%
% disp('****** Press any key to continue ******');pause;
%
% close

% INITIALIZATIONS
% if nargin<3,nexp = 1;end
% if isempty(nexp)||nexp == 0,nexp = 1;end
% if nargin<4,nit = 50;end
% if isempty(nit)|| nit == 0,nit = 50;end
% if nargin<5,tolsigma = 0.1;end
% if isempty(tolsigma) || tolsigma == 0,tolsigma = 0.1;end
% if nargin<6 && nexp == 1,isp = ones(1,nsign);end
% if nargin<6 && nexp>1,isp = ones(nexp,nsign);end
% if isempty(isp) || isp == 0, isp = ones(1,nsign);end
% if nargin<7,csel = [];end
% if nargin<8,ssel = [];end
% if nargin<9,vclos1 = 0;end
% if nargin<10,vclos2 = 0;end
% if nargin<8,scons = 'n';end
% if nargin<7,ccons = 'n';end
% if nexp == 1,
    ncinic(nexp) = 1;
    ncfin(nexp) = ncol;
    nrinic(nexp) = 1;
    nrfin(nexp) = nrow;
% end

% scons = 'y'; % all the spectra matrices the same constraints
% ccons = 'y'; % all the concentration matrices the same constraints
niter = 0;% iterations counter
idev = 0;% divergence counter
% idevmax = 10;% maximum number of diverging iterations
answer = 'n'; % default answer
% ineg = 0;% used for non-negativity constraints
% imod = 0;% used for unimodality constraints
% iclos0 = 0;% used for closure constraints
% iassim = 0;% used for shape constraints
% datamod = 99;% in three-way type of matrix augmentation (1 = row,2 = column)
% matr = 1;% one matrix
% matc = 1;% one matrix
% vclos1n = 0;% used for closure constraints
% vclos2n = 0;% used for closure constraints
% inorm = 0;% no normalizatio (when closurfe is applied)
% type_csel = []; %no equality/lower than constraints in concentrations
% type_ssel = []; %no equality/lower than constraints in spectra

%***************************
% DEFINITION OF THE DATA SET
%***************************

totalconc(1:nsign,1:nexp) = ones(nsign,nexp);

% IN SIMULTANEOUS ANALYSIS OF SEVERAL SAMPLES
% ENTER NUMBER OF SPECTRA

% if nexp > 1,
%     disp(' ')
%     disp('CLASSIFICATION OF THREE-WAY DATA SETS')
%     disp('Column-wise augmented data matrix (1)')
%     disp('Row-wise augmented data matrix (2)')
%     disp('Column- and row-wise augmented data matrix (3)')
%     disp(' ')
%     datamod  =  input('Define your data set ');
%     
%     
%     if datamod  ==  1
%         
%         matr  =  1;
%         ncinic(1) = 1;
%         ncfin(1) = ncol;
%         matc  =  nexp;
%         nrinic(1) = 1;
%         
%         for i = 1:matc,
%             
%             disp(' ')
%             disp(['C matrix, submatrix number ', num2str(i)]);
%             nrsol(i) = input('Enter the number of rows: ');
%             nrfin(1) = nrsol(1);
%             if i>1,
%                 nrinic(i) = nrfin(i-1)+1;
%                 nrfin(i) = nrinic(i)+nrsol(i)-1;
%             end
%             ncinic(i) = 1;
%             ncfin(i) = ncol;
%         end
%     end
%     
%     if datamod  ==  2
%         
%         matc  =  1;
%         nrinic(1) = 1;
%         nrfin(1) = nrow;
%         matr  =  nexp;
%         ncinic(1)  =  1;
%         
%         for i = 1:matr,
%             
%             disp(' ')
%             disp(['S matrix, submatrix number ', num2str(i)]);
%             ncsol(i) = input('Enter the number of columns: ');
%             ncfin(1) = ncsol(1);
%             if i>1, ncinic(i) = ncfin(i-1)+1;
%                 ncfin(i) = ncinic(i)+ncsol(i)-1; end
%             
%         end
%     end
%     
%     if datamod  ==  3
%         
%         matc  =  input('How many submatrices has the C matrix? ')
%         matr  =  input('How many submatrices has the S matrix? ')
%         
%         if matc*matr ~ =  nexp
%             error('Warning: nr. of submatrices in C x nr. of submatrices in S should be equal to nexp')
%         end
%         
%         nrinic(1) = 1;
%         
%         for i = 1:matc,
%             
%             disp(' ')
%             disp(['C matrix, submatrix number ', num2str(i)]);
%             nrsol(i) = input('Enter the number of rows: ');
%             nrfin(1) = nrsol(1);
%             if i>1, nrinic(i) = nrfin(i-1)+1;
%                 nrfin(i) = nrinic(i)+nrsol(i)-1; end
%             
%         end
%         
%         ncinic(1)  =  1;
%         
%         for i = 1:matr,
%             
%             disp(' ')
%             disp(['S matrix, submatrix number ', num2str(i)]);
%             ncsol(i) = input('Enter the number of columns: ');
%             ncfin(1) = ncsol(1);
%             if i>1, ncinic(i) = ncfin(i-1)+1;
%                 ncfin(i) = ncinic(i)+ncsol(i)-1; end
%             
%         end
%         
%     end
%     
% else
    
% WHEN ONLY ONE EXPERIMENT IS PRESENT EVERYTHING IS CLEAR

nrsol(1) = nrow;
nrinic(1) = 1;
nrfin(1) = nrsol(1);
% nesp(1) = nsign;
matr  =  1;
matc  =  1;
isp(1,1:nsign) = ones(1,nsign);
% ishape = 0;

    % end

% disp('speciation');isp


% *************************
% INPUT TYPE OF CONSTRAINTS
% *************************

while answer  ==  'n' ||answer  == 'N'
%     clc
%     disp(' ')
%     disp('INPUT TYPE OF CONSTRAINTS TO BE APPLIED')
%     disp('None (0)')
%     disp('Non-negativity (1)')
%     disp('Unimodality (2)')
%     disp('Closure (3)')
%     disp('Equality (known) / Lower than (selectivity) constraints in conc profiles (4)')
%     disp('Equality (known) / Lower than (selectivity) constraints in spectra profiles (5)')
%     disp('Shape constraints (6)')
%     disp('Three-way data structure constraints (7)')
%     disp(' ')
%     disp('Enter a vector with the selected constraints, e.g. [1,3,5] ')
%     wcons  =  input('Enter the constraints to be applied in the optimization: ');
    wcons = [];
    if any(non_neg ~= 0)
        wcons = [wcons 1]; %#ok<AGROW>
    end
    if any(unimod ~= 0)
        wcons = [wcons 2]; %#ok<AGROW>
    end
    
%     if matc>1
%         ccons  =  input('Do you want to apply the same constraints to all C submatrices? (y/n) ','s');
%     end
%     
%     if matr>1
%         scons  =  input('Do you want to apply the same constraints to all S submatrices? (y/n) ','s');
%     end
    
    
    % ***************************
    % B) SELECTION OF CONSTRAINTS
    % ***************************
    
    % **************************
    % NON-NEGATIVITY CONSTRAINTS
    % **************************
    
%     c1  =  find(wcons  ==  1);
%     if ~isempty(c1)
    if any(wcons == 1)
        ineg = non_neg;
%         disp(' ')
%         ineg = input('Enter the non-negativity constraints (1 = conc / 2 = conc and spectra / 3 = spectra ): ');
%         disp(' ')
        if ineg(2) ~= 0
%         if ineg == 3 || ineg  == 2
            
%             disp(' ')
%             disp('SELECTION OF THE NON-NEGATIVITY IMPLEMENTATION FOR SPECTRA')
%             disp('Warning: nnls or fnnls algorithms can constrain all or none of the present species.')
%             disp('Constraint of some selected species is only possible with the "forced to zero" option')
%             disp(' ')
%             ialgs = input('Enter the selected algorithm for spectra (0  =  forced to zero / 1  =  nnls / 2  =  fnnls)  ');
%             ialgs = ialgs;
            
%             if scons == 'y' || nexp  ==  1
%                 
%                 if ialgs  ==  0
%                     disp(' ')
%                     nspneg = input('How many spectra should be positive? ');
%                     if nspneg  ==  nsign
%                         spneg  =  ones(nsign,matr);
%                     else
%                         spnegr =  input('Enter a vector with the positive spectra (e.g. sp 1 and 3 [1,0,1]) ');
%                         spneg  =  spnegr'*ones(1,matr);
%                     end
%                 else
                    spneg  =  ones(nsign,matr);
%                 end
%             end
%             
%             if scons  ==  'n'
%                 
%                 spneg = [];
%                 for i = 1:matr
%                     disp(' ')
%                     disp(['S submatrix number ' num2str(i)])
%                     selneg  =  input('Apply non-negativity? (y/n)','s');
%                     if selneg  == 'y'
%                         if ialgs  ==  0
%                             nspneg = input('How many spectra should be positive? ');
%                             if nspneg  ==  nsign
%                                 spneg(:,i)  =  ones(nsign,1);
%                             else
%                                 spneg(:,i) =  input('Enter a vector with the positive spectra (e.g. sp 1 and 3 [1,0,1]) ');
%                             end
%                         else
%                             spneg(:,i)  =  ones(nsign,1);
%                         end
%                     end
%                     if selneg  ==  'n'
%                         spneg(:,i)  =  zeros(nsign,1);
%                     end
%                 end
%             end
        end
        
        if ineg(1) ~= 0
%         if ineg == 1||ineg  == 2
%             
%             disp(' ')
%             disp('SELECTION OF THE NON-NEGATIVITY IMPLEMENTATION FOR CONC PROFILES')
%             disp('Warning: nnls or fnnls algorithms can constrain all or none of the present species.')
%             disp('Constraint of some selected species is only possible with the "forced to zero" option')
%             disp(' ')
%             ialg = input('Enter the selected algorithm for conc (0  =  forced to zero / 1  =  nnls / 2  =  fnnls)  ');
            
%             if ccons == 'y' || nexp  ==  1
%                 
%                 if ialg  ==  0
%                     ncneg = input('How many conc profiles should be positive? ');
%                     if ncneg  ==  nsign
%                         cneg  =  ones(matc,nsign);
%                     else
%                         cnegr =  input('Enter a vector with the positive conc profiles (e.g. conc 1 and 3 [1,0,1]) ');
%                         cneg  =  ones(matc,1)*cnegr;
%                     end
%                 else
                    cneg  =  ones(matc,nsign);
%                 end
%             end
            
%             if ccons  ==  'n'
%                 
%                 cneg = [];
%                 for i = 1:matc
%                     disp(' ')
%                     disp(['C submatrix number ' num2str(i)])
%                     selcneg  =  input('Apply non-negativity? (y/n)','s');
%                     if selcneg  == 'y'
%                         if ialg  ==  0
%                             ncneg = input('How many conc profiles should be positive? ');
%                             if ncneg  ==  nsign
%                                 cneg(i,:)  =  ones(1,nsign);
%                             else
%                                 cneg(i,:) =  input('Enter a vector with the positive conc profiles (e.g. sp 1 and 3 [1,0,1]) ');
%                             end
%                         else
%                             cneg(i,:)  =  ones(1,nsign);
%                         end
%                     end
%                     if selcneg  ==  'n'
%                         cneg(i,:)  =  zeros(1,nsign);
%                     end
%                 end
%             end
        end
    else
        
        cneg = zeros(matc,nsign);
        spneg  =  zeros(nsign,matr);
        ialg  =  99;
        ialgs  =  99;
        
    end
    
    
    % **********************
    % UNIMODALITY CONSTRAINT
    % **********************
    
%     c2  =  find(wcons  ==  2);
%     if ~isempty(c2)
    if any(wcons==2)
%         disp(' ')
%         disp('Unimodality constraint applied to: ')
%         disp('     1 : concentration profiles')
%         disp('     2 : spectra')
%         disp('     3 : concentration profiles and spectra')
%         
%         imod = input('Unimodal conc (1), spec(2), conc and spec (3)? ');
        imod = unimod;
        
        if imod(2) ~= 0
%         if imod == 2 || imod == 3,
            
%             if nexp  ==  1|scons  ==  'y' |scons  ==  'Y'
                
%                 nsmod = input('How many species are constrained to have unimodal spectra? ');
                
                
                if imod(2) == -1;
                    spsmod = ones(1,nsign);
                    spmod  = ones(1,nsign);
                else
                    spsmod  =  [ones(1,imod(2))  zeros(1,nsign-imod(2))];%input('Spectra with unimodal profiles, e.g. [1,0,1,..]? ');
                    spmod   = zeros(1,nsign);
                end
%                 spsmod  =  ones(matr,1)*spsmod;
                
%             end
            
%             if scons  ==  'n' |scons  ==  'N'
%                 spsmod  = [];
%                 for i  = 1:matr
%                     disp(['S matrix, submatrix nr. ' num2str(i)])
%                     nsmod = input('How many species are constrained to have unimodal spectra? ');
%                     
%                     if nsmod == nsign,
%                         spsmod(i,:) = ones(1,nsign);
%                     elseif nsmod  ==  0
%                         spsmod(i,:)  =  zeros(1,nsign);
%                     else
%                         spsmod(i,:) = input('Species with unimodal profiles, e.g. [0,1,..]? ');
%                     end
%                 end
%             end
            
%             smod = input('Unimodal constraint tolerance for the spectra?  ');
%             if smod == 1;smod = 1.0001;end
            smod = 1.0001;
            
        end
        
        if imod(1) ~= 0
%         if imod == 1|imod == 3,
            
%             if nexp == 1 | ccons == 'y' | ccons == 'Y'
%                 nmod = input('How many species are constrained to have unimodal concentration profiles? ');
                
                if imod(1) == -1
                    spmod = ones(1,nsign);
                else
                    spmod = [ones(1,imod(1))  zeros(1,nsign-imod(1))];%input('Species with unimodal profiles, e.g. [0,1,..]? ');
                end
%                 spmod  =  ones(matc,1)*spmod;
%             end
            
%             if ccons == 'n' | ccons == 'N'
%                 spmod = [];
%                 for i  = 1:matc
%                     disp(['Exp. ' num2str(i)])
%                     nmod = input('How many species are constrained to have unimodal concentration profiles? ');
%                     
%                     if nmod == nsign,
%                         spmod(i,:) = ones(1,nsign);
%                     elseif nmod  ==  0
%                         spmod(i,:)  =  zeros(1,nsign);
%                     else
%                         spmod(i,:) = input('Species with unimodal profiles, e.g. [0,1,..]? ');
%                     end
%                 end
%             end
            
%             rmod = input('Unimodal constraint tolerance for the conc?  ');
%             if rmod == 1,rmod = 1.0001;end
            rmod = 1.0001;
        end
        
%         cmod = input('Unimodality implementation: vertical (0), horizontal (1), average (2)? ');
        
    end
    
%     % ******************
%     % CLOSURE CONSTRAINT
%     % ******************
%     
%     c3  =  find(wcons  ==  3);
%     if ~isempty(c3)
%         disp(' ');
%         disp('DIRECTION OF THE CLOSURE')
%         disp('Closure for concentration profiles (1)')
%         disp('Closure for spectra (2)')
%         dc  =  input('Specify closure direction  ');
%         
%         %********************
%         % closure for spectra
%         % *******************
%         
%         if dc  ==  2
%             tclos1(1:matr) = zeros(1,matr);
%             tclos2(1:matr) = zeros(1,matr);
%             sclos1(1:matr,1:nsign) = zeros(matr,nsign);
%             sclos2(1:matr,1:nsign) = zeros(matr,nsign);
%             iclos(1:matr) = zeros(1,matr);
%             iclos1(1:matr) = zeros(1,matr);
%             iclos2(1:matr) = zeros(1,matr);
%             disp('Number of closure constants to be included')
%             disp('          0  =  no closure')
%             disp('		1  =  one closure for the species spectra')
%             disp('		2  =  two closures for species spectra')
%             
%             
%             for i =  1:matr
%                 disp(' ')
%                 disp(['S submatrix nr. ',num2str(i)])
%                 iclos(i) = input('Number of closure constants (0/1/2)? ');
%                 
%                 if iclos(i)  == 2
%                     disp('Warning: there should not be common species to the two closures')
%                 end
%                 
%                 if iclos(i) == 1 | iclos(i) == 2,
%                     if vclos1 == 0,
%                         tclos1(i) = input('(first) closure constant is?  ');
%                         disp('Closure condition')
%                         iclos1(i) = input('Equal condition (1) or "lower or equal than" condition (2)? ');
%                     else
%                         iclos1(i) = 1;
%                     end
%                     sclos1(i,:) = input('which species are in (first) closure [1,0,1,...] ');
%                 end
%                 
%                 if iclos(i) == 2,
%                     if vclos2  == 0,
%                         tclos2(i) = input('(second) closure constant is?  ');
%                         disp('Closure condition')
%                         iclos2(i) = input('Equal condition (1) or "lower or equal than" condition (2)');
%                     else
%                         iclos2(i) = 1;
%                     end
%                     sclos2(i,:) = input('which species are in (second) closure [1,0,1,...] ');
%                 end
%             end
%         end
%         %***************************
%         % closure for concentrations
%         % **************************
%         
%         if dc  ==  1
%             disp('Number of closure constants to be included (select for each experiment)')
%             disp('		0  =  no closure')
%             disp('		1  =  one closure for the species concentrations')
%             disp('		2  =  two closures for species concentrations')
%             
%             tclos1(1:matc) = zeros(1,matc);
%             tclos2(1:matc) = zeros(1,matc);
%             sclos1(1:matc,1:nsign) = zeros(matc,nsign);
%             sclos2(1:matc,1:nsign) = zeros(matc,nsign);
%             iclos(1:matc) = zeros(1,matc);
%             iclos1(1:matc) = zeros(1,matc);
%             iclos2(1:matc) = zeros(1,matc);
%             
%             for i = 1:matc,
%                 disp(' ')
%                 disp(['C submatrix nr. ',num2str(i)]),
%                 iclos(i) = input('Number of closure constants (0/1/2)? ');
%                 
%                 if iclos(i)  == 2
%                     disp('Warning: there should not be common species to the two closures')
%                 end
%                 
%                 if iclos(i) == 1 | iclos(i) == 2,
%                     if vclos1 == 0,
%                         tclos1(i) = input('(first) closure constant is?  ');
%                         disp('Closure condition')
%                         iclos1(i) = input('Equal condition (1) or "lower or equal than" condition (2)? ');
%                     else
%                         iclos1(i) = 1
%                     end
%                     sclos1(i,:) = input('which species are in (first) closure [1,0,1,...] ');
%                 end
%                 if iclos(i) == 2,
%                     if vclos2  == 0,
%                         tclos2(i) = input('(second) closure constant is?  ')
%                         disp('Closure condition')
%                         iclos2(i) = input('Equal condition (1) or "lower or equal than" condition (2)');
%                     else
%                         iclos2(i) = 1;
%                     end
%                     sclos2(i,:) = input('which species are in (second) closure [1,0,1,...] ');
%                 end
%             end
%         end
%         
%     end
    
%     if isempty(c3)
%         
%         disp(' ');disp(' ');disp(' ')
%         disp('NO CLOSURE, NORMALIZATION OF THE S MATRIX (PURE SPECTRA) CAN BE RECOMMENDED:')
%         disp('Types of normalization: 0  =  none'),
%         disp(' 	                      1  =  spectra (rows) equal height')
%         disp(' 			      2  =  spectra (rows) equal length ')
%         inorm = input('normalization 0, 1 or 2?: ');
%         
%     end
    
    % *************************************
    % EQUALITY CONSTRAINTS IN CONC PROFILES
    % *************************************
    
%     cons4  =  find(wcons  ==  4);
    
    % in input matrix csel finite values are known
    
%     if ~isempty(cons4)
%         if isempty(csel),
%             disp(' ');disp(' ');disp(' ')
%             disp('conc equality constraints matrix csel was not input'),
%             return
%         else
%             disp(' ');disp(' ');disp(' ')
%             disp('CONC EQUALITY (known) /LOWER THAN (selectivity) CONSTRAINTS WILL BE APPLIED  ==  == '),
%             type_csel = input('are they equality (0) or lower than (1) constraints? ');
%             iisel = find(finite(csel));
%             conc(iisel) = csel(iisel);
%         end
%     end
    
    
    % *****************************************
    % EQUALITY CONSTRAINTS IN SPECTRA PROFILES
    % *****************************************
    
%     cons5  =  find(wcons  ==  5);
%     
%     % in input matrix ssel finite values are known
%     
%     if ~isempty(cons5)
%         if isempty(ssel)
%             disp(' ');disp(' ');disp(' ')
%             disp('spectra equality constraints matrix ssel was not input'),
%             return
%         else
%             disp(' ');disp(' ');disp(' ')
%             disp('SPECTRA EQUALITY (known) /LOWER THAN (selectivity) CONSTRAINTS WILL BE APPLIED  ==  == '),
%             type_ssel = input('are they equality (0) or lower than (1) constraints? ');
%             jjsel = find(finite(ssel));
%             abss(jjsel) = ssel(jjsel);
%         end
%     end
    
    % **********************
    % SPECIFIC PROFILE SHAPE
    % **********************
    
%     c6  =  find(wcons  ==  6);
%     if ~isempty(c6)
%         disp('Shape constraints are still being implemented')
%     end
    
    % *******************
    % THREE-WAY STRUCTURE
    % *******************
    
%     c7  =  find(wcons  ==  7);
%     if ~isempty(c7) | nexp > 1
%         disp(' ');disp(' ')
%         disp('STRUCTURE OF THREE-WAY DATA SETS')
%         disp('No trilinear (0)')
%         disp('trilinear, equal shape and synchronization (all species) (1)')
%         disp('trilinear without synchronization (all species), (2)')
%         disp('trilinear and synchronization for only some species, (3)')
%         ishape = input('Option selected (0/1/2/3)? ');
%         
%         trildir = 99;
%         spetric = zeros(1,nsign);
%         spetris = zeros(1,nsign);
%         
%         if ishape == 1|ishape == 2|ishape == 3
%             if datamod == 3
%                 disp(' ')
%                 disp('APPLICATION OF THE TRILINEARITY CONSTRAINT')
%                 disp('Application to C matrix (1)')
%                 disp('Application to S matrix (2)')
%                 disp('Application to C and S matrices (3)')
%                 disp(' ')
%                 trildir  = input('Select the mode of application of the trilinearity constraint ');
%             end
%             if datamod == 2
%                 trildir = 2;
%             elseif datamod  == 1
%                 trildir = 1;
%             end
%         end
%         
%         if trildir == 1|trildir == 3
%             if ishape == 1|ishape == 2
%                 spetric = ones(1,nsign);
%             end
%             if ishape == 3
%                 disp('enter the vector of trilinear C profiles [1,0,1,..] 1 = yes , 0 = no ')
%                 spetric(1,1:nsign) = input('');
%             end
%         end
%         
%         if trildir == 2|trildir == 3
%             if ishape == 1|ishape == 2
%                 spetris = ones(1,nsign);
%             end
%             if ishape == 3
%                 disp('enter the vector of trilinear S profiles [1,0,1,..] 1 = yes , 0 = no ')
%                 spetris(1,1:nsign) = input('');
%             end
%         end
%         
%     end
    
    % *************************
    % DISPLAY GRAPHICAL RESULTS
    % *************************
    
%     gr = input('Do you want graphic output during the ALS optimization (y/n)? ','s');
%     if gr == 'Y' | gr  == 'y'
%         gr = 'y';
%     end
%     gr = 'n';
    
    % **************************
    % CHECKING THE INITIAL INPUT
    % **************************
    
%     disp(' ')
%     answer = input('Is all the input information correct (y/n)? ','s');
%     if answer == 'y' | answer  == 'Y',
        answer = 'y';
%     else
%         answer = 'n';
%     end
    
    % This end comes from the initial while
    % *****
end
% *****


% ***********************************************************
% C) REPRODUCTION OF THE ORIGINAL DATA MATRIX BY PCA
% ***********************************************************

% dn is the experimental matrix and d is the PCA reproduced matrix

% disp('******* Results obtained after application of PCA to the data matrix ******');
% disp(' ');
dn = d;
% [u,s,v,d,sd] = pcarep(dn,nsign);
[~,~,~,d] = pcarep(dn,nsign);

% disp(['Data reproduction with the considered number of species has an error ',num2str(sd)]);
% disp(' ');disp(' ');disp(' ');
% figure;
% subplot(2,1,1);plot(u*s);title('Scores matrix')
% subplot(2,1,2);plot(v);title('Loadings matrix')
% 
% disp('****** Press any key to start the ALS optimization ******')
% pause

% clc
sstn = sum(sum(dn.*dn));
sst = sum(sum(d.*d));
sigma2 = sqrt(sstn);

% ************************************************************
% D) STARTING ALTERNATING CONSTRAINED LEAST SQUARES OPTIMIZATION
% ************************************************************

while niter < nit
    
    niter = niter+1;
    
    % ***************************************
    % E) ESTIMATE CONCENTRATIONS (ALS solutions)
    % ***************************************
    
    conc = d/abss;
    
    % ******************************************
    % CONSTRAIN APPROPRIATELY THE CONCENTRATIONS
    % ******************************************
    
    % ****************
    % non-negativity
    % ****************
    
%     if ~isempty(c1)
    if any(wcons == 1)  
        if ineg(1) ~= 0
%         if ineg == 1||ineg == 2
            
            for i  = 1:matc
                
                kinic = nrinic(i);
                kfin = nrfin(i);
                conc2 = conc(kinic:kfin,:);
                
                if ialg == 0
                    for k = 1:nsign,
                        if cneg(i,k)  == 1
                            for j = 1:kfin+1-kinic,
                                if conc2(j,k)<0.0,
                                    conc2(j,k) = 0.0;
                                end
                            end
                        end
                    end
                end
                
                onisp = ones(1,size(isp,2));
                if ialg == 1
                    if cneg(i,:)  ==  onisp;
                        for j = kinic:kfin
                            x = lsqnonneg(abss',d(j,:)');
                            conc2(j,:) = x';
%                             conc2(j-kinic+1,:) = x';
                        end
                    end
                end
                
                if ialg == 2
                    if cneg(i,:)  ==  onisp
                        abssip = abss*abss';
                        abssipd = abss*d';
                        for j = kinic:kfin
                            x = fnnls(abssip,abssipd(:,j));
                            conc2(j,:) = x';
%                             conc2(j-kinic+1,:) = x';
                        end
                    end
                end
                
                conc(kinic:kfin,:)  =  conc2;
            end
        end
    end
    
    % ************
    % trilinearity
    % ************
    
    
%     if ishape>=1
%         if trildir == 1||trildir == 3
%             for j = 1:nsign,
%                 if spetric(j) == 1,
%                     [conc(:,j),t] = trilin(conc(:,j),matc,ishape);
%                     totalconc(j,1:matc) = t;
%                     if totalconc(j,1)>0,
%                         rt(j,1:matc) = totalconc(j,1:matc)./totalconc(j,1); %#ok<AGROW>
%                     else
%                         rt(j,1:matc) = totalconc(j,1:matc); %#ok<AGROW>
%                     end
%                 end
%             end
%         end
%     end
    
    % **************************
    % zero concentration species
    % **************************
    
%     if matc>1
%         for i = 1:matc,
%             for j = 1:nsign,
%                 if isp(i,j) == 0,
%                     conc(nrinic(i):nrfin(i),j) = zeros(nrsol(i),1);
%                 end
%             end
%         end
%     end
    
    
    
    % ***********
    % unimodality
    % ***********
    if any(wcons==2) && sum(imod) == 1
        for i  =  1:matc
            
            kinic = nrinic(i);
            kfin = nrfin(i);
            conc2 = conc(kinic:kfin,:);
            
            %         if imod == 1||imod == 3,
            
            for ii = 1:nsign,
                if spmod(i,ii) == 1,
                    conc2(:,ii) = unimodF(conc2(:,ii),rmod,cmod);
                end
            end
            
            
            conc(kinic:kfin,:) = conc2;
        end
    end
    
    % ****************************
    % EQUALITY CONSTRAINTS IN CONC
    % ****************************
    
%     if ~isempty(cons4)
%         if type_csel == 0,conc(iisel) = csel(iisel);end
%         if type_csel == 1
%             for ii = 1:size(iisel),
%                 if conc(iisel(ii))>csel(iisel(ii)),conc(iisel(ii)) = csel(iisel(ii));end
%             end
%         end
%     end
    
    % ********
    % closure
    % ********
    
%     if ~isempty(c3)
%         
%         if dc  ==  1
%             for i  =  1:matc
%                 
%                 kinic = nrinic(i);
%                 kfin = nrfin(i);
%                 conc2 = conc(kinic:kfin,:);
%                 
%                 if iclos(i) == 1 | iclos(i) == 2,
%                     if tclos1(i)  ==  0
%                         vclos1n = vclos1(kinic:kfin,1);
%                     end
%                     
%                     if iclos(i)  == 2 & tclos2(i) == 0
%                         vclos2n = vclos2(kinic:kfin,1);
%                     end
%                     
%                     [conc2] = closure(conc2,iclos(i),sclos1(i,:),iclos1(i),tclos1(i),tclos2(i),sclos2(i,:),iclos2(i),vclos1n,vclos2n);
%                 end
%                 conc(kinic:kfin,:) = conc2;
%             end
%         end
%     end
    
    
    
    
    
    
    % ******************************
    % DISPLAY CONCENTRATION PROFILES
    % ******************************
    
%     if gr == 'y',
%         subplot(2,1,1);plot(conc);title('Concentration profiles');
%     end
    
    % ************************************************
    % QUANTITATIVE INFORMATION FOR THREE-WAY DATA SETS
    % ************************************************
    
    % recalculation of total and ratio concentrations if ishape = 0 or niter = 1
    
%     if ishape == 0 || niter == 1,
        for j = 1:nsign,
            for inexp = 1:matc,
                totalconc(j,inexp) = sum(conc(nrinic(inexp):nrfin(inexp),j));
            end
            if totalconc(j,1)>0,
                rt(j,1:matc) = totalconc(j,1:matc)./totalconc(j,1); %#ok<AGROW>
            else
                rt(j,1:matc) = totalconc(j,1:matc); %#ok<AGROW>
            end
        end
%     end
    
    % areas under concentration profiles
    area = totalconc;
    
    % ********************************
    % ESTIMATE SPECTRA (ALS solution)
    % ********************************
    
    abss = conc\d;
    
    
    % ********************
    % non-negative spectra
    % ********************
    
    if any(wcons == 1) && ineg(2) ~= 0
%     if ineg  == 2 |ineg == 3,
        
        for i  =  1:matr
            kinic  =  ncinic(i);
            kfin  =  ncfin(i);
            abss2  =  abss(:,kinic:kfin);
            
            if ialgs == 0,
                for k = 1:nsign,
                    if spneg(k,i) == 1
                        for j = 1:kfin+1-kinic,
                            if abss2(k,j)<0.0,
                                abss2(k,j) = 0.0;
                            end
                        end
                    end
                end
            end
            
            onisp = ones(size(isp,2),1);
            if ialgs == 1,
                if spneg(:,i) == onisp
                    for j = kinic:kfin
                        abss2(:,j) = lsqnonneg(conc,d(:,j));
                    end
                end
            end
            
            if ialgs == 2,
                if spneg(:,i) == onisp
                    concip = conc'*conc;
                    concipd = conc'*d;
%                     [abss2(:,i),w] = fnnls(concip,concipd(:,j));
                    for j = kinic:kfin
                        abss2(:,j) = fnnls(concip,concipd(:,j));
%                         abss2(:,j-kinic+1) = fnnls(concip,conc'*d(:,j));
                    end
                end
            end
            abss = abss2;
%             abss(:,kinic:kfin) = abss2;
        end
    end
    
    % ************
    % trilinearity
    % ************
    
    
%     if ishape>=1,
%         if trildir == 2||trildir == 3
%             for j = 1:nsign,
%                 if spetris(j) == 1,
%                     [absst,t] = trilin(abss(j,:)',matr,ishape);
%                     abss(j,:) = absst';
%                 end
%             end
%         end
%     end
    
    
    
    % ************************************
    % constrain the unimodality of spectra
    % ************************************
    
    if any(wcons==2) && imod(2) ~= 0
        for i  =  1:matr
            kinic  =  ncinic(i);
            kfin  =  ncfin(i);
            abss2  =  abss(:,kinic:kfin);
            
            %         if imod == 2|imod == 3,
            for j = 1:nsign,
                if spsmod(i,j) == 1
                    dummy = unimodF(abss2(j,:)',smod,cmod);
                    abss2(j,:) = dummy';
                end
            end
            abss(:,kinic:kfin) = abss2;
        end
    end
    
    % ********************************
    % EQUALITY CONSTRAINTS FOR SPECTRA
    % ********************************
    
%     if ~isempty(cons5)
%         if type_ssel == 0,abss(jjsel) = ssel(jjsel);end
%         if type_ssel == 1
%             for jj = 1:size(jjsel),
%                 if abss(jjsel(jj))>ssel(jjsel(jj)),abss(jjsel(jj)) = ssel(jjsel(jj));end
%             end
%         end
%     end
    
    % *******************************************************
    % closure in spectra (in case of inverted analysis D' = SC)
    % *******************************************************
    
%     if ~isempty(c3)
%         
%         if dc == 2,
%             
%             for i  =  1:matr
%                 kinic  =  ncinic(i);
%                 kfin  =  ncfin(i);
%                 abss2  =  abss(:,kinic:kfin);
%                 
%                 if iclos(i) == 1 | iclos(i) == 2,
%                     if tclos1(i)  ==  0
%                         vclos1n = vclos1(kinic:kfin,1);
%                     end
%                     
%                     if iclos(i)  == 2 & tclos2(i) == 0
%                         vclos2n = vclos2(kinic:kfin,1);
%                     end
%                     
%                     abst  =  closure(abss2',iclos(i),sclos1(i,:),iclos1(i),tclos1(i),tclos2(i),sclos2(i,:),iclos2(i),vclos1n,vclos2n);
%                     abss2 = abst';
%                 end
%                 abss(:,kinic:kfin)  =  abss2;
%             end
%         end
%     end
    
    % ************************
    % NORMALIZATION OF SPECTRA
    % ************************
    
    % equal heighth
    
    if inorm == 1,
        maxabss = max(abss'); %#ok<UDIM>
        for i = 1:nsign,
            abss(i,:) = abss(i,:)./maxabss(i);
        end
    end
    
    % equal length
    
    if inorm == 2, abss = normv2(abss); end
    
    % ********************
    % DISPLAY PURE SPECTRA
    % ********************
    
%     if gr == 'y',
%         subplot(2,1,2);plot(abss');title('Unit spectra');
%         pause(1);
%     end
    
    
    % *******************************
    % CALCULATE RESIDUALS
    % *******************************
    
    res = d-conc*abss;
    resn = dn-conc*abss;
    
    % ********************************
    % OPTIMIZATION RESULTS
    % *********************************
    
%     disp(' ' );disp(' ');disp(['ITERATION ',num2str(niter)]);
    u = sum(sum(res.*res));
    un = sum(sum(resn.*resn));
%     disp(['Sum of squares respect PCA reprod.  =  ', num2str(u)]);
    sigma = sqrt(u/(nrow*ncol));
%     sigman = sqrt(un/(nrow*ncol));
%     disp(['Old sigma  =  ', num2str(sigma2),' -----> New sigma  =  ', num2str(sigma)]);
%     disp(['Sigma respect experimental data  =  ', num2str(sigman)]);
%     disp(' ');
    change = ((sigma2-sigma)/sigma);
    
    if change < 0.0,
%         disp(' ')
%         disp('FITING IS NOT IMPROVING  == !')
        idev = idev+1;
    else
%         disp('FITING IS IMPROVING  == !')
        idev = 0;
    end
    
    change = change*100;
%     disp(['Change in sigma (%)  =  ', num2str(change)]);
    sstd(1) = sqrt(u/sst)*100;
    sstd(2) = sqrt(un/sstn)*100;
%     disp(['Fitting error (lack of fit, lof) in % (PCA)  =  ', num2str(sstd(1))]);
%     disp(['Fitting error (lack of fit, lof) in % (exp)  =  ', num2str(sstd(2))]);
%     r2 = (sstn-un)/sstn;
%     disp(['Percent of variance explained (r2) is ',num2str(100*r2)]);
    
    % *************************************************************
    % If change is positive, the optimization is working correctly
    % *************************************************************
    
    if change>0 || niter == 1,
        
        sigma2 = sigma;
        copt = conc;
        sopt = abss;
        sdopt = sstd;
        ropt = res;
        rtopt = rt';
%         itopt = niter;
        areaopt = area;
%         r2opt = r2;
    end
    
    % ******************************************************************
    % test for convergence within maximum number of iterations allowed
    % ******************************************************************
    
    if abs(change) < tolsigma,
        
        %  finish the iterative optimization because convergence is achieved
        
%         disp(' ');disp(' ');
%         disp('CONVERGENCE IS ACHIEVED  ==  == ')
%         disp(' ')
%         disp(['Fitting error (lack of fit, lof) in % at the optimum  =  ', num2str(sdopt(1,1)),'(PCA) ', num2str(sdopt(1,2)), '(exp)']);
%         disp(['Percent of variance explained (r2)at the optimum is ',num2str(100*r2opt)]);
%         disp('Relative species conc. areas respect matrix (sample) 1at the optimum'),disp(rtopt')
%         disp(['Plots are at optimum in the iteration ', num2str(itopt)]);
%         subplot(2,1,1);plot(copt);title('conc profile in optimal iteration');
%         subplot(2,1,2);plot(sopt');title('pure spectra in optimal iteration');
        convergence = 1;
        return         % 1st return (end of the optimization, convergence)
    end
    
    %  finish the iterative optimization if divergence occurs 20 times consecutively
    
    if idev > 20,
%         disp(' ');disp(' ');
%         disp('FIT NOT IMPROVING FOR 20 TMES CONSECUTIVELY (DIVERGENCE?), STOP == !')
%         disp(' ')
%         disp(['Fitting error (lack of fit, lof) in % at the optimum  =  ', num2str(sdopt(1,1)),'(PCA) ', num2str(sdopt(1,2)), '(exp)']);
%         disp(['Percent of variance explained (r2)at the optimum is ',num2str(100*r2opt)]);
%         disp('Relative species conc. areas respect matrix (sample) 1 at the optimum'),disp(rtopt)
%         disp(['Plots are at optimum in the iteration ', num2str(itopt)]);
%         subplot(2,1,1);plot(copt);title('conc profile in optimal iteration');
%         subplot(2,1,2);plot(sopt');title('pure spectra in optimal iteration');
        convergence = -1;
        return          % 2nd return (end of optimization, divergence)
        
    end
    
    % this end refers to number of iterations initially proposed exceeded
    
end

% finish the iterative optimization if maximum number of allowed iterations is exceeded

% disp(' ');disp(' ');
% disp('NUMBER OF ITERATIONS EXCEEDED THE ALLOWED!')
% disp(' ')
% disp(['Fitting error (lack of fit, lof) in % at the optimum  =  ', num2str(sdopt(1,1)),'(PCA) ', num2str(sdopt(1,2)), '(exp)']);
% disp(['Percent of variance explained (r2)at the optimum is ',num2str(100*r2opt)]);
% disp('Relative species conc. areas respect matrix (sample) 1 at the optimum'),disp(rtopt)
% disp(['Plots are at optimum in the iteration ', num2str(itopt)]);
% subplot(2,1,1);plot(copt);title('conc profile in optimal iteration');
% subplot(2,1,2);plot(sopt');title('pure spectra in optimal iteration');
% return          % 3rd return (end of optimization, number of iterations exceeded)
convergence = 0;


%% PCAREP
function [u,s,v,x,sigma]=pcarep(xi,nf)
% function [u,s,v,x,sigma]=pcarep(xi,nf)
% PCA reproduction of the original data matrix x dor nf components
% u,s,v and x as in svd matlab function [u,s,v]=svd(x)
% xi is the original input data matrix (with noise)
% x is the pca reproduced data matrix (filtered no noise)
% nf is the number of components to be included in the reproduction

% t0=cputime;

[u,s,v]=svd(xi,0);
u=u(:,1:nf);
s=s(1:nf,1:nf);
v=v(:,1:nf);
x=u*s*v';
res=xi-x;
sst1=sum(sum(res.*res));
sst2=sum(sum(xi.*xi));
sigma=(sqrt(sst1/sst2))*100;


%% Normv2
function [s]=normv2(s)
% normalitzacio s=s/sqrt(sum(si)2))
[m,~] = size(s);
for i=1:m,
    sr = sqrt(sum(s(i,:).*s(i,:)));
    s(i,:) = s(i,:)./sr;
end

%% FNNLS
function [x,w] = fnnls(XtX,Xty,tol)
%FNNLS	Non-negative least-squares.
%
% 	Adapted from NNLS of Mathworks, Inc.
%
%	x = fnnls(XtX,Xty) returns the vector X that solves x = pinv(XtX)*Xty
%	in a least squares sense, subject to x >= 0.
%	Differently stated it solves the problem min ||y - Xx|| if
%	XtX = X'*X and Xty = X'*y.
%
%	A default tolerance of TOL = MAX(SIZE(XtX)) * NORM(XtX,1) * EPS
%	is used for deciding when elements of x are less than zero.
%	This can be overridden with x = fnnls(XtX,Xty,TOL).
%
%	[x,w] = fnnls(XtX,Xty) also returns dual vector w where
%	w(i) < 0 where x(i) = 0 and w(i) = 0 where x(i) > 0.
%
%	See also NNLS and FNNLSb

%	L. Shure 5-8-87
%	Revised, 12-15-88,8-31-89 LS.
%	(Partly) Copyright (c) 1984-94 by The MathWorks, Inc.

%	Modified by R. Bro 5-7-96 according to
%       Bro R., de Jong S., Journal of Chemometrics, 1997, xx
% 	Corresponds to the FNNLSa algorithm in the paper
%
%	
%	Rasmus bro
%	Chemometrics Group, Food Technology
%	Dept. Dairy and Food Science
%	Royal Vet. & Agricultural
%	DK-1958 Frederiksberg C
%	Denmark
%	rb@kvl.dk
%	http://newton.foodsci.kvl.dk/rasmus.html


%  Reference:
%  Lawson and Hanson, "Solving Least Squares Problems", Prentice-Hall, 1974.

% initialize variables
if nargin < 3
    tol = 10*eps*norm(XtX,1)*max(size(XtX));
end
[~,n] = size(XtX);


P = zeros(1,n);
Z = 1:n;
x = P';
ZZ=Z;
w = Xty;%-XtX*x;
Xtyt = Xty';

% set up iteration criterion
iter = 0;
itmax = 30*n;
zz = zeros(n,1);

% outer loop to put variables into set to hold positive coefficients
while any(Z) && any(w(ZZ) > tol)
    [~,t] = max(w(ZZ));
    t = ZZ(t);
    P(1,t) = t;
    Z(t) = 0;
    PP = find(P);
    z = zz;
    z(PP) = (Xtyt(PP)/XtX(PP,PP));

    % inner loop to remove elements from the positive set which no longer belong
    while any((z(PP) <= tol)) && iter < itmax

        iter = iter + 1;
        QQ = find((z <= tol) & P');
        alpha = min(x(QQ)./(x(QQ) - z(QQ)));
        x = x + alpha*(z - x);
        ij = find(abs(x) < tol & P' ~= 0);
        Z(ij)=ij';
        P(ij)=zeros(1,max(size(ij)));
        PP = find(P);
        z = zz;
        z(PP)=(Xtyt(PP)/XtX(PP,PP));
    end
    ZZ = find(Z);
    x = z;
    w = Xty-XtX*x;
end


%% Unimodality
function [conc] = unimodF(conc,rmod,cmod)

[ns,nc]=size(conc);

% 1) look for the maximum

imax = zeros(1,nc);
for j=1:nc,
    [~,imax(j)] = max(conc(:,j));
end

% 2) force unimodality shape

for j=1:nc,
    
    rmax=conc(imax(j),j);
    k=imax(j);
    % disp('maximum at point');disp(k)
    
    % 2a) discard left maxima (tolerance rmod)
    
    while k>1,
        k=k-1;
        
        if conc(k,j)<=rmax,
            rmax=conc(k,j);
        else
            rmax2=rmax*rmod;
            if conc(k,j)>rmax2,
                
                % disp('no left unimodality in point: ');disp(k);
                % pause
                
                if cmod==0,conc(k,j)=1.0E-30;end
                if cmod==1,conc(k,j)=conc(k+1,j);end
                if cmod==2,
                    if rmax>0,
                        conc(k,j)=(conc(k,j)+conc(k+1,j))/2;
                        conc(k+1,j)=conc(k,j);
                        k=k+2;
                    else
                        conc(k,j)=0;
                    end
                end
                
                rmax=conc(k,j);
                
            end
            
        end
        
    end
    
    % 2b) discard right maxima (tolerance rmod)
    
    rmax=conc(imax(j),j);
    k=imax(j);
    
    while k<ns,
        k=k+1;
        
        if conc(k,j)<=rmax,
            rmax=conc(k,j);
        else
            rmax2=rmax*rmod;
            if conc(k,j)>rmax2,
                if cmod==0,conc(k,j)=1.0E-30;end
                if cmod==1,conc(k,j)=conc(k-1,j);end
                if cmod==2,
                    % disp('no right unimodality in point: ');
                    % disp([k,conc(k,j),rmax])
                    % disp('rmax= ');disp(rmax);
                    % pause
                    if rmax>0,
                        conc(k,j)=(conc(k,j)+conc(k-1,j))/2;
                        conc(k-1,j)=conc(k,j);
                        k=k-2;
                    else
                        conc(k,j)=0;
                    end
                end
                rmax=conc(k,j);
            end
        end
        
    end
    
end
