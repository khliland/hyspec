function varargout = hyspec_select(varargin)
% HYSPEC_SELECT MATLAB code for hyspec_select.fig
%      HYSPEC_SELECT, by itself, creates a new HYSPEC_SELECT or raises the existing
%      singleton*.
%
%      H = HYSPEC_SELECT returns the handle to a new HYSPEC_SELECT or the handle to
%      the existing singleton*.
%
%      HYSPEC_SELECT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HYSPEC_SELECT.M with the given input arguments.
%
%      HYSPEC_SELECT('Property','Value',...) creates a new HYSPEC_SELECT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hyspec_select_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hyspec_select_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help hyspec_select

% Last Modified by GUIDE v2.5 01-Jul-2014 20:20:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hyspec_select_OpeningFcn, ...
                   'gui_OutputFcn',  @hyspec_select_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before hyspec_select is made visible.
function hyspec_select_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hyspec_select (see VARARGIN)

% Choose default command line output for hyspec_select
global options

handles.output = hObject;
I = varargin{1};
if isstruct(I)
    handles.dataset = I.d;
else
    handles.dataset = I;
end
if length(varargin) > 1
    handles.xlabs = varargin{2};
else
    if isstruct(I)
        handles.xlabs = I.v;
    else
        handles.xlabs = 1:size(handles.dataset,3);
    end
end
handles.meanSpectra = hyspec_mean(handles.dataset);
handles.selectedSpectra = cell(0,0);
handles.segmented = [];
handles.quantiles = [];
handles.selectedNames = cell(0,0);
options.doSegment = false;
options.colormap  = 'gray';
options.chanelPC  = 1;
options.chanelPC2 = 0;
options.scores    = [];
options.loadings  = [];
options.clip      = false;
options.plotQuant = false;
options.selectedSet = [];
options.polys = cell(0,0);
options.interpolate = 0;
options.imMinMax = [];
handles.whichSpectra = cell(0,0);
tmp = num2str(handles.xlabs(:));
% tmp = num2str((1:length(handles.xlabs))');
if size(tmp,2) < 4
    tmp = [tmp repmat(' ',size(tmp,1), 4-size(tmp,2))];
end
if size(tmp) > 4
    tmp = [tmp; [['PC 1';'PC 2';'PC 3';'PC 4';'PC 5'] repmat(' ', 3, size(tmp,2)-4)]];
else
    tmp = [tmp; ['PC 1';'PC 2';'PC 3';'PC 4';'PC 5']];
end
set(handles.popupmenu2,'String',tmp)
% options.selection = 0;
set(handles.popupmenu4,'String',[repmat(' ', 1, size(tmp,2)); tmp])
% options.selection2 = 0;
options.reverseColor = 0;
plotImage(handles, true)
plotPreview(handles)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hyspec_select wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hyspec_select_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.meanSpectra(2:end,:);
varargout{2} = handles.selectedSpectra;
varargout{3} = [handles.selectedNames;handles.whichSpectra];
if nargout > 3 && size(handles.meanSpectra,1) > 2
    varargout{4} = hyspec_segment(handles.dataset, handles.meanSpectra(2:end,:));
else
    varargout{4} = [];
end
delete(hObject);


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global options
tmp = get(hObject,'Value');
if tmp > size(handles.xlabs,2)
    options.chanelPC = size(handles.xlabs,2)-tmp;
else
    options.chanelPC = tmp;
end
options.imMinMax = [];
guidata(hObject, handles);
plotImage(handles)
plotPreview(handles)


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
global options
contents = cellstr(get(hObject,'String'));
options.colormap = contents{get(hObject,'Value')};
guidata(hObject, handles);
plotImage(handles)

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.pushbutton5,'Enable','off')
set(handles.pushbutton2,'Enable','off')
set(handles.pushbutton3,'Enable','off')
set(handles.pushbutton6,'Enable','off')
global options
axes(handles.axes1)
plotImage(handles)
axes(handles.axes1)
imp = impoly(gca);
if ~isempty(imp)
    pos = getPosition(imp);
    options.polys{length(options.polys)+1} = pos;
    px = size(handles.dataset);
    spectra = reshape(handles.dataset,[px(1)*px(2),px(3)]);
    mask    = createMask(imp);
    [w1,w2] = ind2sub(size(mask),find(mask));
    spectra = spectra(mask,:);
    handles.meanSpectra = [handles.meanSpectra; mean(spectra)];
    handles.selectedSpectra{1,size(handles.selectedSpectra,2)+1} = spectra;
    handles.selectedNames{1,size(handles.selectedNames,2)+1} = [];
    % Tabell-lagring og sletting
    data = get(handles.uitable1,'Data');
    n_sel = size(data,1);
    if n_sel == 0
        set(handles.uitable1,'Data',{1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)})
        handles.whichSpectra = {ind2sub([px(1),px(2)],find(mask))};
    else
        last = max(cell2mat(data(:,1)));
        set(handles.uitable1,'Data',[data;{last+1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)}])
        handles.whichSpectra{1,length(handles.whichSpectra)+1} = ind2sub([px(1),px(2)],find(mask));
    end
    delete(imp)
    plotImage(handles)
    plotPreview(handles)
