function H = hyspec_merge(I1, I2,varargin)
%% Merge objects into imageobject with metainformation
% H = hyspec_object(I1, I2); % Creates a default image object
%
% I1 - array: rows x columns x spectrum (x images), or
%      hyspec object
%    image(s)
% I2 - array: rows x columns x spectrum (x images), or
%      hyspec object
%    image(s)
%
% --= Optional arguments =-- (Vectors are reused, cell arrays are not)
% i1 - char matrix
%    image name(s)
% i2 - char matrix
%    image name(s)
% v1 - vector
%    values of abscissas (wavelengths, wavenumbers, shifts, ...)
% v2 - vector
%    values of abscissas (wavelengths, wavenumbers, shifts, ...)
% x1 - vector
%    values of x coordinates
% x2 - vector
%    values of x coordinates
% y1 - vector
%    values of y coordinates
% y2 - vector
%    values of y coordinates
% mask1 - matrix
%    image mask for subsetting
% mask2 - matrix
%    image mask for subsetting

% Number of images
if iscell(I1) % I is cell
    n1 = length(I1);
    p = size(I1{1},3);
else
    n1 = size(I1,4);
    p = size(I1,3);
end
if iscell(I2) % I is cell
    n2 = length(I2);
    p2 = size(I2{1},3);
else
    n2 = size(I2,4);
    p2 = size(I2,3);
end
if p ~= p2
    error('Images must have the same abcissas')
end

% Extra arguments and defaults
names = {'i1' 'v1'  'x1'  'y1' 'mask1' 'i2' 'v2'  'x2'  'y2' 'mask2'};
dflts = { ''   1:p    []    []     []    ''   1:p    []    []     []};
[i1, v1, x1, y1, mask1, i2, v2, x2, y2, mask2] = match_arguments(names,dflts,varargin{:});

% Possibly convert to image object(s)
if ~isstruct(I1)
    I = I1;
    i = i1;
    v = v1;
    x = x1;
    y = y1;
    mask = mask1;
else
    I = I1.d;
    i = I1.i;
    v = I1.v;
    x = I1.x;
    y = I1.y;
    mask = I1.mask;
end
if ~isstruct(I2)
    I = {I I2};
    i = {i i2};
    v = {v v2};
    x = {x x2};
    y = {y y2};
    mask = {mask mask2};
else
    I = {I I2.d};
    i = {i I2.i};
    v = {v I2.v};
    x = {x I2.x};
    y = {y I2.y};
    mask = {mask I2.mask};
end
n = (n1+n2);

% Initialize with defaults
for j = 1:n
    if iscell(I) % I is cell
        H(j) = hyspec_object_default(I{j}); %#ok<*AGROW>
    else
        H(j) = hyspec_object_default(I(:,:,:,j));
    end
    
    % Image name
    if iscell(i) % Add name directly
        H(j).i = i{j};
    elseif isempty(i) % Default name + number
        H(j).i = ['Image ' num2str(j)];
    else % Common base + number
        H(j).i = [i ' ' num2str(j)];
    end
    
    % Abscissas
    if iscell(v)
        H(j).v = v{j};
    else
        H(j).v = v;
    end
    
    % X labels
    if ~isempty(x)
        if iscell(x)
            H(j).x = x{j};
        else
            H(j).x = x;
        end
    end
    
    % Y labels
    if ~isempty(y)
        if iscell(y)
            H(j).y = y{j};
        else
            H(j).y = y;
        end
    end
    
    % Mask(s)
    if ~isempty(mask)
        if iscell(mask)
            H(j).mask = mask{j};
        else
            H(j).mask = mask;
        end
    end
end


%% Initial hyspec_object
function H = hyspec_object_default(I)
[r,c,~] = size(I);

x = 1:r;
y = 1:c;

% Create struct
H = struct('d',I, ...    % image
    'i','', ...          % names
    'v',[], ...          % abscissa values
    'x',x, ...           % x coordinate values
    'y',y, ...           % y coordinate values
    'mask',[]);          % image masks
