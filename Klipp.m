function varargout = Klipp(varargin)
% KLIPP MATLAB code for Klipp.fig
%      KLIPP, by itself, creates a new KLIPP or raises the existing
%      singleton*.
%
%      H = KLIPP returns the handle to a new KLIPP or the handle to
%      the existing singleton*.
%
%      KLIPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KLIPP.M with the given input arguments.
%
%      KLIPP('Property','Value',...) creates a new KLIPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Klipp_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Klipp_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Klipp

% Last Modified by GUIDE v2.5 09-Jul-2021 14:39:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Klipp_OpeningFcn, ...
                   'gui_OutputFcn',  @Klipp_OutputFcn, ...
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


% --- Executes just before Klipp is made visible.
function Klipp_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Klipp (see VARARGIN)

% Choose default command line output for Klipp
handles.output = hObject;

load('protocol');
handles.protocol=protocol;
set(handles.editPreStart,'String',num2str(handles.protocol.preStart*1000));
set(handles.editDurBlock,'String',num2str(handles.protocol.durBlock*1000));
set(handles.editStimTime,'String',num2str(handles.protocol.stimTime*1000));
set(handles.editBaseline,'String',num2str(handles.protocol.baseline*1000));
set(handles.editNBlocks,'String',num2str(handles.protocol.N));

if nargin>3
    handles.time=varargin{1};
    handles.trace=varargin{2};
    handles.data=varargin{3};
    handles.listCh=varargin{4};
    handles.unitY=varargin{5};
    handles.PathName=pwd;
    handles.FileName='tempData.mat';
    handles.check=zeros(size(handles.data,1),handles.protocol.N,length(handles.listCh));
    handles.include=ones(size(handles.data,1),handles.protocol.N,length(handles.listCh));
else
    [handles.FileName,handles.PathName] = uigetfile('*.mat','Choose a file');
    load(fullfile(handles.PathName,handles.FileName));
    handles.time=time;
    handles.trace=vector;
    handles.listCh=listCh;
    handles.unitY=unitY;
    if exist('data','var')
        handles.data=data;
    else 
        handles.data=vector; %in case there is no data variable, than the vector becomes the data variable itself.
    end
    if exist('include','var')
        handles.include=include;
        % activates the ffTrace button.
        set(handles.toggleFinal,'Enable','on');
        set(handles.pushSave,'Enable','on');
        set(handles.pushExportBlock,'Enable','on');
        set(handles.pushExportAvr,'Enable','on');
        set(handles.pushPSPone,'Enable','on');
    else
        handles.include=ones(size(handles.data,1),handles.protocol.N,length(handles.listCh));
    end
    if exist('check','var')
        handles.check=check;
    else
        handles.check=zeros(size(handles.data,1),handles.protocol.N,length(handles.listCh));
    end
end

%sets the initial settings. 
set(handles.checkTraces,'Value',1);
wakeSelectionBox(hObject,handles);
handles.Ch=1;
handles.block=1;
handles.cutTrace=[];
handles.cutData=[];
handles.newTime=[];
handles.selectedTrace=1;

%marker for the cutting process.
handles.cut=0;
handles.cutType=0; %resets teh cut type. 

%checks if there is more than one channel. 
if length(handles.listCh)>1
     set(handles.textChannel,'Visible','on');
     set(handles.pushChMinus,'Visible','on');
     set(handles.pushChPlus,'Visible','on');
     set(handles.editCh,'Visible','On');
     set(handles.textChN,'Visible','On');
     [~,~,Ch]=size(handles.trace);
     set(handles.editCh,'String',num2str(handles.Ch));
     set(handles.textChN,'String',strcat('/',num2str(Ch)));
     set(handles.textRealCh,'String',strcat('Ch:',handles.listCh(handles.Ch)));
end

%initializes the "clipping log" menu (in the off mode).
set(handles.editBeforeStim,'Enable','off');
set(handles.editAfterStim,'Enable','off');
set(handles.pushPreview,'Enable','off');
set(handles.pushCut2,'Enable','off');

%initialize the includeShoulders vector flags. 
handles.includeShoulders=ones(size(handles.data,1),2,length(handles.listCh)); %there are only two columns: 1 for pre and 1 for post.