end
set(handles.pushbutton5,'Enable','on')
set(handles.pushbutton2,'Enable','on')
set(handles.pushbutton3,'Enable','on')
if size(handles.meanSpectra,1) > 2
    set(handles.pushbutton6,'Enable','on')
end
guidata(hObject, handles);
uiwait(handles.figure1);


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global options
if ~isempty(options.selectedSet)
    i = options.selectedSet;
    handles.meanSpectra(i+1,:) = [];
    handles.selectedSpectra = handles.selectedSpectra(setdiff(1:length(handles.selectedSpectra),i));
    handles.selectedNames   = handles.selectedNames(setdiff(1:length(handles.selectedNames),i));
    handles.whichSpectra    = handles.whichSpectra(setdiff(1:length(handles.whichSpectra),i));
    options.selectedSet = [];
    options.polys = options.polys(setdiff(1:length(options.polys),i));
    data = get(handles.uitable1,'Data');
    set(handles.uitable1,'Data',data(setdiff(1:size(data,1),i),:))
    guidata(hObject, handles);
    plotImage(handles)
    plotPreview(handles)
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close

% Plot image
function plotImage(handles, reset)
global options
axes(handles.axes1)

wi = get(handles.edit3,'String');
if isempty(wi) || strcmp(wi,'')
    wi = 0;
else
    wi = str2num(wi);
end
if nargin == 1 % Keep zoom
    xL = get(gca,'XLim');
    yL = get(gca,'YLim');
end
if options.doSegment
    im = handles.segmented;
else
    if options.chanelPC > 0
        ch = options.chanelPC;
        ch = ch + (-wi:1:wi);
        ch(ch<1) = []; ch(ch>length(handles.xlabs)) = [];
        im = mean(handles.dataset(:,:,ch),3);
    else
        if isempty(options.scores) || size(options.scores,3) < -options.chanelPC
            [options.loadings,options.scores] = hyspec_pca(handles.dataset,'ncomp',-options.chanelPC);
        end
        im = options.scores(:,:,-options.chanelPC);
    end
    if options.chanelPC2 > 0 && options.chanelPC2 ~= options.chanelPC
        ch = options.chanelPC2;
        ch = ch + (-wi:1:wi);
        ch(ch<1) = []; ch(ch>length(handles.xlabs)) = [];
        im = im./mean(handles.dataset(:,:,ch),3);
    elseif options.chanelPC2 < 0 && options.chanelPC2 ~= options.chanelPC
        if isempty(options.scores) || size(options.scores,3) < -options.chanelPC2
            [options.loadings,options.scores] = hyspec_pca(handles.dataset,'ncomp',-options.chanelPC2);
        end
        im = im./options.scores(:,:,-options.chanelPC2);
    end
end
if options.reverseColor == 1
    im = -im;
