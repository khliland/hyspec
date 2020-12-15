function hyspec()

% Properties
handles.BGColor = [0.90 0.90 0.90];
handles.FGColor = [0,0,0];
handles.ShColor = [0.3,0.3,0.3];
handles.HiColor = [0.5,0.5,0.5];
global currentDataset options
currentDataset = [];
options.path  = cd;
options.openType = 1;
options.imNo  = 1;
options.size  = [];
options.wave1 = 1;
options.wave2 = 0;
options.clip  = false;
options.polys = [];
options.imMinMax  = [];
options.waveWidth = 0;
options.colormap  = 'gray';
options.reverse   = false;
options.scores    = [];    % Lagre utregnede scores til plotting
options.loadings  = [];
options.MCR_S     = [];    % Lagre resultater fra MCR til plotting
options.MCR_C     = [];
options.mouse     = 6;
options.plotArea  = 520;
options.plotSize  = 1;
options.meanSpectra     = [];
options.selectedSpectra = cell(0,0);
options.selectedNames   = cell(0,0);
options.whichSpectra    = cell(0,0);
options.selectedSet     = 1;
options.selectedSegment = [];
options.xlabs     = [];
options.quantiles = false;
options.plotQuant = [];
options.doSegment = false;
options.segmented = [];
options.doEMSC    = false;
options.emsc_parameters = [];
options.emsc_par_names  = [];
options.doMCR          = false;
options.showLegend     = true;
options.showQuantiles  = false;
options.showSelections = true;
options.multiSelect    = [];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Create figure
handles.fig = figure('Name', 'HySpec', 'Color',handles.BGColor, ...
    'Position',[100,100,1000,650], 'MenuBar','none','Tag','Nofima');


%% Add axes
handles.axes1 = axes(...
    'Parent',handles.fig,...
    'Units','pixels',...
    'Position',[40 30 520 520],...
    'Tag','axes1', 'XTick',[],'YTick',[], 'Color','none' );

handles.axes2 = axes(...
    'Parent',handles.fig,...
    'Units','pixels',...
    'Position',[620 30 360 230],...
    'Tag','axes2','XTick',[],'YTick',[], 'Color','none' );

handles.axes3 = axes(...
    'Parent',handles.fig,...
    'Units','pixels',...
    'Position',[675 470 250 120],...
    'Tag','axes2','XTick',[],'YTick',[], 'Color','none' );


%% Add controls
handles.popupmenu_image = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[40 580 100 50],...
    'String',{'Image'},...
    'Style','popupmenu',...
    'Value',1,...
    'Tag','popupmenu_image');

handles.popupmenu_plotsize = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[40 555 100 50],...
    'String',{'Large plot','Medium plot','Small plot'},...
    'Style','popupmenu',...
    'Value',1,...
    'Tag','popupmenu_plotsize');

handles.edit1 = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[675 590 51 22],...
    'String','Min',...
    'Style','edit',...
    'Tag','edit1');

handles.edit2 = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[874 590 51 22],...
    'String','Max',...
    'Style','edit',...
    'Tag','edit2');

handles.popupmenu_ch1 = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[620 265 100 21],...
    'String','Ch.1',...
    'Style','popupmenu',...
    'Value',1,...
    'Tag','popupmenu_ch1');
handles.popupmenu_ch2 = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[881 265 100 21],...
    'String','Ch.2',...
    'Style','popupmenu',...
    'Value',1,...
    'Tag','popupmenu_ch2');

handles.edit_width = uicontrol(...
    'Parent',handles.fig,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[770 264 31 22],...
    'String','0',...
    'Style','edit',...
    'Tag','edit_width');
handles.text7 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.fig,...
    'Position',[803 261 31 22],...
    'String','+/-',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','text7');


%% Add mouse control buttons
handles.panel2 = uibuttongroup(...
    'Parent',handles.fig,...
    'Units','pixels',...
    'Title','',...
    'Tag','uipanel1',...
    'Clipping','on',...
    'Position',[170 580 400 70],...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'HighlightColor',handles.HiColor,'ShadowColor',handles.ShColor,...
    'SelectedObject',[],...
    'OldSelectedObject',[]);
