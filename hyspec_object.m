function H = hyspec_object(I,varargin)
%% Image object with metainformation
% H = hyspec_object(I); % Creates a default image object
%
% I - array: rows x columns x spectrum (x images)
%    image(s)
%
% --= Optional arguments =-- (Vectors are reused, cell arrays are not)
% i - char matrix
%    image name(s)
% v - vector
%    values of abscissas (wavelengths, wavenumbers, shifts, ...)
% x - vector
%    values of x coordinates
% y - vector
%    values of y coordinates
% mask - matrix
%    image mask for subsetting

% Number of images
if iscell(I) % I is cell
    n = length(I);
    p = size(I{1},3);
else
    n = size(I,4);
    p = size(I,3);
end


% Extra arguments and defaults
names = {'i' 'v'  'x'  'y' 'mask'};
dflts = { '' 1:p   []   []     []};
[i, v, x, y, mask] = match_arguments(names,dflts,varargin{:});

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