end
if options.interpolate > 0
    [r,c,~] = size(handles.dataset);
    [X,Y] = meshgrid(1:r,1:c);
    [Xi,Yi] = meshgrid(1:(1/options.interpolate):r,1:(1/options.interpolate):c);
    im = interp2(Y',X',im,Yi',Xi');
end
hold off
cla
colormap(options.colormap);
if options.clip == true
    mm = quantile(im(:),[0.01,0.99]);
    options.imMinMax = mm;
    options.clip = false;
elseif isempty(options.imMinMax)
    mm = [min(im(:)) max(im(:))];
    options.imMinMax = mm;
else
    mm = options.imMinMax;
end
if mm(1)==mm(2) % Handle "flat" images
    mm(1) = mm(1)-eps;
end
imagesc(im,mm)
hold on
for i=1:length(options.polys)
    pos = options.polys{i};
    patch(pos(:,1),pos(:,2), zeros(size(pos,1),1), 'FaceColor','none')
    patch(pos(:,1),pos(:,2), zeros(size(pos,1),1), 'FaceColor','none','EdgeColor',[1 1 1],'LineStyle',':')
end
% set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_zoom,handles})
% set(gca,'ButtonDownFcn', {@mouseclick_zoom,handles})

if nargin == 1
    xlim(xL)
    ylim(yL)
else
    zoom reset
end
axes(handles.axes3)
hold off
hist(im(:),100)
axis tight
hold on
yl = get(gca,'YLim');
plot(mm(1)*ones(1,2),yl,':k')
plot(mm(2)*ones(1,2),yl,':r')
set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_callback2,handles})
set(gca,'ButtonDownFcn', {@mouseclick_callback2,handles})

set(handles.edit1,'String',mm(1))
set(handles.edit2,'String',mm(2))

% Mouse click handler for histogram
function mouseclick_callback2(hObject, event_obj, handles)
global options
pos = [];
sel = [];
switch get(gcf,'SelectionType')
    case 'normal' % Click left mouse button.
        sel = 1;
    case 'alt'    % Control - click left mouse button or click right mouse button.
        sel = 2;
    case 'open'   % Double-click any mouse button.
        sel = 3;
end
while isempty(pos)
    try
        pos = get(hObject,'Currentpoint');
    catch e
    end
    hObject = get(hObject,'Parent');
end
if sel == 1
    if pos(1) < options.imMinMax(2)
        options.imMinMax(1) = pos(1);
        set(handles.edit1,'String',pos(1))
    end
elseif sel == 2
    if pos(2) > options.imMinMax(1)
        options.imMinMax(2) = pos(1);
        set(handles.edit2,'String',pos(1))
    end
elseif sel == 3
    options.imMinMax = [];
end
plotImage(handles)
    