handles.panel_text1 = uicontrol(...
    'Parent', handles.panel2, ...
    'Position', [10 50, 180, 15], ...
    'String', '---------------- Selection ----------------', ...
    'Style', 'text', ...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','panel_text1');
handles.panel_text2 = uicontrol(...
    'Parent', handles.panel2, ...
    'Position', [225 50, 160, 15], ...
    'String', '------- Manipulation -------', ...
    'Style', 'text', ...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','panel_text2');
handles.button1_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[10 15 80 23],...
    'String','Polynomial',...
    'Style','radiobutton',...
    'Value',0,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton1');
handles.button2_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[100 25 90 23],...
    'String','Click (multi)',...
    'Style','radiobutton',...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton2');
handles.button3_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[100 4 110 23],...
    'String','Click (single)',...
    'Style','radiobutton',...
    'Value',0,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton3');
handles.button4_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[245 25 60 23],...
    'String','Zoom',...
    'Style','radiobutton',...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton4');
handles.button5_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[245 4 60 23],...
    'String','Pan',...
    'Style','radiobutton',...
    'Value',0,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton5');
handles.button6_2 = uicontrol(...
    'Parent',handles.panel2,...
    'Position',[310 15 70 23],...
    'String','Interact',...
    'Style','radiobutton',...
    'Value',1,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Tag','radiobutton6');


%% Add selection table
handles.uitable_select = uitable(...
    'Parent',handles.fig,...
    'ColumnFormat',{  'numeric' 'char' 'numeric' 'numeric' 'numeric' },...
    'ColumnEditable',[false true false false false],...
    'ColumnName',{  'Sel.'; 'Name'; 'x'; 'y'; 'Px' },...
    'ColumnWidth',{  30 70 40 40 40 },...
    'Data',[],...
    'BackgroundColor',[handles.BGColor;handles.BGColor-0.1],'ForegroundColor',handles.FGColor,...
    'Position',[675 320 250 100],...
    'RowName',[],...
    'UserData',[],...
    'Tag','uitable_select', ...
    'Visible', 'on');


%% Add menus
handles.fileMenu = uimenu('Label','File');
loadui = uimenu(handles.fileMenu,'Label','Load','Accelerator','O');
saveui = uimenu(handles.fileMenu,'Label','Save','Accelerator','S');
uimenu(handles.fileMenu,'Label','Close','Callback','close',...
    'Separator','on','Accelerator','X');

handles.dataMenu = uimenu('Label','Dataset');
handles.select = uimenu(handles.dataMenu,'Label','Select object');
handles.snapshot = uimenu(handles.dataMenu,'Label','Snapshot','Enable','off');

handles.preprocMenu = uimenu('Label','Preprocess');
handles.preproc = [];
handles.preproc{1} = uimenu(handles.preprocMenu,'Label','Flip left/right');
handles.preproc{2} = uimenu(handles.preprocMenu,'Label','Reflectance to absorbance');
handles.preproc{3} = uimenu(handles.preprocMenu,'Label','Derivative (Savitzky-Golay)');
handles.preproc{4} = uimenu(handles.preprocMenu,'Label','SNV - Standard Normal Variate');
emscMenu           = uimenu(handles.preprocMenu,'Label','(E)MSC - (Extended) Multiplicative signal correction');
handles.preproc{5} = uimenu(emscMenu,'Label','Perform (E)MSC');
handles.emsc       = uimenu(emscMenu,'Label','View parameter images','Enable','off');
handles.emscToIm   = uimenu(emscMenu,'Label','Promote parameters to images','Enable','off');
handles.preproc{6} = uimenu(handles.preprocMenu,'Label','Non-negative image(s)');
handles.preproc{7} = uimenu(handles.preprocMenu,'Label','Nearest neighbour smoothing');

handles.analysisMenu = uimenu('Label','Analysis');
handles.MCR     = uimenu(handles.analysisMenu,'Label','MCR - Multivariate Curve Resolution');
handles.doMCR   = uimenu(handles.MCR,'Label','Perform MCR');
handles.viewMCR = uimenu(handles.MCR,'Label','View MCR concentration images','Enable','off');

handles.selectMenu = uimenu('Label','Selection');
handles.segmentMenu = uimenu(handles.selectMenu, 'Label','Segmentation');
handles.segment = [];
handles.segment{1} = uimenu(handles.segmentMenu,'Label','Nearest neighbour');
handles.segment{2} = uimenu(handles.segmentMenu,'Label','LDA');
handles.segment{3} = uimenu(handles.segmentMenu,'Label','Qvision');
handles.segment{4} = uimenu(handles.segmentMenu,'Label','Custom rule','Enable','off');
handles.setInvert  = uimenu(handles.selectMenu,'Label','Invert selection','Enable','off');
handles.setNA      = uimenu(handles.selectMenu,'Label','Delete selection from image(s)','Enable','off');
handles.addSegment = uimenu(handles.selectMenu,'Label','Add segments as selections','Enable','off');
handles.endSegment = uimenu(handles.selectMenu,'Label','View segmentation','Enable','off');
handles.exportSelect = uimenu(handles.selectMenu,'Label','Export selection(s)','Enable','off');

handles.plotMenu = uimenu('Label','Plot controls');
handles.popFig   = uimenu(handles.plotMenu,'Label','Figure popout');
handles.clip1p   = uimenu(handles.plotMenu,'Label','Clip histogram 1%');
handles.showSelect = uimenu(handles.plotMenu,'Label','Show selections','Checked','on');
handles.showQuant  = uimenu(handles.plotMenu,'Label','Show quantiles','Checked','off');
handles.showLegend = uimenu(handles.plotMenu,'Label','Show legend','Checked','on');

handles.colormapMenu = uimenu(handles.plotMenu, 'Label','Colormap');
handles.menu = cell(11,1);
handles.menu{1} = uimenu(handles.colormapMenu,'Label','gray','Checked','on');
handles.menu{2} = uimenu(handles.colormapMenu,'Label','bone');
handles.menu{3} = uimenu(handles.colormapMenu,'Label','copper');
handles.menu{4} = uimenu(handles.colormapMenu,'Label','hsv');
handles.menu{5} = uimenu(handles.colormapMenu,'Label','hot');
handles.menu{6} = uimenu(handles.colormapMenu,'Label','cool');
handles.menu{7} = uimenu(handles.colormapMenu,'Label','spring');
handles.menu{8} = uimenu(handles.colormapMenu,'Label','summer');
handles.menu{9} = uimenu(handles.colormapMenu,'Label','autumn');
handles.menu{10} = uimenu(handles.colormapMenu,'Label','winter');
handles.menu{11} = uimenu(handles.colormapMenu,'Label','pink');
handles.menu{12} = uimenu(handles.colormapMenu,'Label','<- Reverse ->');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Handlers and functions
set(loadui,'Callback',@(hObject,eventdata)loadCallback(hObject,1,handles));
set(saveui,'Callback',@(hObject,eventdata)saveCallback(hObject,1,handles));
set(handles.popFig,'Callback',@(hObject,eventdata)mainPlot(handles,false,true));
set(handles.panel2,'SelectionChangeFcn',@(hObject,eventdata)uipanel2_SelectionChangeFcn(get(hObject,'SelectedObject'),eventdata,handles));
for i=1:12
    set(handles.menu{i},'Callback',@(hObject,eventdata)colorMap(hObject,i,handles));
end
for i=1:7
    set(handles.preproc{i},'Callback',@(hObject,eventdata)preprocessing(hObject,i,handles));
end
set(handles.doMCR,'Callback',@(hObject,eventdata)mcr(hObject,eventdata,handles));
set(handles.viewMCR,'Callback',@(hObject,eventdata)mcr_view(hObject,eventdata,handles));
set(handles.emsc,'Callback',@(hObject,eventdata)emsc_plot_Callback(hObject,eventdata,handles))
set(handles.emscToIm,'Callback',@(hObject,eventdata)emsc_to_im_Callback(hObject,eventdata,handles))
set(handles.uitable_select,'CellSelectionCallback',@(hObject,eventdata)uitable_select_CellSelectionCallback(hObject,eventdata,handles))
set(handles.uitable_select,'CellEditCallback',@(hObject,eventdata)uitable_select_CellEditCallback(hObject,eventdata,handles))
set(handles.edit_width,'KeyPressFcn',@(hObject,eventdata)edit_width_KeyPressFcn(hObject,eventdata,handles))
set(handles.popupmenu_plotsize,'Callback',@(hObject,eventdata)popupmenu_plotsize_Callback(hObject,eventdata,handles))
set(handles.popupmenu_image,'Callback',@(hObject,eventdata)popupmenu_image_Callback(hObject,eventdata,handles))
set(handles.popupmenu_ch1,'Callback',@(hObject,eventdata)popupmenu_ch1_Callback(hObject,eventdata,handles))
set(handles.popupmenu_ch2,'Callback',@(hObject,eventdata)popupmenu_ch2_Callback(hObject,eventdata,handles))
for i=1:4
    set(handles.segment{i},'Callback',@(hObject,eventdata)segment(hObject,i,handles));
end
set(handles.exportSelect,'Callback',@(hObject,eventdata)exportSelect(hObject,eventdata,handles));
set(handles.addSegment,'Callback',@(hObject,eventdata)addSegmentation(hObject,eventdata,handles));
set(handles.endSegment,'Callback',@(hObject,eventdata)endSegmentation(hObject,eventdata,handles));
set(handles.setInvert,'Callback',@(hObject,eventdata)setInvert(hObject,eventdata,handles));
set(handles.setNA,'Callback',@(hObject,eventdata)setNA(hObject,eventdata,handles));
set(handles.snapshot,'Callback',@(hObject,eventdata)snapshot(hObject,eventdata,handles));
set(handles.select,'Callback',@(hObject,eventdata)selectCallback(hObject,eventdata,handles));
set(handles.showSelect,'Callback',@(hObject,eventdata)showSelect(hObject,eventdata,handles));
set(handles.showQuant,'Callback',@(hObject,eventdata)showQuant(hObject,eventdata,handles));
set(handles.showLegend,'Callback',@(hObject,eventdata)showLegend(hObject,eventdata,handles));
set(handles.clip1p,'Callback',@(hObject,eventdata)clip1p(hObject,eventdata,handles));
set(handles.fig,'ResizeFcn',@(hObject,eventdata)resizeFigure(hObject,eventdata,handles));


%--
function colorMap(hObject,which,handles)
global options
if which < 12
    for i=1:11
        set(handles.menu{i},'Checked','off')
    end
    cm = {'gray','bone','copper','hsv','hot',...
        'cool','spring','summer','autumn',...
        'winter','pink'};
    options.colormap = cm{which};
    set(handles.menu{which},'Checked','on')
else
    options.imMinMax = [];
    if strcmp(get(handles.menu{12},'Checked'), 'off')
        set(handles.menu{which},'Checked','on')
        options.reverse = true;
    else
        set(handles.menu{which},'Checked','off')
        options.reverse = false;
    end
end
mainPlot(handles, false, false);


%-
function popupmenu_plotsize_Callback(hObject, eventdata, handles)
global options
p34 = options.plotArea;
if get(handles.popupmenu_plotsize,'Value')==1
    options.plotSize = 1;
    set(handles.axes1,'Position', [40 30 p34 p34])
elseif get(handles.popupmenu_plotsize,'Value')==2
    options.plotSize = 2;
    p24 = (p34-p34/1.444)/2;
    set(handles.axes1,'Position', [40+p24 30+p24 p34/1.444 p34/1.444])
else
    options.plotSize = 3;
    p24 = (p34-p34/2.6)/2;
    set(handles.axes1,'Position', [40+p24 30+p24 p34/2.6 p34/2.6])
end


%-
function popupmenu_image_Callback(hObject, eventdata, handles)
global options
% options.imNo = ;
% options.doSegment = false;
% options.doEMSC = false;
% set(handles.emsc,'Checked','off')
% options.wave1 = 1;
% options.wave2 = 0;
% set(handles.popupmenu_ch1,'Value',1)
% set(handles.popupmenu_ch2,'Value',0)
% set(handles.endSegment,'Enable','off')
% set(handles.endSegment,'Checked','off')
% set(handles.addSegment,'Enable','off')
newDataset(handles,get(handles.popupmenu_image,'Value'))
options.mouse = 6;
set(handles.button6_2,'Value',1);
% options.meanSpectra = hyspec_mean(currentDataset(options.imNo).d);
% mainPlot(handles,true,false)


%--
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
global options currentDataset
if isfield(options,'imp') % End impoly if active
    robot = java.awt.Robot;
    robot.keyPress    (java.awt.event.KeyEvent.VK_ESCAPE);
    robot.keyRelease  (java.awt.event.KeyEvent.VK_ESCAPE);
end
if get(handles.button1_2,'Value')==1  % Select polynomial
    if ~isempty(currentDataset)
        options.mouse = 1;
        zoom off
        pan off
        if options.doSegment || options.doEMSC || options.doMCR
            options.doSegment = false;
            options.doEMSC    = false;
            options.doMCR     = false;
            set(handles.emsc,'Checked','off')
            set(handles.endSegment,'Checked','off')
            set(handles.viewMCR,'Checked','off')
            %         mainPlot(handles,false,false)
            options.multiSelect    = [];
            newDataset(handles,options.imNo);
        end
        axes(handles.axes1)
        options.imp = impoly(gca);
        if ~isempty(options.imp)
            pos = getPosition(options.imp);
            options.polys{length(options.polys)+1} = pos;
            px = size(currentDataset(options.imNo).d);
            spectra = reshape(currentDataset(options.imNo).d,[px(1)*px(2),px(3)]);
            mask    = createMask(options.imp);
            delete(options.imp)
            [w1,w2] = ind2sub(size(mask),find(mask));
            spectra = spectra(mask,:);
            options.meanSpectra = [options.meanSpectra; mean(spectra)];
            options.selectedSpectra{1,size(options.selectedSpectra,2)+1} = spectra;
            options.selectedNames{1,size(options.selectedNames,2)+1} = [];
            % Tabell-lagring og sletting
            data = get(handles.uitable_select,'Data');
            n_sel = size(data,1);
            if n_sel == 0
                set(handles.uitable_select,'Data',{1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)})
                options.whichSpectra = {ind2sub([px(1),px(2)],find(mask))};
            else
                last = max(cell2mat(data(:,1)));
                set(handles.uitable_select,'Data',[data;{last+1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)}])
                options.whichSpectra{1,length(options.whichSpectra)+1} = ind2sub([px(1),px(2)],find(mask));
            end
            set(handles.setInvert,'Enable','on')
            set(handles.setNA,'Enable','on')
            set(handles.exportSelect,'Enable','on')
        end
    end
    options.mouse = 6;
    axes(handles.axes1)
    set(handles.button1_2,'Value',0)
    set(handles.button6_2,'Value',1)
    mainPlot(handles, false, false)
elseif get(handles.button2_2,'Value')==1  % Select several spectra
    if ~isempty(currentDataset)
        options.mouse = 2;
        options.multiSelect = [];
        zoom off
        pan off
        if options.doSegment || options.doEMSC || options.doMCR
            options.doSegment = false;
            options.doEMSC    = false;
            options.doMCR     = false;
            set(handles.emsc,'Checked','off')
            set(handles.endSegment,'Checked','off')
            set(handles.viewMCR,'Checked','off')
            newDataset(handles,options.imNo);
        else
            mainPlot(handles,false,false)
        end
    end
elseif get(handles.button3_2,'Value')==1 % Select single pixel
    if ~isempty(currentDataset)
        zoom off
        pan off
        options.mouse = 3;
        if options.doSegment || options.doEMSC || options.doMCR
            options.doSegment = false;
            options.doEMSC    = false;
            options.doMCR     = false;
            set(handles.emsc,'Checked','off')
            set(handles.endSegment,'Checked','off')
            set(handles.viewMCR,'Checked','off')
            %         mainPlot(handles,false,false)
            newDataset(handles,options.imNo);
        end
        axes(handles.axes1)
        options.imp = impoint(gca);
        if ~isempty(options.imp)
            pos = getPosition(options.imp);
            options.polys{length(options.polys)+1} = -pos;
            px = size(currentDataset(options.imNo).d);
            spectra = reshape(currentDataset(options.imNo).d,[px(1)*px(2),px(3)]);
            mask    = createMask(options.imp);
            delete(options.imp)
            [w1,w2] = ind2sub(size(mask),find(mask));
            spectra = spectra(mask,:);
            options.meanSpectra = [options.meanSpectra; spectra];
            options.selectedSpectra{1,size(options.selectedSpectra,2)+1} = spectra;
            options.selectedNames{1,size(options.selectedNames,2)+1} = [];
            % Tabell-lagring og sletting
            data = get(handles.uitable_select,'Data');
            n_sel = size(data,1);
            if n_sel == 0
                set(handles.uitable_select,'Data',{1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)})
                options.whichSpectra = {ind2sub([px(1),px(2)],find(mask))};
            else
                last = max(cell2mat(data(:,1)));
                set(handles.uitable_select,'Data',[data;{last+1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)}])
                options.whichSpectra{1,length(options.whichSpectra)+1} = ind2sub([px(1),px(2)],find(mask));
            end
            set(handles.setInvert,'Enable','on')
            set(handles.setNA,'Enable','on')
            set(handles.exportSelect,'Enable','on')
        end
    end
    options.mouse = 6;
    axes(handles.axes1)
    set(handles.button1_2,'Value',0)
    set(handles.button6_2,'Value',1)
    mainPlot(handles, false, false)