%initializes the central figure.
plotterKlipp(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Klipp wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Klipp_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function editPreStart_Callback(hObject, eventdata, handles)
% hObject    handle to editPreStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPreStart as text
%        str2double(get(hObject,'String')) returns contents of editPreStart as a double
handles.protocol.preStart=str2num(get(hObject,'String'))/1000;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editPreStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPreStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDurBlock_Callback(hObject, eventdata, handles)
% hObject    handle to editDurBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDurBlock as text
%        str2double(get(hObject,'String')) returns contents of editDurBlock as a double
handles.protocol.durBlock=str2num(get(hObject,'String'))/1000;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editDurBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDurBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStimTime_Callback(hObject, eventdata, handles)
% hObject    handle to editStimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStimTime as text
%        str2double(get(hObject,'String')) returns contents of editStimTime as a double
handles.protocol.stimTime=str2num(get(hObject,'String'))/1000;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editStimTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to editBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBaseline as text
%        str2double(get(hObject,'String')) returns contents of editBaseline as a double
handles.protocol.baseline=str2num(get(hObject,'String'))/1000;
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editBaseline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editNBlocks_Callback(hObject, eventdata, handles)
% hObject    handle to editNBlocks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNBlocks as text
%        str2double(get(hObject,'String')) returns contents of editNBlocks as a double
handles.protocol.N=str2num(get(hObject,'String'));
handles.include=ones(size(handles.data,1),handles.protocol.N,length(handles.listCh));
handles.check=zeros(size(handles.data,1),handles.protocol.N,length(handles.listCh));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editNBlocks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNBlocks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushSaveProt.
function pushSaveProt_Callback(hObject, eventdata, handles)
% hObject    handle to pushSaveProt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
protocol=handles.protocol;
uisave('protocol','protocol');

% --- Executes on button press in pushLoadProt.
function pushLoadProt_Callback(hObject, eventdata, handles)
% hObject    handle to pushLoadProt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName] = uigetfile('*.mat','Choose a file');
load(fullfile(PathName,FileName));
handles.protocol=protocol;
handles.include=ones(size(handles.data,1),handles.protocol.N,length(handles.listCh));
handles.check=zeros(size(handles.data,1),handles.protocol.N,length(handles.listCh));
updateClippingStatus(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in toggleCut.
function toggleCut_Callback(hObject, eventdata, handles)
% hObject    handle to toggleCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleCut
handles.cutType=1;
wakeSlider(hObject,handles);
[handles]=klippProcessor(hObject,handles);
[handles]=includerFcn(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in checkCheck.
function checkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to checkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkCheck
if get(handles.toggleCut,'Value')
    if get(handles.checkSelection,'Value') %when selection button is on.
        if get(hObject,'Value')
           handles.check(handles.selectedTrace,handles.block,handles.Ch)=1; 
        else
            handles.check(handles.selectedTrace,handles.block,handles.Ch)=0; 
        end
    else %when selection button is off.
        if get(hObject,'Value')
           handles.check(:,handles.block,handles.Ch)=1; 
        else
            handles.check(:,handles.block,handles.Ch)=0; 
        end
    end
else
    if get(handles.checkSelection,'Value')
        if get(hObject,'Value')
           handles.check(handles.selectedTrace,:,handles.Ch)=1; 
        else
            handles.check(handles.selectedTrace,:,handles.Ch)=0; 
        end
    else
        if get(hObject,'Value')
           handles.check(:,:,handles.Ch)=1; 
        else
            handles.check(:,:,handles.Ch)=0; 
        end
    end
end
guidata(hObject,handles);

% --- Executes on button press in checkTraces.
function checkTraces_Callback(hObject, eventdata, handles)
% hObject    handle to checkTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkTraces
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in checkExcAPs.
function checkExcAPs_Callback(hObject, eventdata, handles)
% hObject    handle to checkExcAPs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkExcAPs
[handles]=klippProcessor(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

function editTreshold_Callback(hObject, eventdata, handles)
% hObject    handle to editTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTreshold as text
%        str2double(get(hObject,'String')) returns contents of editTreshold as a double
[handles]=klippProcessor(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editTreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkSelection.
function checkSelection_Callback(hObject, eventdata, handles)
% hObject    handle to checkSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSelection
wakeSelectionBox(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);


function editNTrace_Callback(hObject, eventdata, handles)
% hObject    handle to editNTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNTrace as text
%        str2double(get(hObject,'String')) returns contents of editNTrace as a double
selectedTrace=round(str2num(get(hObject,'String')));
if selectedTrace>0 && selectedTrace<size(handles.data,1)
    handles.selectedTrace=selectedTrace;
else
    disp('Trace number out of bounds!');
end
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editNTrace_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushDown.
function pushDown_Callback(hObject, eventdata, handles)
% hObject    handle to pushDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedTrace=handles.selectedTrace-1;
[handles]=selectionModeKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in pushUp.
function pushUp_Callback(hObject, eventdata, handles)
% hObject    handle to pushUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.selectedTrace=handles.selectedTrace+1;
[handles]=selectionModeKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in radioInc.
function radioInc_Callback(hObject, eventdata, handles)
% hObject    handle to radioInc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioInc
if get(hObject,'Value')
    if get(handles.toggleFinal,'Value')
        handles.include(:,handles.block,handles.Ch)=1;
    else
        if get(handles.toggleCut,'Value')
           handles.include(handles.selectedTrace,handles.block,handles.Ch)=1;
        else
           handles.include(handles.selectedTrace,:,handles.Ch)=1;
        end
    end
else
    if get(handles.toggleFinal,'Value')
        handles.include(:,handles.block,handles.Ch)=0;
    else
        if get(handles.toggleCut,'Value')
            handles.include(handles.selectedTrace,handles.block,handles.Ch)=0;
        else
            handles.include(handles.selectedTrace,:,handles.Ch)=0;
        end
    end
end
[handles]=klippProcessor(hObject,handles);
[handles]=includerFcn(hObject,handles);
handles.cut=1;
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in radioExc.
function radioExc_Callback(hObject, eventdata, handles)
% hObject    handle to radioExc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioExc
if get(hObject,'Value')
    if get(handles.toggleFinal,'Value')
        handles.include(:,handles.block,handles.Ch)=0;
    else
        if get(handles.toggleCut,'Value')
           handles.include(handles.selectedTrace,handles.block,handles.Ch)=0;
        else
           handles.include(handles.selectedTrace,:,handles.Ch)=0;
        end
    end
else
    if get(handles.toggleFinal,'Value')
        handles.include(:,handles.block,handles.Ch)=1;
    else
        if get(handles.toggleCut,'Value')
            handles.include(handles.selectedTrace,handles.block,handles.Ch)=1;
        else
            handles.include(handles.selectedTrace,:,handles.Ch)=1;
        end
    end
end
[handles]=klippProcessor(hObject,handles);
[handles]=includerFcn(hObject,handles);
handles.cut=1;
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in pushChMinus.
function pushChMinus_Callback(hObject, eventdata, handles)
% hObject    handle to pushChMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.Ch>1,
    handles.Ch=handles.Ch-1;
end
if handles.Ch==1,
    set(handles.pushChMinus,'Enable','off');
end
if handles.Ch<length(handles.listCh)
    set(handles.pushChPlus,'Enable','on');
end
set(handles.editCh,'String',num2str(handles.Ch));
set(handles.textRealCh,'String',strcat('Ch:',handles.listCh{handles.Ch}));
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in pushChPlus.
function pushChPlus_Callback(hObject, eventdata, handles)
% hObject    handle to pushChPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLABsei
% lá...
% handles    structure with handles and user data (see GUIDATA)
if handles.Ch<length(handles.listCh),
    handles.Ch=handles.Ch+1;
end
if handles.Ch==length(handles.listCh),
    set(handles.pushChPlus,'Enable','off');
end
if handles.Ch>1,
    set(handles.pushChMinus,'Enable','on');
end
set(handles.editCh,'String',num2str(handles.Ch));
set(handles.textRealCh,'String',strcat('Ch:',handles.listCh{handles.Ch}));
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);


function editCh_Callback(hObject, eventdata, handles)
% hObject    handle to editCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCh as text
%        str2double(get(hObject,'String')) returns contents of editCh as a double
Ch=round(str2num(get(hObject,'String')));
if Ch<0 && Ch<length(listCh)
    handles.Ch=Ch;
else 
    disp('Channel number out of bounds!');
end
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editCh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function sliderBlock_Callback(hObject, eventdata, handles)
% hObject    handle to sliderBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.block=round(get(hObject,'Value'));
set(handles.editBlockN,'String',num2str(handles.block));
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderBlock_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editBlockN_Callback(hObject, eventdata, handles)
% hObject    handle to editBlockN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBlockN as text
%        str2double(get(hObject,'String')) returns contents of editBlockN as a double
handles.block=str2num(get(hObject,'String'));
if handles.block>handles.protocol.N
    handles.block=handles.protocol.N;
    set(handles.editBlockN,'String',num2str(handles.block));
elseif handles.block<1
    handles.block=1;
    set(handles.editBlockN,'String',num2str(handles.block));
end
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editBlockN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBlockN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkNorm.
function checkNorm_Callback(hObject, eventdata, handles)
% hObject    handle to checkNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkNorm
[handles]=plotterKlipp(hObject,handles);
guidata(hObject, handles);


% --- Executes on button press in toggleFinal.
function toggleFinal_Callback(hObject, eventdata, handles)
% hObject    handle to toggleFinal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of toggleFinal
[handles]=wakeFFTrace(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);


% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oldKids = get(gca,'Children');

% make new figure and new axes
figure;
h = axes;

% put old children in new axes
copyobj(oldKids,h);


% --- Executes on button press in pushSave.
function pushSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.cut
    originProg='Klipp';
    time=handles.time;
    listCh=handles.listCh;
    vector=handles.finalTrace; %average result vectors. 
    data=handles.data; %full initial dataset.
    cutData=handles.finalData; %finalData is the result of the cuts, but also considering the include and AP/outliers matrices. 
    cutTime=handles.newTime;
    include=handles.include;
    check=handles.check;
    unitY=handles.unitY;
    uisave({'originProg','time','data','cutData','cutTime','listCh','vector','include','check','unitY'},fullfile(handles.PathName,handles.FileName));
else
    disp('Data has not been cut.');
end

% --- Executes on button press in pushExportBlock.
function pushExportBlock_Callback(hObject, eventdata, handles)
% hObject    handle to pushExportBlock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stimTime=handles.protocol.stimTime;
PSPlab(handles.newTime,handles.finalTrace(handles.block,:,handles.Ch),handles.unitY,stimTime);

% --- Executes on button press in pushExportAvr.
function pushExportAvr_Callback(hObject, eventdata, handles)
% hObject    handle to pushExportAvr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stimTime=handles.protocol.stimTime;
PSPlab(handles.newTime,handles.ffTrace(:,handles.Ch)',handles.unitY,stimTime);

% --- Executes on button press in pushCheckboard.
function pushCheckboard_Callback(hObject, eventdata, handles)
% hObject    handle to pushCheckboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CheckboardFcn(handles.check,handles.Ch);


% --- Executes on button press in pushIncboard.
function pushIncboard_Callback(hObject, eventdata, handles)
% hObject    handle to pushIncboard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkExcAPs,'Value'),
    inc=handles.include & ~handles.AP;
else
    inc=handles.include;
end
CheckboardFcn(inc,handles.Ch);


% --- Executes on button press in pushPSPone.
function pushPSPone_Callback(hObject, eventdata, handles)
% hObject    handle to pushPSPone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oldKids = get(gca,'Children');
if strcmp(handles.unitY,'V'),
    trace=oldKids(1).YData/1000;
else
    trace=oldKids(1).YData/1000000000000;
end
time=oldKids.XData;
time=time/1000;
stimTime=handles.protocol.stimTime;
PSPlab(time,trace,handles.unitY,stimTime);


% --- Executes on button press in pushBatchPSP.
function pushBatchPSP_Callback(hObject, eventdata, handles)
% hObject    handle to pushBatchPSP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PSPhandles.cutData=handles.finalData; %finalData is the result of the cuts, but also considering the include and AP/outliers matrices. 
PSPhandles.cutTime=handles.newTime;
PSPhandles.unitY=handles.unitY;
PSPhandles.listCh=handles.listCh;
PSPhandles.originProg='KlippPSP';

[FileName,PathName]= uigetfile({'*.mat'},'Select the settings file');
fullnameSettings=fullfile(PathName,FileName);  
try
    load(fullnameSettings);
catch
    error('Could not load the file');
end
%calls the batch function:
PSPext(PSPhandles,PSPsettings);


% --- Executes on button press in pushLoadLog.
function pushLoadLog_Callback(hObject, eventdata, handles)
% hObject    handle to pushLoadLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try
    times = logRappReader;
    handles.stimtimes = times(2:end); 
    disp('File successfully loaded');
    set(handles.editBeforeStim,'Enable','on');
    set(handles.editAfterStim,'Enable','on');
    handles.defaultTime=round(mean(diff(handles.stimtimes)),1)/2;
    handles.minTime=min(diff(handles.stimtimes));
    set(handles.editBeforeStim,'String',num2str(handles.defaultTime*1000));
    set(handles.editAfterStim,'String',num2str(handles.defaultTime*1000));
    handles.cutType=2; %reports that it is the second type of cutting method (using rapp log). 
    set(handles.editPreStart,'Enable','off');
    set(handles.editDurBlock,'Enable','off');
    set(handles.editStimTime,'Enable','off');
    set(handles.editNBlocks,'Enable','off');
    set(handles.pushSaveProt,'Enable','off');
    set(handles.pushLoadProt,'Enable','off');
    set(handles.toggleCut,'Enable','off');
    set(handles.pushPreview,'Enable','on');
    set(handles.pushCut2,'Enable','on');
    set(handles.editBaseline,'String',num2str(round(handles.stimtimes(1)*0.95,2)*1000));
    handles.protocol.baseline=round(handles.stimtimes(1)*0.95,2);
    handles.protocol.N=length(handles.stimtimes);
    handles.protocol.stimTime = handles.defaultTime;
    
    handles.include=ones(size(handles.data,1),length(handles.stimtimes),length(handles.listCh));
    handles.check=zeros(size(handles.data,1),length(handles.stimtimes),length(handles.listCh));
% catch 
%     disp('Cannot open the log file');
% end

guidata(hObject,handles);



function editBeforeStim_Callback(hObject, eventdata, handles)
% hObject    handle to editBeforeStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editBeforeStim as text
%        str2double(get(hObject,'String')) returns contents of editBeforeStim as a double

% --- Executes during object creation, after setting all properties.
function editBeforeStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editBeforeStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editAfterStim_Callback(hObject, eventdata, handles)
% hObject    handle to editAfterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAfterStim as text
%        str2double(get(hObject,'String')) returns contents of editAfterStim as a double


% --- Executes during object creation, after setting all properties.
function editAfterStim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAfterStim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushCut2.
function pushCut2_Callback(hObject, eventdata, handles)
% hObject    handle to pushCut2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of pushCut2
handles.cut=1;
handles.protocol2.stimtimes=handles.stimtimes;
handles.protocol2.beforeStim=str2num(get(handles.editBeforeStim,'String'))/1000;
handles.protocol2.afterStim=str2num(get(handles.editAfterStim,'String'))/1000;

set(handles.editBaseline,'String',num2str(round(handles.protocol2.beforeStim*0.95,2)*1000));
handles.protocol.baseline=round(handles.protocol2.beforeStim*0.95,2);

wakeSlider(hObject,handles);
[handles]=klippProcessor(hObject,handles);
[handles]=includerFcn(hObject,handles);
[handles]=plotterKlipp(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in pushPreview.
function pushPreview_Callback(hObject, eventdata, handles)
% hObject    handle to pushPreview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
beforeStim=str2num(get(handles.editBeforeStim,'String'))/1000;
afterStim=str2num(get(handles.editAfterStim,'String'))/1000;

[handles]=plotterKlipp(hObject,handles);
yl=ylim;
for i=1:length(handles.stimtimes)
   plot([handles.stimtimes(i)*1000 handles.stimtimes(i)*1000],yl,'r');
   plot([(handles.stimtimes(i)-beforeStim)*1000 (handles.stimtimes(i)-beforeStim)*1000],yl,'--g');
   plot([(handles.stimtimes(i)+afterStim)*1000 (handles.stimtimes(i)+afterStim)*1000],yl,'--g');
end