% Plot preview of spectra
function plotPreview(handles)
global options
axes(handles.axes2)
hold off
if options.chanelPC > 0 && options.chanelPC2 > 0
    plot(handles.xlabs, handles.meanSpectra')
else
    ol1 = []; ol2 = [];
    if options.chanelPC < 0
        ol1 = options.loadings(:,-options.chanelPC);
        ol1 = ol1./norm(ol1).*norm(handles.meanSpectra(1,:));
    end
    if options.chanelPC2 < 0
        ol2 = options.loadings(:,-options.chanelPC2);
        ol2 = ol2./norm(ol2).*norm(handles.meanSpectra(1,:));
    end
    plot(handles.xlabs, [handles.meanSpectra' ol1 ol2])
end
hold on
axis tight
wi   = str2num(get(handles.edit3,'String'));
data = get(handles.uitable1,'Data');
tmp  = 'legend(''Image''';
for i=1:(size(handles.meanSpectra,1)-1)
    if isempty(data{i,2})
        tmp = [tmp ',''Select. ' num2str(data{i,1}) ''''];
    else
        tmp = [tmp ',''' data{i,2} ''''];
    end
end
if options.plotQuant == true
    nq = size(handles.quantiles,1);
    p = length(handles.xlabs);
    for j=1:ceil(nq/2)
        patch([handles.xlabs, handles.xlabs(p:-1:1)], ...
            [handles.quantiles(j,:), handles.quantiles(end+1-j,(p:-1:1))], ...
            ones(1,p+p)*-1,'k','EdgeColor','none')
        alpha(0.05)
    end
end
axis tight
if options.chanelPC > 0
    plot((handles.xlabs(options.chanelPC)-wi)*ones(1,2), get(gca,'YLim'),':k')
    plot((handles.xlabs(options.chanelPC)+wi)*ones(1,2), get(gca,'YLim'),':k')
else
    tmp = [tmp ', ''PC ' num2str(-options.chanelPC) ''''];
end
if options.chanelPC2 > 0
    plot((handles.xlabs(options.chanelPC2)-wi)*ones(1,2), get(gca,'YLim'),':r')
    plot((handles.xlabs(options.chanelPC2)+wi)*ones(1,2), get(gca,'YLim'),':r')
elseif options.chanelPC2 < 0
    tmp = [tmp ', ''PC ' num2str(-options.chanelPC2) ''''];
end
if handles.xlabs(1)>handles.xlabs(end)
    set(gca,'XDir','rev')
end
set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_callback,handles})
set(gca,'ButtonDownFcn', {@mouseclick_callback,handles})
tmp = [tmp ');'];
eval(tmp)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, call UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
global options
options.reverseColor = get(hObject,'Value');
options.imMinMax = [];
guidata(hObject, handles);
plotImage(handles)


% Find mouse click
function mouseclick_callback(hObject, event_obj, handles)
global options
pos = [];
sel = [];
switch get(gcf,'SelectionType')
    case 'normal' % Click left mouse button.
        sel = 1;
    case 'alt'    % Control - click left mouse button or click right mouse button.
        sel = 2;
    case 'open'   % Double-click any mouse button.
        sel = 3;
end
while isempty(pos)
    try
        pos = round(get(hObject,'Currentpoint'));
    catch e
    end
    hObject = get(hObject,'Parent');
end
[~,i] = min((handles.xlabs-pos(1)).^2);
if sel == 1
    options.chanelPC = i;
    set(handles.popupmenu2,'Value',options.chanelPC);
    uicontrol(handles.popupmenu2)
elseif sel == 2
    options.chanelPC2 = i;
    set(handles.popupmenu4,'Value',options.chanelPC2+1);
    uicontrol(handles.popupmenu4)
elseif sel == 3
    options.chanelPC = 1;
    set(handles.popupmenu2,'Value',options.chanelPC);
    options.chanelPC2 = 0;
    set(handles.popupmenu4,'Value',options.chanelPC2+1);
end
guidata(hObject, handles);
options.imMinMax = [];
plotImage(handles)
plotPreview(handles)


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
global options
options.selectedSet = eventdata.Indices(:,1);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushbutton5
if get(handles.pushbutton5,'Value') == 1
    zoom on
    set(handles.pushbutton2,'Enable','off')
    set(handles.pushbutton6,'Enable','off')
    set(handles.popupmenu5,'Enable','off')
else
    zoom off
    set(handles.pushbutton2,'Enable','on')
    set(handles.pushbutton6,'Enable','on')
    set(handles.popupmenu5,'Enable','on')
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
global options
tmp = get(hObject,'Value');
if tmp-1 > size(handles.xlabs,2)
    options.chanelPC2 = size(handles.xlabs,2)-tmp+1;
else
    options.chanelPC2 = tmp-1;
end
options.imMinMax = [];
guidata(hObject, handles);
plotImage(handles)
plotPreview(handles)


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global options
if get(handles.pushbutton6,'Value') == 1
    set(handles.pushbutton2,'Enable','off')
    set(handles.pushbutton3,'Enable','off')
    set(handles.popupmenu2,'Enable','off')
    set(handles.popupmenu4,'Enable','off')
    handles.segmented = hyspec_segment(handles.dataset, handles.meanSpectra(2:end,:));
    options.doSegment = true;
    options.imMinMax  = [];
    guidata(hObject, handles);
    plotImage(handles)
else
    set(handles.pushbutton2,'Enable','on')
    set(handles.pushbutton3,'Enable','on')
    set(handles.popupmenu2,'Enable','on')
    set(handles.popupmenu4,'Enable','on')
    options.doSegment = false;
    options.imMinMax  = [];
    guidata(hObject, handles);
    plotImage(handles)
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global options
axes(handles.axes1)
xL = get(gca,'XLim');
yL = get(gca,'YLim');

if options.doSegment
    im = handles.segmented;
else
    if options.chanelPC > 0
        im = handles.dataset(:,:,options.chanelPC);
    else
        if isempty(options.scores) || size(options.scores,3) < -options.chanelPC
            [options.loadings,options.scores] = hyspec_pca(handles.dataset,'ncomp',-options.chanelPC);
        end
        im = options.scores(:,:,-options.chanelPC);
    end
    if options.chanelPC2 > 0 && options.chanelPC2 ~= options.chanelPC
        im = im./handles.dataset(:,:,options.chanelPC2);
    elseif options.chanelPC2 < 0 && options.chanelPC2 ~= options.chanelPC
        if isempty(options.scores) || size(options.scores,3) < -options.chanelPC2
            [options.loadings,options.scores] = hyspec_pca(handles.dataset,'ncomp',-options.chanelPC2);
        end
        im = im./options.scores(:,:,-options.chanelPC2);
    end
end
if options.reverseColor == 1
    im = -im;
end
if options.interpolate > 0
    [r,c,~] = size(handles.dataset);
    [X,Y] = meshgrid(1:r,1:c);
    [Xi,Yi] = meshgrid(1:(1/options.interpolate):r,1:(1/options.interpolate):c);
    im = interp2(Y',X',im,Yi',Xi');
end
im = im(ceil(yL(1)):floor(yL(2)),ceil(xL(1)):floor(xL(2)));
im = grayslice(im, linspace(min(min(im)), max(max(im)), 255));
map = eval([options.colormap, '(255)']);
[file,path,~] = uiputfile({'*.png','Portable Network Graphics (*.png)';
    '*.jpg','Joint Photographic Experts (*.jpg)';
    '*.tif','Tagged Image File Format (*.tif)'}, ...
    'Save corrected spectra','*.png');
if file ~= 0
    imwrite(im, map, [path file])
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu5 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu5
global options
options.interpolate = 2^(get(hObject,'Value')-1);
plotImage(handles,true)


% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in uipanel4.
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel4 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
if get(handles.radiobutton1,'Value') == 1
    set(handles.axes1,'Position', [40 40 500 500])
elseif  get(handles.radiobutton3,'Value') == 1
    set(handles.axes1,'Position', [40+75 40+75 350 350])
else
    set(handles.axes1,'Position', [40+150 40+150 200 200])
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when entered data in editable cell(s) in uitable1.
function uitable1_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global options
data = get(handles.uitable1,'Data');
handles.selectedNames{1,options.selectedSet} = data{options.selectedSet,2};
guidata(hObject, handles);
plotPreview(handles)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on edit3 and none of its controls.
function edit3_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global options
ch = get(handles.figure1,'CurrentCharacter');
if ~isempty(ch)
    if ch == 28 || ch == 31
        set(handles.edit3,'String',max(str2num(get(handles.edit3,'String'))-1,0));
    elseif ch == 30 || ch == 29
        set(handles.edit3,'String',str2num(get(handles.edit3,'String'))+1);
    end
    if ch == 13 || (ch >= 28 && ch <= 31)
        options.imMinMax = [];
        drawnow
        plotPreview(handles)
        plotImage(handles)
    end
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global options
options.clip = true;
plotPreview(handles)
plotImage(handles)


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
global options
if get(handles.checkbox2,'Value') == 1
    if isempty(handles.quantiles)
        handles.quantiles = hyspec_quantile(handles.dataset,'quant',[0.01 0.05 0.1 0.5 0.9 0.95 0.99]);
    end
    options.plotQuant = true;
else
    options.plotQuant = false;
end
guidata(hObject, handles);
plotPreview(handles)