elseif get(handles.button4_2,'Value')==1
    options.mouse = 4;
    mainPlot(handles,false,false)
    pan off
    zoom on
elseif get(handles.button5_2,'Value')==1
    options.mouse = 5;
    mainPlot(handles,false,false)
    zoom off
    pan on
elseif get(handles.button6_2,'Value')==1
    options.mouse = 6;
    mainPlot(handles,false,false)
    zoom off
    pan off
end


%--
function loadCallback(hObject, eventdata, handles)
global currentDataset options
[filename, pathname, index] = uigetfile( ...
    {'*.mat;*.MAT','MATLAB data file (*.mat)';
    '*.bin;*.bin','QVision bin file(s) (*.bin)';
    '*.fsm;*.fsm','PerkinElmer IR file(s) (*.fsm)';
    '*.mat;*.MAT','Unscrambler export for MATLAB (*.mat)';
    '*.*',  'All Files (*.*)'},...
    'Select MATLAB spectra to analyse',...
    options.path,'MultiSelect', 'on');

if index > 0
    options.path = pathname;
    if ~iscell(filename)
        filename = {filename};
    end
    filename_orig = filename;
    for i=1:length(filename)
        filename{i} = strcat(pathname,filename{i});
    end
    
    if index == 1
        for i = 1:length(filename)
            disp(['load(''',filename{i},''')'])
            evalin('base',['load(''',filename{i},''')'])
        end
        selectCallback(hObject, eventdata, handles)
    elseif index == 2
        save([tempdir 'import.mat'], 'filename')
        string = 'QVision2MATLAB(''_sep_';
%         for i = 1:length(filename)
%             string = [string filename{i} '_sep_'];
%         end
        string = [string tempdir 'import.mat_sep_' tempdir 'fil.mat_sep_'')'];
        string = strrep(string, '\', '_dir_');
        string = strrep(string, '/', '_dir_');
        string = strrep(string, ':', '_colon_');
        string = strrep(string, ' ', '_space_');
        xL = get(handles.axes1,'XLim');
        yL = get(handles.axes1,'YLim');
        axes(handles.axes1)
        text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Importing', 'FontSize',30,...
            'HorizontalAlignment','center')
        text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Importing', 'FontSize',30,...
            'HorizontalAlignment','center','Color',[1 1 1])
        drawnow
        [status,results] = system(string);
        if status ~= 0
            fprintf('%s',results)
        else
            eval(['load(''',tempdir '\fil.mat'')'])
            dataset = hyspec_object(Ims);
            for i = 1:length(filename_orig)
                dataset(i).i = filename_orig{i};
            end
            currentDataset = dataset;
            options.xlabs  = dataset(1).v;
            options.i = cell(1,i);
            if isempty(dataset(1).i)
                for j = 1:i
                    options.i{j} = ['Image ' num2str(j)];
                end
            else
                for j = 1:i
                    options.i{j} = dataset(j).i;
                end
            end
            newDataset(handles)
        end
    elseif index == 3
        nFile = length(filename);
        h = waitbar(0,['Importing image 1/' num2str(nFile)]);
        for i = 1:nFile
            waitbar((i-1)/nFile,h,['Importing image: ' num2str(i) '/' num2str(nFile)])
            [data, xAxis, yAxis, zAxis] = fsmload(filename{i});
            dataset(i) = hyspec_object(data, 'x',xAxis, 'y',yAxis, 'v',zAxis); %#ok<AGROW>
            dataset(i).i = filename_orig{i}; %#ok<AGROW>
        end
        currentDataset = dataset;
        options.xlabs  = dataset(1).v;
        options.i = cell(1,i);
        if isempty(dataset(1).i)
            for j = 1:i
                options.i{j} = ['Image ' num2str(j)];
            end
        else
            for j = 1:i
                options.i{j} = dataset(j).i;
            end
        end
        newDataset(handles)
        
%         nchar = length(filename_orig{1});
%         names = filename_orig{1};
%         [data, xAxis, yAxis, zAxis] = fsmload(filename{1});
%         ims = zeros([size(data) nFile]);
%         ims(:,:,:,1) = data;
%         if length(filename) > 1
%             for i = 2:nFile
%                 waitbar((i-1)/nFile,h,['Importing ' num2str(i) '/' num2str(nFile) ' images'])
%                 [ims(:,:,:,i)] = fsmload(filename{i});
%                 if length(filename_orig{i})>nchar
%                     names = [names repmat(' ', i-1, 1)];
%                 end
%                 names(i,:) = [filename_orig{i} repmat(' ',1,nchar-length(filename_orig{i}))];
%                 nchar = size(names,2);
%             end
%         end
        close(h)
%         I = hyspec_object(ims, 'i',names, 'v',zAxis, 'x', xAxis, 'y', yAxis);
%         assignin('base', 'FSM_import', I);
%         selectCallback(hObject, eventdata, handles)
    end
end


%--
function saveCallback(hObject, eventdata, handles)
global currentDataset options
[filename, pathname, filterindex] = uiputfile( ...
    {'*.mat','MAT-file (array + abscissas) (*.mat)';...
    '*.mat','MAT-file (struct) (*.mat)';...
    '*.mat','MAT-file (Unscrambler)';...
    '*.*',  'All Files (*.*)'},...
    'Save as');
if ~(isequal(filename,0) || isequal(pathname,0))
    if filterindex == 1
        Im = currentDataset; %#ok<NASGU>
        xlabs = options.xlabs; %#ok<NASGU>
        eval(['save(''' fullfile(pathname,filename) ''', ''Im'', ''xlabs'')'])
    elseif filterindex == 2
        Im = struct('data',currentDataset, ...
            'xlabs', options.xlabs); %#ok<NASGU>
        eval(['save(''' fullfile(pathname,filename) ''', ''Im'')'])
    elseif filterindex == 3
        disp('Not implemented yet')
    end
end


%--
function newDataset(handles,imNo)
global options currentDataset
same = false;
options.clip = false;
% Update options
if nargin==1
    resetParam(handles,1,1);
    set(handles.popupmenu_ch1,'Value',1)
    set(handles.popupmenu_ch2,'Value',1)
    options.imNo  = 1;
    options.meanSpectra = hyspec_mean(currentDataset(1));
    set(handles.popupmenu_image,'String',options.i)
    set(handles.popupmenu_image,'Value',options.imNo)
    options.wave1 = 1;
    options.wave2 = 0;
    options.clip  = false;
    options.waveWidth = 0;
    options.reverse   = false;
else
    if imNo == options.imNo
        same = true;
        options.wave1 = 1;
        options.wave2 = 0;
    end
    options.imNo  = imNo;
    options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo));
end
options.imMinMax  = [];
options.scores    = [];
options.loadings  = [];

% Update GUI
if options.doEMSC
    tmp = options.emsc_par_names;
elseif options.doMCR
    n = size(options.MCR_S,1);
    tmp = [repmat('Comp. ',n,1) num2str((1:n)')];
else
    tmp = num2str(options.xlabs(:));
    if size(tmp,2) < 4
        tmp = [tmp repmat(' ',size(tmp,1), 4-size(tmp,2))];
    end
    if size(tmp) > 4
        tmp = [tmp; [['PC 1';'PC 2';'PC 3';'PC 4';'PC 5'] repmat(' ', 3, size(tmp,2)-4)]];
    else
        tmp = [tmp; ['PC 1';'PC 2';'PC 3';'PC 4';'PC 5']];
    end
end
% if nargin == 1 || same
set(handles.popupmenu_ch1,'String',tmp,'Value',options.wave1)
set(handles.popupmenu_ch2,'String',[repmat(' ', 1, size(tmp,2)); tmp],'Value',options.wave2+1)
%     set(handles.popupmenu_ch1,'String',tmp,'Value',options.wave1)
%     set(handles.popupmenu_ch2,'String',[repmat(' ', 1, size(tmp,2)); tmp],'Value',options.wave2)
% end
set(handles.snapshot,'Enable','on')

% Update plots
if same
    mainPlot(handles,false,false)
else
    mainPlot(handles,true,false)
end


% Main plotting function
function mainPlot(handles, reset, popout)
global options currentDataset
if isempty(currentDataset)
    return;
else
    theImage = currentDataset(options.imNo).d;
end
if popout
    reset = true;
    figure
else
    axes(handles.axes1)
end
if ~reset % Keep zoom
    xL = get(gca,'XLim');
    yL = get(gca,'YLim');
end

if options.doSegment
    imSeg = options.segmented(options.imNo).d;
end
if options.doEMSC
    theImage = options.emsc_parameters(options.imNo).d;
end
if options.doMCR
    theImage = options.MCR_C(options.imNo).d;
end
wi = get(handles.edit_width,'String');
if isempty(wi) || strcmp(wi,'')
    wi = 0;
else
    wi = str2num(wi);
end

if options.wave1 > 0
    ch = options.wave1;
    ch = ch + (-wi:1:wi);
    ch(ch<1) = []; ch(ch>size(theImage,3)) = [];
    im = mean(theImage(:,:,ch),3);
else
    if isempty(options.scores) || size(options.scores,3) < -options.wave1
        [options.loadings,options.scores] = hyspec_pca(theImage,'ncomp',-options.wave1);
    end
    im = options.scores(:,:,-options.wave1);
end
if options.wave2 > 0 && options.wave2 ~= options.wave1
    ch = options.wave2;
    ch = ch + (-wi:1:wi);
    ch(ch<1) = []; ch(ch>length(options.xlabs)) = [];
    im = im./mean(theImage(:,:,ch),3);
elseif options.wave2 < 0 && options.wave2 ~= options.wave1
    if isempty(options.scores) || size(options.scores,3) < -options.wave2
        [options.loadings,options.scores] = hyspec_pca(theImage,'ncomp',-options.wave2);
    end
    im = im./options.scores(:,:,-options.wave2);
end

if options.reverse == 1
    if options.doSegment
        imSeg = max(imSeg(:))-imSeg;
    else
        im = max(im(:))-im;
    end
end
un = min(256,length(unique(im(:))));
eval(['cols = colormap(' options.colormap '(' num2str(un) '));']);
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
if any(isnan(mm)) || any(isinf(mm))
    mm(1) = 0;
    mm(2) = 1;
end
if mm(1)==mm(2) % Handle "flat" images
    mm(1) = mm(1)-eps;
end
hold off
cla
imagesc(im,mm)
if options.doSegment
    imSeg = imSeg - min(imSeg(:));
    imSeg = imSeg./max(imSeg(:)).*256;
    hold on
    iseg = image(imSeg);
    if ~isempty(options.selectedSegment)
        uis = unique(imSeg(:));
        alfa = ones(size(imSeg));
        for i=1:length(options.selectedSegment)
            alfa(uis(options.selectedSegment(i))==imSeg) = 0;
        end
        set(iseg,'AlphaData',alfa);%repmat(0.9,size(imSeg)));
    end
end
if ~popout && options.showSelections
    hold on
    for i=1:length(options.polys)
        pos = options.polys{i};
        if iscell(pos);
            for j=1:length(pos)
                posj = options.polys{i}{j};
                patch(posj(:,1),posj(:,2), zeros(size(posj,1),1), 'FaceColor','none')
                patch(posj(:,1),posj(:,2), zeros(size(posj,1),1), 'FaceColor','none','EdgeColor',[1 1 1],'LineStyle',':')
            end
        elseif ~isempty(pos)
            if pos(1,1) > 0 % Polynomial
                patch(pos(:,1),pos(:,2), zeros(size(pos,1),1), 'FaceColor','none')
                patch(pos(:,1),pos(:,2), zeros(size(pos,1),1), 'FaceColor','none','EdgeColor',[1 1 1],'LineStyle',':')
            else % Single points
                for j=1:size(pos,1)
                    plot(-pos(j,1),-pos(j,2),'kx')
                    plot(-pos(j,1),-pos(j,2),'+','Color',[1 1 1])
                end
            end
        end
    end
end
if options.mouse == 2
    set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_multiSelect,handles})
    set(gca,'ButtonDownFcn', {@mouseclick_multiSelect,handles})
    if ~isempty(options.multiSelect)
        for j=1:size(options.multiSelect,1)
            plot(options.multiSelect(j,1),options.multiSelect(j,2),'gx')
            plot(options.multiSelect(j,1),options.multiSelect(j,2),'r+')
        end
    end
end

if ~reset
    xlim(xL)
    ylim(yL)
else
    zoom reset
end

% Histogram in upper right corner
if ~popout 
    axes(handles.axes3)
    if options.doSegment
        uis = unique(imSeg(:));
        un = length(uis);
        m1 = 1;
        m2 = un;
        s  = m1:(m2-m1)/(un-1):m2;
        hi = hist(imSeg(:),uis(s));
    else
        m1 = min(im(:));
        if isinf(m1) % Handle strange images
            imvec = im(:);
            imvec = imvec(~isinf(imvec));
            m1 = min(imvec);
        end % Handle strange images
        if isnan(m1)
            m1 = 0;
        end
        m2 = max(im(:));
        if isinf(m2) % Handle strange images
            imvec = im(:);
            imvec = imvec(~isinf(imvec));
            m2 = max(imvec);
        end % Handle strange images
        if isnan(m2)
            m2 = m1+1;
        end
        if m1==m2 % Set midpoints of histogram bars
            s = m1;
            hi = hist(im(:),1);
        else
            s  = m1:(m2-m1)/(un-1):m2;
            hi = hist(im(:),s);
        end
    end
    if m1==m2 % Find left and right edges of histogram bars
        s1 = s-0.5;
        s2 = s+0.5;
    else
        s1 = s - (m2-m1)/(un*2-2);
        s2 = s + (m2-m1)/(un*2-2);
    end
    hold off
    plot([s1(1) s2(end)],[0,0],'-k')
    if options.doSegment % Set color indexes for histogram bars
        cc = (1:un);
    else
        cc = zeros(1,un);
        cc(s<mm(1)) = 1;
        cc(s>mm(2)) = un;
        nun = sum(cc==0);
        if nun == 1
            cc(s>=mm(1) & s<=mm(2)) = round(un/2);
        else
            cc(s>=mm(1) & s<=mm(2)) = round(1:(un-1)/(nun-1):un);
        end
    end
%     if ~options.doSegment
%         cc(s <= options.imMinMax(1)) = 1;
%         cc(s >= options.imMinMax(2)) = un;
%     end
    % Plot histogram bars
    patch([s1(:) s2(:) s2(:) s1(:)]', [zeros(un,1) zeros(un,1) hi(:) hi(:)]', 'b','EdgeColor','none','FaceVertexCData', cc', 'FaceColor', 'flat')
    ss  = [s1;s2];
    sss = ss(:);
    hh  = [hi;hi];
    hhh = hh(:);
    hold on
    % Outline edges of histogram bars
    plot([sss(1) sss' sss(end)], [0 hhh' 0], 'k')
    xlim([s1(1) s2(end)])
    mmm = max(hi(:));
    ylim([0 mmm*1.05+eps])
    set(gca,'YTick',[])
    if ~options.doSegment % Show cut-off limits 
        yl = get(gca,'YLim');
        plot(mm(1)*ones(1,2),yl,':k')
        plot(mm(2)*ones(1,2),yl,':r')
        set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_callback2,handles})
        set(gca,'ButtonDownFcn', {@mouseclick_callback2,handles})
    else
        set(gca,'XTick',1:un)
        set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_callback3,handles})
        set(gca,'ButtonDownFcn', {@mouseclick_callback3,handles})
    end
    
    set(handles.edit1,'String',roundn(mm(1),3))
    set(handles.edit2,'String',roundn(mm(2),3))
    
    plotSpectra(handles)
end


%% Selection dialog
function selectCallback(hObject, eventdata, handles)
handles.sel = figure('Position',[250,250,180,240], 'WindowStyle','modal',...
    'Units','pixels', 'MenuBar','none', 'Resize','off');
objects = evalin('base','who');
handles.tab1 = uitable(...
    'Parent',handles.sel,...
    'Units','pixels',...
    'ColumnFormat',{  [] },...
    'ColumnEditable',false,...
    'ColumnName',{  'Object' },...
    'ColumnWidth',{  138 },...
    'Data',cellstr(objects),...
    'RowName',[],...
    'Position',[20,60,140,160],...
    'UserData',[],...
    'Tag','uitable_select');
handles.OK1 = uicontrol(...
    'Parent',handles.sel,...
    'Units','pixels',...
    'Position',[90,20,70,30],...
    'String','OK',...
    'Tag','pushbutton1');
handles.Cancel1 = uicontrol(...
    'Parent',handles.sel,...
    'Units','pixels',...
    'Callback','close',...
    'Position',[20,20,70,30],...
    'String','Cancel',...
    'Tag','pushbutton1');
set(handles.tab1,'CellSelectionCallback',@(hObject,eventdata)tab1_CellSelectionCallback(hObject,eventdata,handles));
set(handles.Cancel1,'Callback','close');
set(handles.OK1,'Callback',@(hObject,eventdata)selectedCallback(hObject,eventdata,handles));


%-
function tab1_CellSelectionCallback(hObject, eventdata, handles)
global selected
selected = eventdata.Indices(:,1);


%-
function selectedCallback(hObject, eventdata, handles)
global selected currentDataset options
nsel = length(selected);
if nsel > 2
    errodlg('Select one or two objects object')
elseif nsel == 1
    list = get(handles.tab1,'Data');
    tmp = evalin('base',list{selected});
    if isnumeric(tmp) % Single matrix, no xlabs
        set(handles.emsc,'Checked','off')
        set(handles.endSegment,'Checked','off')
        set(handles.viewMCR,'Checked','off')
        options.doEMSC = false;
        options.doMCR  = false;
        options.doSegment = false;
        currentDataset = hyspec_object(tmp);
        [n1,n2,w,i] = size(tmp);
        options.xlabs = 1:size(tmp,3);
        options.x = 1:n1;
        options.y = 1:n2;
        options.i = cell(1,i);
        for j = 1:i
            options.i{j} = ['Image ' num2str(j)];
        end
    elseif isstruct(tmp)
        set(handles.emsc,'Checked','off')
        set(handles.endSegment,'Checked','off')
        set(handles.viewMCR,'Checked','off')
        options.doEMSC = false;
        options.doMCR  = false;
        options.doSegment = false;
        currentDataset = tmp;
        if isfield(tmp, 'd') && isfield(tmp,'i') && isfield(tmp,'v') && isfield(tmp,'x') && isfield(tmp,'y')
             % hyspec_object
             currentDataset = tmp;
             i = length(currentDataset);
             options.xlabs  = tmp(1).v;
             options.i = cell(1,i);
             if isempty(tmp(1).i)
                 for j = 1:i
                     options.i{j} = ['Image ' num2str(j)];
                 end
             else
                 for j = 1:i
                     options.i{j} = tmp(j).i;
                 end
             end
%              options.i = tmp.i;
        elseif isfield(tmp,'filename') && isfield(tmp,'spectra') ...
                && isfield(tmp,'rows') && isfield(tmp,'columns') ...
                && isfield(tmp,'variables')
            % imageObject
            currentDataset = tmp.spectra;
            options.xlabs  = tmp.variables;
            options.x      = tmp.rows;
            options.y      = tmp.columns;
            options.i      = tmp.filename;
        end
    end
    options.meanSpectra = hyspec_mean(currentDataset);
%     options.size = [n1,n2,w,i];
    close(handles.sel)
    newDataset(handles);
%     delete(handles.sel)
end


%-
function mcr(hObject, eventdata, handles)
global options currentDataset
if ~isempty(currentDataset)
    MCRCallback(hObject, eventdata, handles);
end


%-
function MCRCallback(hObject, eventdata, handles)
handles.mcr1 = figure('Position',[250,250,261,214], 'WindowStyle','modal',...
    'Units','pixels', 'MenuBar','none', 'Resize','off', ...
    'Color',handles.BGColor);
handles.mcrPanel1 = uipanel(...
    'Parent',handles.mcr1,...
    'Units','pixels',...
    'Title','Non-negativity',...
    'Tag','MCRPanel1',...
    'Clipping','on',...
    'Position',[19 111 221 51]);
handles.mcrCheck1 = uicontrol(...
    'Parent',handles.mcrPanel1,...
    'Position',[20 11 103 23],...
    'String','Concentrations',...
    'Style','checkbox',...
    'Tag','MCRcheckbox1');
handles.mcrCheck2 = uicontrol(...
    'Parent',handles.mcrPanel1,...
    'Position',[135 11 66 23],...
    'String','Spectra',...
    'Style','checkbox',...
    'Tag','MCRcheckbox2');
handles.mcrPanel2 = uipanel(...
    'Parent',handles.mcr1,...
    'Units','pixels',...
    'Title','Unimodality',...
    'Tag','MCRPanel2',...
    'Clipping','on',...
    'Position',[19 51 221 51]);
handles.mcrCheck3 = uicontrol(...
    'Parent',handles.mcrPanel2,...
    'Position',[20 11 103 23],...
    'String','Concentrations',...
    'Style','checkbox',...
    'Tag','MCRcheckbox3');
handles.mcrCheck4 = uicontrol(...
    'Parent',handles.mcrPanel2,...
    'Position',[135 11 66 23],...
    'String','Spectra',...
    'Style','checkbox',...
    'Tag','MCRcheckbox4');
handles.mcrText = uicontrol(...
    'Parent',handles.mcr1,...
    'Position',[70 176 71 14],...
    'String','# components',...
    'Style','text',...
    'Tag','MCRtext1');
handles.mcrEdit = uicontrol(...
    'Parent',handles.mcr1,...
    'BackgroundColor',[1 1 1],...
    'Position',[150 172 31 22],...
    'String','5',...
    'Style','edit',...
    'Tag','MCRedit1');
handles.mcrOK = uicontrol(...
    'Parent',handles.mcr1,...
    'Callback',@(hObject,eventdata)testA_export('pushbutton1_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[121 13 100 31],...
    'String','OK',...
    'Tag','MCRpushbutton1');
handles.mcrCancel = uicontrol(...
    'Parent',handles.mcr1,...
    'Callback',@(hObject,eventdata)testA_export('pushbutton1_Callback',hObject,eventdata,guidata(hObject)),...
    'Position',[20 13 100 31],...
    'String','Cancel',...
    'Tag','MCRpushbutton1');
set(handles.mcrCancel,'Callback',@(hObject,eventdata)mcrClose(hObject,eventdata,handles));
set(handles.mcrOK,'Callback',@(hObject,eventdata)mcrMCRCallback(hObject,eventdata,handles));

function mcrClose(hObject,eventdata,handles)
global options currentDataset
close
options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo).d);
newDataset(handles,options.imNo)

function mcrMCRCallback(hObject,eventdata,handles)
global options currentDataset
ncomp = str2num(get(handles.mcrEdit,'String'));
nn = zeros(1,2); um = zeros(1,2);
nn(1) = get(handles.mcrCheck1,'Value');
nn(2) = get(handles.mcrCheck2,'Value');
um(1) = get(handles.mcrCheck3,'Value');
um(2) = get(handles.mcrCheck4,'Value');
close
xL = get(handles.axes1,'XLim');
yL = get(handles.axes1,'YLim');
axes(handles.axes1)
text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Analysing', 'FontSize',30,...
    'HorizontalAlignment','center')
text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Analysing', 'FontSize',30,...
    'HorizontalAlignment','center','Color',[1 1 1])
drawnow
tmp = '[C,S] = hyspec_mcr(currentDataset, ncomp, ''non_neg'', nn, ''unimod'', um);';
eval(tmp)
options.MCR_C = C;
options.MCR_S = S;
options.doMCR     = true;
options.doEMSC    = false;
options.doSegment = false;
options.imMinMax  = [];
set(handles.viewMCR,'Checked','on','Enable','on')
set(handles.emsc,'Checked','off')
set(handles.endSegment,'Checked','off')
% mainPlot(handles,true,false)

% options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo).d);
% set(handles.emsc,'Enable','on')
% set(handles.emscToIm,'Enable','on')

newDataset(handles,options.imNo)


%-
function preprocessing(hObject, which, handles)
% 'Flip left/right');
% 'Reflectance to absorbance');
% 'SNV');
% '(E)MSC');
% 'Baseline correct');
% Nearest neighbour smoothing
global options currentDataset
if ~isempty(currentDataset)
    xL = get(handles.axes1,'XLim');
    yL = get(handles.axes1,'YLim');
    axes(handles.axes1)
    text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Preprocessing', 'FontSize',30,...
        'HorizontalAlignment','center')
    text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Preprocessing', 'FontSize',30,...
        'HorizontalAlignment','center','Color',[1 1 1])
    drawnow
    im = length(currentDataset);
    w  = size(currentDataset(1).d,3);
    switch which
        case 1
            for i=1:im
                currentDataset(i).d = currentDataset(i).d(:,:,w:-1:1);
            end
            options.xlabs = options.xlabs(end:-1:1);
        case 2
            currentDataset = hyspec_ref2abs(currentDataset);
        case 3
            derivativeCallback(hObject, 1, handles);
        case 4
            currentDataset = hyspec_snv(currentDataset);
        case 5
            EMSCCallback(hObject, 1, handles);
        case 6
            forceImNonNegative();
        case 7
            currentDataset = nnSmooth(currentDataset);
            options.imMinMax  = [];
    end
    if which ~= 5 && which ~= 3
        options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo));
        newDataset(handles,options.imNo)
    end
end


%- Force spectra to be non-negative
function forceImNonNegative()
global currentDataset
for i=1:length(currentDataset)
    currentDataset(i).d = currentDataset(i).d-min(currentDataset(i).d(:));
end


%-
function smoothed = nnSmooth(data)
smoothed = data;
h = waitbar(0,'Smoothing','Name','Smoothing');
ld = length(data);
for im = 1:ld
    waitbar((im-1) / ld,h,['Image ' num2str(im) '/' num2str(ld)])
    % Corners
    smoothed(im).d(1,1,:)     = mean(mean(data(im).d(1:2,1:2,:),1),2);% + 0.5*data(1,1,:,:);
    smoothed(im).d(1,end,:)   = mean(mean(data(im).d(1:2,end-1:end,:),1),2);% + 0.5*data(1,end,:,:);
    smoothed(im).d(end,1,:)   = mean(mean(data(im).d(end-1:end,1:2,:),1),2);% + 0.5*data(end,1,:,:);
    smoothed(im).d(end,end,:) = mean(mean(data(im).d(end-1:end,end-1:end,:),1),2);% + 0.5*data(end,end,:,:);
    % Edges
    smoothed(im).d(2:(end-1),1) = (smoothed(im).d(1:(end-2),1) + ...
        smoothed(im).d(2:(end-1),1) + ...
        smoothed(im).d(3:(end),1) + ...
        smoothed(im).d(1:(end-2),2) + ...
        smoothed(im).d(2:(end-1),2) + ...
        smoothed(im).d(3:(end),2))./6;
    smoothed(im).d(2:(end-1),end) = (smoothed(im).d(1:(end-2),end) + ...
        smoothed(im).d(2:(end-1),end) + ...
        smoothed(im).d(3:(end),end) + ...
        smoothed(im).d(1:(end-2),end-1) + ...
        smoothed(im).d(2:(end-1),end-1) + ...
        smoothed(im).d(3:(end),end-1))./6;
    smoothed(im).d(1,2:(end-1)) = (smoothed(im).d(1,1:(end-2)) + ...
        smoothed(im).d(1,2:(end-1)) + ...
        smoothed(im).d(1,3:(end)) + ...
        smoothed(im).d(2,1:(end-2)) + ...
        smoothed(im).d(2,2:(end-1)) + ...
        smoothed(im).d(2,3:(end)))./6;
    smoothed(im).d(end,2:(end-1)) = (smoothed(im).d(end,1:(end-2)) + ...
        smoothed(im).d(end,2:(end-1)) + ...
        smoothed(im).d(end,3:(end)) + ...
        smoothed(im).d(end-1,1:(end-2)) + ...
        smoothed(im).d(end-1,2:(end-1)) + ...
        smoothed(im).d(end-1,3:(end)))./6;
    % Internals
    smoothed(im).d(2:(end-1),2:(end-1)) = (smoothed(im).d(1:(end-2),1:(end-2)) + ...
        smoothed(im).d(1:(end-2),2:(end-1)) + ...
        smoothed(im).d(1:(end-2),3:(end)) + ...
        smoothed(im).d(2:(end-1),1:(end-2)) + ...
        smoothed(im).d(2:(end-1),2:(end-1)) + ...
        smoothed(im).d(2:(end-1),3:(end)) + ...
        smoothed(im).d(3:(end),1:(end-2)) + ...
        smoothed(im).d(3:(end),2:(end-1)) + ...
        smoothed(im).d(3:(end),3:(end)))./9;
end
close(h)


%--
function uitable_select_CellEditCallback(hObject, eventdata, handles)
global options
data = get(handles.uitable_select,'Data');
tmpAll = cellstr(data(setdiff(1:size(data,1),options.selectedSet),2));
tmp = data{options.selectedSet,2};
if strcmp(tmp,'-')
    options.meanSpectra(options.selectedSet+1,:) = [];
    options.selectedSpectra = options.selectedSpectra(1,setdiff(1:length(options.selectedSpectra),options.selectedSet));
    options.selectedNames   = options.selectedNames(1,setdiff(1:length(options.selectedNames),options.selectedSet));
    options.whichSpectra    = options.whichSpectra(1,setdiff(1:length(options.whichSpectra),options.selectedSet));
    options.polys           = options.polys(1,setdiff(1:length(options.polys),options.selectedSet));
    data = data(setdiff(1:size(data,1),options.selectedSet),:);
    set(handles.uitable_select,'Data',data);
else
    if ~strcmp(tmp, '') && any(strcmp(tmpAll,tmp))
        % Merge two selections
        inds = find(strcmp(cellstr(data(:,2)), tmp));
        options.meanSpectra(options.selectedSet+1,:) = [];
        options.selectedSpectra{1,inds(1)} = [options.selectedSpectra{1,inds(1)}; options.selectedSpectra{1,inds(2)}];
        options.whichSpectra{1,inds(1)}    = [options.whichSpectra{1,inds(1)}; options.whichSpectra{1,inds(2)}];
        if ~iscell(options.polys{inds(1)})
            if ~iscell(options.polys{1,inds(2)})
                if options.polys{inds(2)}(1) < 0
                    options.polys{1,inds(1)} = [options.polys{1,inds(1)};options.polys{1,inds(2)}];
                else
                    options.polys{1,inds(1)} = {options.polys{1,inds(1)},options.polys{1,inds(2)}};
                end
            else
                tmp = options.polys{inds(2)};
                tmp{length(tmp)+1} = options.polys{inds(1)};
                options.polys{1,inds(1)} = tmp;
            end
        else
            if ~iscell(options.polys{inds(2)})
                tmp = options.polys{inds(1)};
                tmp{length(tmp)+1} = options.polys{inds(2)};
                options.polys{1,inds(1)} = tmp;
            else
                tmp = options.polys{inds(1)};
                lt  = length(tmp);
                for i=1:length(options.polys{inds(2)})
                    tmp{lt+i} = options.polys{inds(2)}{i};
                end
                options.polys{1,inds(1)} = tmp;
            end
        end
        options.selectedNames   = options.selectedNames(1,setdiff(1:length(options.selectedNames),inds(2)));
        options.selectedSpectra = options.selectedSpectra(1,setdiff(1:length(options.selectedSpectra),inds(2)));
        options.whichSpectra    = options.whichSpectra(1,setdiff(1:length(options.whichSpectra),inds(2)));
        options.polys           = options.polys(1,setdiff(1:length(options.polys),inds(2)));
        data{inds(1),3} = round((data{inds(1),3}+data{inds(2),3})/2);
        data{inds(1),4} = round((data{inds(1),4}+data{inds(2),4})/2);
        data{inds(1),5} = data{inds(1),5}+data{inds(2),5};
        data = data(setdiff(1:size(data,1),inds(2)),:);
        set(handles.uitable_select,'Data',data);
        
    else
        options.selectedNames{1,options.selectedSet} = data{options.selectedSet,2};
    end
end
guidata(hObject, handles);
mainPlot(handles,false,false)


%--
function uitable_select_CellSelectionCallback(hObject, eventdata, handles)
global options
options.selectedSet = eventdata.Indices(:,1);


%--
function edit_width_KeyPressFcn(hObject, eventdata, handles)
global options
options.clip = false;
ch = get(handles.fig,'CurrentCharacter');
if ~isempty(ch)
    if ch == 28 || ch == 31
        set(handles.edit_width,'String',max(str2num(get(handles.edit_width,'String'))-1,0));
    elseif ch == 30 || ch == 29
        set(handles.edit_width,'String',str2num(get(handles.edit_width,'String'))+1);
    end
    if ch == 13 || (ch >= 28 && ch <= 31)
        options.imMinMax = [];
        drawnow
        %         plotSpectra(handles)
        mainPlot(handles,false,false)
    end
end


%--
function popupmenu_ch1_Callback(hObject, eventdata, handles)
global options
options.clip = false;
tmp = get(hObject,'Value');
if tmp > size(options.xlabs,2)
    options.wave1 = size(options.xlabs,2)-tmp;
else
    options.wave1 = tmp;
end
options.imMinMax = [];
guidata(hObject, handles);
mainPlot(handles,false,false)
% plotSpectra(handles)


%--
function popupmenu_ch2_Callback(hObject, eventdata, handles)
global options
options.clip = false;
tmp = get(hObject,'Value');
if tmp-1 > size(options.xlabs,2)
    options.wave2 = size(options.xlabs,2)-tmp+1;
else
    options.wave2 = tmp-1;
end
options.imMinMax = [];
guidata(hObject, handles);
mainPlot(handles,false,false)
% plotSpectra(handles)


%--
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
    if pos(1) > options.imMinMax(1)
        options.imMinMax(2) = pos(1);
        set(handles.edit2,'String',pos(1))
    end
elseif sel == 3
    options.imMinMax = [];
end
options.clip = false;
mainPlot(handles,false,false)


%--
function mouseclick_multiSelect(hObject, event_obj, handles)
global options currentDataset
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
lastPoint = false;
if sel == 1
    options.multiSelect    = [options.multiSelect; pos(1,1:2)];
elseif sel == 2
    lastPoint = true;
elseif sel == 3
    options.multiSelect    = [options.multiSelect; pos(1,1:2)];
    lastPoint = true;
end
if lastPoint % Add points to the table
    options.mouse = 6;
    set(handles.button1_2,'Value',0)
    set(handles.button6_2,'Value',1)
    options.polys{length(options.polys)+1} = -options.multiSelect;
    px = size(currentDataset(options.imNo).d);
    spectra = reshape(currentDataset(options.imNo).d,[px(1)*px(2),px(3)]);
    pos = sub2ind([px(1),px(2)],round(options.multiSelect(:,1)),round(options.multiSelect(:,2)));
    spectra = spectra(pos,:);
    options.meanSpectra = [options.meanSpectra; mean(spectra,1)];
    options.selectedSpectra{1,size(options.selectedSpectra,2)+1} = spectra;
    options.selectedNames{1,size(options.selectedNames,2)+1} = [];
    % Tabell-lagring og sletting
    data = get(handles.uitable_select,'Data');
    n_sel = size(data,1);
    w1 = round(options.multiSelect(:,1));
    w2 = round(options.multiSelect(:,2));
    if n_sel == 0
        set(handles.uitable_select,'Data',{1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)})
        options.whichSpectra = {ind2sub([px(1),px(2)],pos)};
    else
        last = max(cell2mat(data(:,1)));
        set(handles.uitable_select,'Data',[data;{last+1, '', round(mean(w2)),round(mean(w1)),size(spectra,1)}])
        options.whichSpectra{1,length(options.whichSpectra)+1} = ind2sub([px(1),px(2)],pos);
    end
    set(handles.setInvert,'Enable','on')
    set(handles.setNA,'Enable','on')
    set(handles.exportSelect,'Enable','on')
end
mainPlot(handles,false,false)


%--
function mouseclick_callback3(hObject, event_obj, handles)
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
if sel < 3
        newSeg = round(pos(1));
        if isempty(options.selectedSegment)
             options.selectedSegment = newSeg;
        else
            if any(options.selectedSegment == newSeg)
                options.selectedSegment = setdiff(options.selectedSegment,newSeg);
            else
                options.selectedSegment = [options.selectedSegment newSeg];
            end
        end
elseif sel == 3
    options.selectedSegment = [];
end
options.clip = false;
mainPlot(handles,false,false)


%--
function plotSpectra(handles)
global options
axes(handles.axes2)
hold off
if options.doEMSC
    xlabs = 1:size(options.emsc_par_names,1);
else
    xlabs = options.xlabs;
end
if options.wave1 > 0 && options.wave2 > 0
    if options.doEMSC
        plot(xlabs, hyspec_mean(options.emsc_parameters(options.imNo).d))
    elseif options.doMCR
        plot(xlabs, options.MCR_S)
    else
        plot(xlabs, options.meanSpectra')
    end
else
    ol1 = []; ol2 = [];
    if options.wave1 < 0
        ol1 = options.loadings(:,-options.wave1);
        ol1 = ol1./norm(ol1).*norm(options.meanSpectra(1,:));
    end
    if options.wave2 < 0
        ol2 = options.loadings(:,-options.wave2);
        ol2 = ol2./norm(ol2).*norm(options.meanSpectra(1,:));
    end
    if options.doEMSC
        plot(xlabs, hyspec_mean(options.emsc_parameters(options.imNo).d))
    elseif options.doMCR
        plot(xlabs, options.MCR_S)
    else
        plot(xlabs, [options.meanSpectra' ol1 ol2])
    end
end
hold on
axis tight
wi   = str2num(get(handles.edit_width,'String'));
data = get(handles.uitable_select,'Data');
if options.doMCR
    tmp = 'legend(''Comp. 1''';
    for i = 2:size(options.MCR_S,1)
        tmp = [tmp ',''Comp. ' num2str(i) ''''];
    end
else
    tmp  = 'legend(''Image''';
end
if ~options.doMCR
    for i=1:(size(options.meanSpectra,1)-1)
        if isempty(data{i,2})
            tmp = [tmp ',''Select. ' num2str(data{i,1}) ''''];
        else
            tmp = [tmp ',''' data{i,2} ''''];
        end
    end
end
if options.showQuantiles == true
%     nq = size(options.quantiles,1);
%     p = length(options.xlabs);
%     for j=1:ceil(nq/2)
%         patch([options.xlabs, options.xlabs(p:-1:1)], ...
%             [options.quantiles(j,:), options.quantiles(end+1-j,(p:-1:1))], ...
%             ones(1,p+p)*-1,'k','EdgeColor','none')
%         alpha(0.05)
%     end
    disp('Not implemented yet')
end
axis tight
if options.wave1 > 0
    plot((xlabs(options.wave1)-wi)*ones(1,2), get(gca,'YLim'),':k')
    plot((xlabs(options.wave1)+wi)*ones(1,2), get(gca,'YLim'),':k')
else
    tmp = [tmp ', ''PC ' num2str(-options.wave1) ''''];
end
if options.wave2 > 0
    plot((xlabs(options.wave2)-wi)*ones(1,2), get(gca,'YLim'),':r')
    plot((xlabs(options.wave2)+wi)*ones(1,2), get(gca,'YLim'),':r')
elseif options.wave2 < 0
    tmp = [tmp ', ''PC ' num2str(-options.wave2) ''''];
end
if xlabs(1)>xlabs(end)
    set(gca,'XDir','rev')
end
set(get(gca,'Children'),'ButtonDownFcn', {@mouseclick_callback,handles})
set(gca,'ButtonDownFcn', {@mouseclick_callback,handles})
tmp = [tmp ');'];
if ~options.doEMSC
    if options.showLegend
        eval(tmp)
    end
else
    ne = size(options.emsc_par_names,1);
    set(handles.axes2, 'XTick',1:ne)
    labels = mat2cell(options.emsc_par_names,ones(ne,1));
    for i=1:ne
        labels{i} = strrep(labels{i}, ' ', '');
    end
    set(handles.axes2, 'XTickLabel', labels)
end


%--
function mouseclick_callback(hObject, event_obj, handles)
%%%%%%%%%%%%%%%%%%%% Her må MCR behandles separat. Vertikal avstand til
%%%%%%%%%%%%%%%%%%%% nærmeste spektrum!
global options
options.clip = false;
options.imMinMax = [];
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
if options.doEMSC
    i = round(pos(1));
else
    [~,i] = min((options.xlabs-round(pos(1))).^2);
end
if options.doMCR
    [~,i] = min((options.MCR_S(:,i)-pos(1,2)).^2);
end
if sel == 1
    options.wave1 = i;
    set(handles.popupmenu_ch1,'Value',options.wave1);
    uicontrol(handles.popupmenu_ch1)
elseif sel == 2
    options.wave2 = i;
    set(handles.popupmenu_ch2,'Value',options.wave2+1);
    uicontrol(handles.popupmenu_ch2)
elseif sel == 3
    options.wave1 = 1;
    set(handles.popupmenu_ch1,'Value',options.wave1);
    options.wave2 = 0;
    set(handles.popupmenu_ch2,'Value',options.wave2+1);
end
guidata(hObject, handles);
options.imMinMax = [];
mainPlot(handles,false,false)


%--
function segment(hObject, i, handles)
global options currentDataset
options.clip = false;
options.selectedSegment = [];
if size(options.meanSpectra,1)>1 || i == 3
    set(handles.endSegment,'Enable','on')
    set(handles.addSegment,'Enable','on')
    axes(handles.axes1)
    xL = get(handles.axes1,'XLim');
    yL = get(handles.axes1,'YLim');
    axes(handles.axes1)
    text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Segmenting', 'FontSize',30,...
        'HorizontalAlignment','center')
    text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Segmenting', 'FontSize',30,...
        'HorizontalAlignment','center','Color',[1 1 1])
    drawnow
    if i == 1 % Nearest neighbour
        if size(options.meanSpectra,1) == 2
            options.segmented = hyspec_segment(currentDataset, options.meanSpectra);
        else
            options.segmented = hyspec_segment(currentDataset, options.meanSpectra(2:end,:));
        end
    end
    if i == 2 % LDA
        if size(options.meanSpectra,1) == 2
            selSpec = options.selectedSpectra;
            thisIm  = currentDataset(options.imNo).d;
            thisIm  = reshape(thisIm,[size(thisIm,1)*size(thisIm,2),size(thisIm,3)]);
            selSpec{2,1} = thisIm(setdiff(1:size(thisIm,1),options.whichSpectra{1}),:);
            options.segmented = hyspec_segment(currentDataset, selSpec,'type',2);
        else
            options.segmented = hyspec_segment(currentDataset, options.selectedSpectra','type',2);
        end
    elseif i == 3 % Qvision
        if size(currentDataset(1).d,3) < 15
            error('Qvision algorithm needs 15 channels (or more)')
        else
            options.segmented = hyspec_segment(currentDataset, [],'type',3);
        end
    elseif i == 4
        CustomRuleCallback
    end
    options.doSegment = true;
    options.doMCR     = false;
    options.doEMSC    = false;
    options.imMinMax  = [];
    set(handles.endSegment,'Checked','on')
    set(handles.emsc,'Checked','off')
    set(handles.viewMCR,'Checked','off')
    mainPlot(handles,true,false)
end

%--
function exportSelect(hObject, eventdata, handles)
global options
n = size(options.meanSpectra,1)-1;
if n > 0
    selected = cell(n,1);
    for i=1:n
        selected{i,1} = struct('Names',options.selectedNames{i}, ...
            'Spectra',options.selectedSpectra{i}, ...
            'Means',options.meanSpectra(i+1,:),...
            'Coordinates',options.whichSpectra{i}, ...
            'Polygons',options.polys{i});
    end
    objName = inputdlg('Choose name:','Save selection(s) workspace');
    if ~isempty(objName) && ~strcmp(objName{1},'')
        eval(['assignin(''base'',''' objName{1} ''', selected)'])
    end
end


%--
function endSegmentation(hObject,eventdata,handles)
global options
options.clip = false;
options.selectedSegment = [];
if options.doSegment
    options.doSegment = false;
    options.imMinMax = [];
    % set(handles.endSegment,'Enable','off')
    set(handles.endSegment,'Checked','off')
    set(handles.addSegment,'Enable','off')
elseif ~isempty(options.segmented)
    options.doSegment = true;
    options.imMinMax = [];
    set(handles.endSegment,'Checked','on')
    set(handles.addSegment,'Enable','on')
end
set(handles.emsc,'Checked','off')
set(handles.viewMCR,'Checked','off')
options.doMCR     = false;
options.doEMSC    = false;
mainPlot(handles,false,false)


%--
function snapshot(hObject,eventdata,handles)
global currentDataset %#ok<NUSED>
objName = inputdlg('Choose name:','Save snapshot to workspace');
if ~isempty(objName) && ~strcmp(objName{1},'')
    eval(['assignin(''base'',''' objName{1} ''', currentDataset)'])
end


% New size for figure
function resizeFigure(hObject,eventdata,handles)
global options
pos = get(handles.fig,'Position');
too_small = false;
if pos(3) < 1000
    pos(3) = 1000;
    too_small = true;
end
if pos(4) < 650
    pos(4) = 650;
    too_small = true;
end
p3 = pos(3)-1000;
p4 = pos(4)-650;
p34 = 520+min(p3,p4);
options.plotArea = p34;
ps = options.plotSize;

if ps == 1
    set(handles.axes1,              'Position', [40 30 p34 p34]);
elseif ps == 2
    p24 = (p34-p34/1.444)/2;
    set(handles.axes1,              'Position', [40+p24 30+p24 p34/1.444 p34/1.444]);
else
    p24 = (p34-p34/2.6)/2;
    set(handles.axes1,              'Position', [40+p24 30+p24 p34/2.6 p34/2.6]);
end
set(handles.axes2,              'Position', [p3+620  30 360 230]);
set(handles.axes3,              'Position', [p3+675 p4+470 250 120]);
set(handles.popupmenu_image,    'Position', [40     p4+580 100 50]);
set(handles.popupmenu_plotsize, 'Position', [40     p4+555 100 50]);
set(handles.edit1,              'Position', [p3+675 p4+590 51 22]);
set(handles.edit2,              'Position', [p3+874 p4+590 51 22]);
set(handles.popupmenu_ch1,      'Position', [p3+620 265 70 21]);
set(handles.popupmenu_ch2,      'Position', [p3+911 265 70 21]);
set(handles.edit_width,         'Position', [p3+770 264 31 22]);
set(handles.text7,              'Position', [p3+803 261 31 22]);
set(handles.panel2,             'Position', [170    p4+570 400 70]);
set(handles.uitable_select,     'Position', [p3+675 pos(4)/2 250 100]);
if too_small
    set(handles.fig, 'Position', pos)
end


%--
function setInvert(hObject,eventdata,handles)
global options currentDataset
ind = options.selectedSet;
if ~isempty(ind)
    X = currentDataset(options.imNo).d;
    [r,c,p] = size(X);
    X = reshape(X,[r*c,p]);
    options.whichSpectra{ind}    = setdiff(1:(r*c),options.whichSpectra{ind});
    options.selectedSpectra{ind} = X(options.whichSpectra{ind},:);
    options.meanSpectra(ind+1,:) = mean(options.selectedSpectra{ind});
    data = get(handles.uitable_select,'Data');
    data{ind,5} = length(options.whichSpectra{ind});
    set(handles.uitable_select,'Data',data)
    mainPlot(handles,true,false)
end


%--
function setNA(hObject,eventdata,handles)
warndlg('This deletes pixels at the same position as the original')
global options currentDataset
ind = options.selectedSet;
if ~isempty(ind)
    for i = 1:length(currentDataset)
        X = currentDataset(i).d;
        [r,c,p] = size(X);
        X = reshape(X,[r*c,p]);
        X(options.whichSpectra{ind},:) = NaN;
        X = reshape(X,[r,c,p]);
        currentDataset(i).d = X;
    end
    mainPlot(handles,true,false)
end


%--
function addSegmentation(hObject,eventdata,handles)
global options currentDataset
Im = currentDataset(options.imNo).d;
Im = reshape(Im, [size(Im,1)*size(Im,2),size(Im,3)]);
segments = options.segmented(options.imNo).d;
nsel = length(options.whichSpectra);
nseg = max(2,nsel);

data = get(handles.uitable_select,'Data');
for i=1:nseg
    inds = find(segments==i);
    options.meanSpectra(nsel+i+1,:)   = mean(Im(inds,:));
    options.selectedSpectra{nsel+i} = Im(inds,:);
    options.selectedNames{nsel+i}   = ['Seg. ' num2str(i)];
    options.whichSpectra{nsel+i}    = inds;
    data(nsel+i,:) = {max(cell2mat(data(:,1)))+1, ['Seg. ' num2str(i)], '', '', length(inds)};
    options.polys{nsel+i} = [];
end
set(handles.uitable_select,'Data',data)
mainPlot(handles,true,false)


% Derivative dialog
function derivativeCallback(hObject, eventdata, handles)
handles.deriv = figure('Position',[250,250,170,170], 'WindowStyle','modal',...
    'Units','pixels', 'MenuBar','none', 'Resize','off', ...
    'Color',handles.BGColor);
handles.popupmenu_derivative = uicontrol(...
    'Parent',handles.deriv,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[20 100 100 50],...
    'String',{'1st derivative','2nd derivative'},...
    'Style','popupmenu',...
    'Value',1,...
    'Tag','popupmenu_derivative');
handles.derText1 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.deriv,...
    'Position',[20 94 35 16],...
    'String','Points',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','derText1');
handles.derText2 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.deriv,...
    'Position',[80 94 61 16],...
    'String','Polynomial',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','derText2');
handles.derEdit1 = uicontrol(...
    'Parent',handles.deriv,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[20 70 51 22],...
    'String','9',...
    'Style','edit',...
    'Tag','derEdit1');
handles.derEdit2 = uicontrol(...
    'Parent',handles.deriv,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[80 70 51 22],...
    'String','3',...
    'Style','edit',...
    'Tag','derEdit2');
handles.derOK1 = uicontrol(...
    'Parent',handles.deriv,...
    'Units','pixels',...
    'Position',[90,20,70,30],...
    'String','OK',...
    'Tag','pushbutton1');
handles.derCancel1 = uicontrol(...
    'Parent',handles.deriv,...
    'Units','pixels',...
    'Callback','close',...
    'Position',[20,20,70,30],...
    'String','Cancel',...
    'Tag','pushbutton1');
set(handles.derCancel1,'Callback','close');
set(handles.derOK1,'Callback',@(hObject,eventdata)derivDerivCallback(hObject,eventdata,handles));
set(handles.popupmenu_derivative,'Callback',@(hObject,eventdata)derivative_change_Callback(hObject,eventdata,handles))

function derivative_change_Callback(hObject,eventdata,handles)
order  = get(handles.popupmenu_derivative,'Value');
if order == 1
    set(handles.derEdit1,'String', num2str(9));
    set(handles.derEdit2,'String', num2str(3));
else
    set(handles.derEdit1,'String', num2str(21));
    set(handles.derEdit2,'String', num2str(3));
end

function derivDerivCallback(hObject,eventdata,handles)
global options currentDataset
order  = get(handles.popupmenu_derivative,'Value');
points = str2num(get(handles.derEdit1,'String'));
poly   = str2num(get(handles.derEdit2,'String'));
close(handles.deriv)
xL = get(handles.axes1,'XLim');
yL = get(handles.axes1,'YLim');
axes(handles.axes1)
text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Preprocessing', 'FontSize',30,...
    'HorizontalAlignment','center')
text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Preprocessing', 'FontSize',30,...
    'HorizontalAlignment','center','Color',[1 1 1])
drawnow
currentDataset = hyspec_derivative(currentDataset, order, ...
    'points', points, 'poly', poly);
options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo).d);
newDataset(handles,options.imNo)



% EMSC dialog
function EMSCCallback(hObject, eventdata, handles)
handles.emsc1 = figure('Position',[250,250,200,170], 'WindowStyle','modal',...
    'Units','pixels', 'MenuBar','none', 'Resize','off', ...
    'Color',handles.BGColor);
handles.popupmenu_emsc = uicontrol(...
    'Parent',handles.emsc1,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[20 100 100 50],...
    'String',{'Baseline', 'Reference', 'Linear', 'Quadratic', ...
    'Cubic', 'Fourth order', 'Fifth order', 'Sixth order'},...
    'Style','popupmenu',...
    'Value',4,...
    'Tag','popupmenu_emsc');
handles.emscText1 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.emsc1,...
    'Position',[20 94 50 16],...
    'String','Reference',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','emscText1');
handles.emscText2 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.emsc1,...
    'Position',[80 94 61 16],...
    'String','Constituent',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','emscText2');
handles.emscText3 = uicontrol(...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Parent',handles.emsc1,...
    'Position',[140 94 61 16],...
    'String','Interferent',...
    'Style','text',...
    'HorizontalAlignment','left',...
    'Tag','emscText3');
handles.emscEdit1 = uicontrol(...
    'Parent',handles.emsc1,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[20 70 51 22],...
    'String','0',...
    'Style','edit',...
    'Tag','emscEdit1');
handles.emscEdit2 = uicontrol(...
    'Parent',handles.emsc1,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[80 70 51 22],...
    'String','',...
    'Style','edit',...
    'Tag','emscEdit2');
handles.emscEdit3 = uicontrol(...
    'Parent',handles.emsc1,...
    'BackgroundColor',handles.BGColor,'ForegroundColor',handles.FGColor,...
    'Position',[140 70 51 22],...
    'String','',...
    'Style','edit',...
    'Tag','emscEdit3');
handles.emscOK1 = uicontrol(...
    'Parent',handles.emsc1,...
    'Units','pixels',...
    'Position',[90,20,70,30],...
    'String','OK',...
    'Tag','emscOK1');
handles.emscCancel1 = uicontrol(...
    'Parent',handles.emsc1,...
    'Units','pixels',...
    'Callback','close',...
    'Position',[20,20,70,30],...
    'String','Cancel',...
    'Tag','emscCancel1');
set(handles.emscCancel1,'Callback',@(hObject,eventdata)emscClose(hObject,eventdata,handles));
set(handles.emscOK1,'Callback',@(hObject,eventdata)emscEmscCallback(hObject,eventdata,handles));

function emscClose(hObject,eventdata,handles)
global options currentDataset
close
options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo));
newDataset(handles,options.imNo)

function emscEmscCallback(hObject,eventdata,handles)
global options currentDataset
order     = get(handles.popupmenu_emsc,'Value');
reference = str2num(get(handles.emscEdit1,'String'));
constituent = get(handles.emscEdit2,'String');
interferent = get(handles.emscEdit3,'String');
close
xL = get(handles.axes1,'XLim');
yL = get(handles.axes1,'YLim');
axes(handles.axes1)
text(xL(1)+range(xL)/2, yL(1)+range(yL)/2, 'Preprocessing', 'FontSize',30,...
    'HorizontalAlignment','center')
text(xL(1)+range(xL)/2.01, yL(1)+range(yL)/2.01, 'Preprocessing', 'FontSize',30,...
    'HorizontalAlignment','center','Color',[1 1 1])
drawnow
tmp = '[currentDataset, options.emsc_parameters, options.emsc_par_names] = hyspec_emsc(currentDataset, ''terms'', order';
if reference > 0
    ref = options.meanSpectra(reference,:); %#ok<NASGU>
    tmp = [tmp ', ''reference'', ref'];
end
if ~isempty(constituent)
    eval(['const = options.meanSpectra([' constituent '],:);'])
    tmp = [tmp ', ''constituent'', const'];
end
if ~isempty(interferent)
    eval(['inter = options.meanSpectra([' interferent '],:);'])
    tmp = [tmp ', ''interferent'', inter'];
end
tmp = [tmp ');'];
eval(tmp)
options.meanSpectra(1,:) = hyspec_mean(currentDataset(options.imNo).d);
set(handles.emsc,'Enable','on')
set(handles.emscToIm,'Enable','on')
set(handles.endSegment,'Checked','off')
set(handles.viewMCR,'Checked','off')
options.doSegment = false;
options.doMCR     = false;

newDataset(handles,options.imNo)


% Plot EMSC parameter images
function emsc_plot_Callback(hObject,eventdata,handles)
global options
if options.doEMSC
    set(handles.emsc,'Checked','off')
    options.doEMSC = false;
else
    set(handles.emsc,'Checked','on')
    options.doEMSC = true;
    options.wave1  = 1;
    options.wave2  = 0;
end
set(handles.endSegment,'Checked','off')
set(handles.viewMCR,'Checked','off')
options.doSegment = false;
options.doMCR     = false;
newDataset(handles,options.imNo)


% Plot MCR concentration images
function mcr_view(hObject,eventdata,handles)
global options
if options.doMCR
    set(handles.viewMCR,'Checked','off')
    options.doMCR = false;
else
    set(handles.viewMCR,'Checked','on')
    options.doMCR  = true;
    options.wave1  = 1;
    options.wave2  = 0;
end
set(handles.emsc,'Checked','off')
set(handles.endSegment,'Checked','off')
options.doSegment = false;
options.doEMSC    = false;
newDataset(handles,options.imNo)


% Promote EMSC parameter images to images
function emsc_to_im_Callback(hObject,eventdata,handles)
global currentDataset options
currentDataset = options.emsc_parameters;
options.xlabs = 1:size(options.emsc_par_names,1);
options.emsc_par_names = [];
options.doEMSC = false;
set(handles.emsc,'Enable','off')
set(handles.emscToIm,'Enable','off')
newDataset(handles)


% Reset parameters
function resetParam(handles,tull1,tull2)
global options
options.wave1 = 1;
options.wave2 = 0;
options.meanSpectra     = [];
options.selectedSpectra = cell(0,0);
options.selectedNames   = cell(0,0);
options.whichSpectra    = cell(0,0);
options.selectedSet     = 1;
options.segmented = [];
options.doSegment = false;
options.doEMSC    = false;
options.doMCR     = false;
options.emsc_parameters = [];
options.emsc_par_names  = [];
options.polys = [];
set(handles.emsc,'Checked','off')
set(handles.endSegment,'Checked','off')
set(handles.viewMCR,'Checked','off')
set(handles.uitable_select, 'Data', [])


% Round to given number of decimals
function x = roundn(x,n)
x = round(x*10.^n)./(10.^n);


% Change plot controls
function showSelect(hObject,eventdata,handles)
global options
if options.showSelections
    set(handles.showSelect,'Checked','off');
else
    set(handles.showSelect,'Checked','on');
end
options.showSelections = ~options.showSelections;
mainPlot(handles,false,false)

function showQuant(hObject,eventdata,handles)
global options
if options.showQuantiles
    set(handles.showQuant,'Checked','off');
else
    set(handles.showQuant,'Checked','on');
end
options.showQuantiles  = ~options.showQuantiles;
mainPlot(handles,false,false)

function showLegend(hObject,eventdata,handles)
global options
if options.showLegend
    set(handles.showLegend,'Checked','off');
else
    set(handles.showLegend,'Checked','on');
end
options.showLegend     = ~options.showLegend;
mainPlot(handles,false,false)


% Clip histogram 1%
function clip1p(hObject,eventdata,handles)
global options
options.clip = ~options.clip;
mainPlot(handles,false,false)
