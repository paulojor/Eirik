function varargout = PSPlab(varargin)
% PSPLAB MATLAB code for PSPlab.fig
%      PSPLAB, by itself, creates a new PSPLAB or raises the existing
%      singleton*.
%
%      H = PSPLAB returns the handle to a new PSPLAB or the handle to
%      the existing singleton*.
%
%      PSPLAB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PSPLAB.M with the given input arguments.
%
%      PSPLAB('Property','Value',...) creates a new PSPLAB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PSPlab_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PSPlab_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PSPlab

% Last Modified by GUIDE v2.5 05-Mar-2021 14:25:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PSPlab_OpeningFcn, ...
                   'gui_OutputFcn',  @PSPlab_OutputFcn, ...
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


% --- Executes just before PSPlab is made visible.
function PSPlab_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PSPlab (see VARARGIN)

% Choose default command line output for PSPlab
handles.output = hObject;

handles.stimTime=1000; %default number when no information about stimulus time is given (in ms). 
handles.baselineTime=NaN;
handles.artifactTime=0; %default no artifat time. The user has to change this value. 
handles.flims=[];

if nargin>3
    if isrow(varargin{1}) && length(size(varargin{2}))<=3, %checks if the two inpus are two rows of data;
        handles.time=varargin{1}*1000; %in ms.
        handles.trace=varargin{2};
        handles.unitY=varargin{3};
        %converts to the right scale:
        if strcmp(handles.unitY,'V'),
            handles.trace=handles.trace*1000;
        else
            handles.trace=handles.trace*1000000000000;
        end
        
        if length(size(handles.trace))>2,
             set(handles.textChannel,'Visible','on');
             set(handles.pushChMinus,'Visible','on');
             set(handles.pushChPlus,'Visible','on');
             set(handles.editCh,'Visible','On');
             set(handles.textChN,'Visible','On');
             [~,~,Ch]=size(handles.trace);
             set(handles.textChN,'String',strcat('/',num2str(Ch)));
             handles.Ch=1;
             handles.traceS=handles.trace;
             handles.trace=handles.trace(1,:,handles.Ch);
        end
        set(handles.editStimTime,'String',num2str(handles.stimTime));
        set(handles.editBaseline,'String',num2str(handles.stimTime*0.95));
    end
    if nargin>6
        if ~isempty(varargin{4}),
             handles.stimTime=varargin{4}*1000; %converted to ms.
             if length(handles.stimTime)==1,
                 handles.stimTimeN=1;
                 set(handles.editStimTime,'String',num2str(handles.stimTime));
                 set(handles.editBaseline,'String',num2str(handles.stimTime*0.95));
             else
                 handles.stimTimeVector=handles.stimTime;
                 handles.stimTime=handles.stimTime(1);
                 handles.stimTimeN=1;
                 set(handles.textStimN,'String',strcat('1/',num2str(length(handles.stimTimeVector))));
                 set(handles.editStimTime,'String',num2str(handles.stimTime));
                 set(handles.editBaseline,'String',num2str(round(handles.stimTime*0.95,2)));
                 set(handles.textStim,'Visible','on');
                 set(handles.pushSMinus,'Visible','on');
                 set(handles.pushSPlus,'Visible','on');
             end
        end
    end
end

set(handles.editStartBaseline,'String','0');
set(handles.editEndTime,'String',num2str(handles.time(end)));
set(handles.editArtifact,'String','0');
handles.endTime=str2num(get(handles.editEndTime,'String'));
handles.baselineTimeStart=str2num(get(handles.editStartBaseline,'String'));
handles.baselineTime=str2num(get(handles.editBaseline,'String'));



% Update handles structure
guidata(hObject, handles);

%opens figure 1 interface. 
[handles]=plotterPSP(hObject,handles);

% UIWAIT makes PSPlab wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PSPlab_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editWindow_Callback(hObject, eventdata, handles)
% hObject    handle to editWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editWindow as text
%        str2double(get(hObject,'String')) returns contents of editWindow as a double
[handles]=plotterPSP(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radioFilterNone.
function radioFilterNone_Callback(hObject, eventdata, handles)
% hObject    handle to radioFilterNone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFilterNone
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in radioFilterFlat.
function radioFilterFlat_Callback(hObject, eventdata, handles)
% hObject    handle to radioFilterFlat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioFilterFlat
[handles]=plotterPSP(hObject,handles);



function editStimTime_Callback(hObject, eventdata, handles)
% hObject    handle to editStimTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStimTime as text
%        str2double(get(hObject,'String')) returns contents of editStimTime as a double
handles.stimTime=str2double(get(handles.editStimTime,'String'));
set(handles.editBaseline,'String',num2str(round(handles.stimTime*0.95,2)));
handles.baselineTime=str2double(get(handles.editBaseline,'String'));
handles.baselineTimeStart=str2double(get(handles.editStartBaseline,'String'));
if handles.baselineTime-handles.baselineTimeStart<length(handles.time)*0.01*(handles.time(2)-handles.time(1)),
    handles.baselineTimeStart=handles.baselineTime-length(handles.time)*0.01*(handles.time(2)-handles.time(1));
    set(handles.editStartBaseline,'String',num2str(round(handles.baselineTimeStart,2)));
end
[handles]=plotterPSP(hObject,handles);



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



function editEndTime_Callback(hObject, eventdata, handles)
% hObject    handle to editEndTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editEndTime as text
%        str2double(get(hObject,'String')) returns contents of editEndTime as a double
handles.endTime=str2double(get(hObject,'String'));
[handles]=plotterPSP(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editEndTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editEndTime (see GCBO)
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
handles.baselineTime=str2double(get(hObject,'String'));
[handles]=plotterPSP(hObject,handles);


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


% --- Executes on button press in checkPeak.
function checkPeak_Callback(hObject, eventdata, handles)
% hObject    handle to checkPeak (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkPeak
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in checkHalfwidth.
function checkHalfwidth_Callback(hObject, eventdata, handles)
% hObject    handle to checkHalfwidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkHalfwidth
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in checkRiseTime.
function checkRiseTime_Callback(hObject, eventdata, handles)
% hObject    handle to checkRiseTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkRiseTime
[handles]=plotterPSP(hObject,handles);


function editRiseMin_Callback(hObject, eventdata, handles)
% hObject    handle to editRiseMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRiseMin as text
%        str2double(get(hObject,'String')) returns contents of editRiseMin as a double
[handles]=plotterPSP(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editRiseMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRiseMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRiseMax_Callback(hObject, eventdata, handles)
% hObject    handle to editRiseMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRiseMax as text
%        str2double(get(hObject,'String')) returns contents of editRiseMax as a double
[handles]=plotterPSP(hObject,handles);


% --- Executes during object creation, after setting all properties.
function editRiseMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRiseMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to editStartBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartBaseline as text
%        str2double(get(hObject,'String')) returns contents of editStartBaseline as a double
handles.baselineTimeStart=str2double(get(handles.editStartBaseline,'String'));
handles.baselineTime=str2double(get(handles.editBaseline,'String'));
if handles.baselineTime-handles.baselineTimeStart<length(handles.time)*0.01*(handles.time(2)-handles.time(1)),
    handles.baselineTimeStart=handles.baselineTime-length(handles.time)*0.01*(handles.time(2)-handles.time(1));
    set(handles.editStartBaseline,'String',num2str(round(handles.baselineTimeStart,2)));
end
[handles]=plotterPSP(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editStartBaseline_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkBaseline.
function checkBaseline_Callback(hObject, eventdata, handles)
% hObject    handle to checkBaseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBaseline
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in checkStimulus.
function checkStimulus_Callback(hObject, eventdata, handles)
% hObject    handle to checkStimulus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkStimulus
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in checkEnd.
function checkEnd_Callback(hObject, eventdata, handles)
% hObject    handle to checkEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkEnd
[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in checkNorm.
function checkNorm_Callback(hObject, eventdata, handles)
% hObject    handle to checkNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkNorm
fig=findobj('type','figure','number',1);
if ~isempty(fig),
    figure(1);
    clf;
end
[handles]=plotterPSP(hObject,handles);



function editAmpMethod_Callback(hObject, eventdata, handles)
% hObject    handle to editAmpMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAmpMethod as text
%        str2double(get(hObject,'String')) returns contents of editAmpMethod as a double
[handles]=plotterPSP(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editAmpMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAmpMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editSDMethod_Callback(hObject, eventdata, handles)
% hObject    handle to editSDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSDMethod as text
%        str2double(get(hObject,'String')) returns contents of editSDMethod as a double
[handles]=plotterPSP(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editSDMethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkLatency.
function checkLatency_Callback(hObject, eventdata, handles)
% hObject    handle to checkLatency (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkLatency
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in checkSD.
function checkSD_Callback(hObject, eventdata, handles)
% hObject    handle to checkSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSD
[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in radioAmpMethod.
function radioAmpMethod_Callback(hObject, eventdata, handles)
% hObject    handle to radioAmpMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioAmpMethod
[handles]=plotterPSP(hObject,handles);

% --- Executes on button press in radioSDMethod.
function radioSDMethod_Callback(hObject, eventdata, handles)
% hObject    handle to radioSDMethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioSDMethod
[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in pushSMinus.
function pushSMinus_Callback(hObject, eventdata, handles)
% hObject    handle to pushSMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimTimeN=handles.stimTimeN-1;
handles.stimTime=handles.stimTimeVector(handles.stimTimeN);
set(handles.editStimTime,'String',num2str(handles.stimTime));
if handles.stimTimeN==1,
    set(handles.pushSMinus,'Enable','Off');
end
if handles.stimTimeN<length(handles.stimTimeVector),
    set(handles.pushSPlus,'Enable','On');
end
set(handles.textStimN,'String',strcat(num2str(handles.stimTimeN),'/',num2str(length(handles.stimTimeVector))));
[handles]=baselineHandling(hObject,handles);
[handles]=plotterPSP(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in pushSPlus.
function pushSPlus_Callback(hObject, eventdata, handles)
% hObject    handle to pushSPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stimTimeN=handles.stimTimeN+1;
handles.stimTime=handles.stimTimeVector(handles.stimTimeN);
set(handles.editStimTime,'String',num2str(handles.stimTime));
if handles.stimTimeN==length(handles.stimTimeVector),
    set(handles.pushSPlus,'Enable','Off');
end
if handles.stimTimeN>1,
    set(handles.pushSMinus,'Enable','On');
end
set(handles.textStimN,'String',strcat(num2str(handles.stimTimeN),'/',num2str(length(handles.stimTimeVector))));
[handles]=baselineHandling(hObject,handles);
[handles]=plotterPSP(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in pushChMinus.
function pushChMinus_Callback(hObject, eventdata, handles)
% hObject    handle to pushChMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Ch=handles.Ch-1;
[~,~,ChN]=size(handles.traceS);
if handles.Ch==1,
    set(handles.pushChMinus,'Enable','Off');
end
if handles.Ch<ChN,
    set(handles.pushChPlus,'Enable','On');
end
set(handles.editCh,'String',num2str(handles.Ch));
handles.trace=handles.traceS(1,:,handles.Ch);
fig=findobj('type','figure','number',1);
if ~isempty(fig),
    figure(1);
    clf;
end
[handles]=plotterPSP(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in pushChPlus.
function pushChPlus_Callback(hObject, eventdata, handles)
% hObject    handle to pushChPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Ch=handles.Ch+1;
[~,~,ChN]=size(handles.traceS);
if handles.Ch==ChN,
    set(handles.pushChPlus,'Enable','Off');
end
if handles.Ch>1,
    set(handles.pushChMinus,'Enable','On');
end
set(handles.editCh,'String',num2str(handles.Ch));
handles.trace=handles.traceS(1,:,handles.Ch);
fig=findobj('type','figure','number',1);
if ~isempty(fig),
    figure(1);
    clf;
end
[handles]=plotterPSP(hObject,handles);
guidata(hObject,handles);



function editCh_Callback(hObject, eventdata, handles)
% hObject    handle to editCh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editCh as text
%        str2double(get(hObject,'String')) returns contents of editCh as a double
handles.Ch=str2num(get(hObject,'String'));
if handles.Ch<1
    handles.Ch=1;
    set(handles.editCh,'String',num2str(handles.Ch));
end
[~,~,ChN]=size(handles.traceS);
if handles.Ch>ChN,
    handles.Ch=ChN;
    set(handles.editCh,'String',num2str(handles.Ch));
end
handles.trace=handles.traceS(1,:,handles.Ch);
fig=findobj('type','figure','number',1);
if ~isempty(fig),
    figure(1);
    clf;
end
[handles]=plotterPSP(hObject,handles);
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



function editArtifact_Callback(hObject, eventdata, handles)
% hObject    handle to editArtifact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editArtifact as text
%        str2double(get(hObject,'String')) returns contents of editArtifact as a double
handles.artifactTime=str2double(get(hObject,'String'));
[handles]=plotterPSP(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editArtifact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editArtifact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkArtifact.
function checkArtifact_Callback(hObject, eventdata, handles)
% hObject    handle to checkArtifact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkArtifact
[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in pushRedraw.
function pushRedraw_Callback(hObject, eventdata, handles)
% hObject    handle to pushRedraw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig=findobj('type','figure','number',1);
if ~isempty(fig),
    figure(1);
    clf;
end

[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in checkArea.
function checkArea_Callback(hObject, eventdata, handles)
% hObject    handle to checkArea (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkArea
[handles]=plotterPSP(hObject,handles);


% --- Executes on button press in pushExpSet.
function pushExpSet_Callback(hObject, eventdata, handles)
% hObject    handle to pushExpSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PSPsettings.checkPeak=get(handles.checkPeak,'Value');
PSPsettings.checkHalfwidth=get(handles.checkHalfwidth,'Value');
PSPsettings.checkRiseTime=get(handles.checkRiseTime,'Value');
PSPsettings.checkLatency=get(handles.checkLatency,'Value');
PSPsettings.checkStimulus=get(handles.checkStimulus,'Value');
PSPsettings.checkEnd=get(handles.checkEnd,'Value');
PSPsettings.checkBaseline=get(handles.checkBaseline,'Value');
PSPsettings.checkSD=get(handles.checkSD,'Value');
PSPsettings.checkArtifact=get(handles.checkArtifact,'Value');
PSPsettings.checkArea=get(handles.checkArea,'Value');
PSPsettings.checkNorm=get(handles.checkNorm,'Value');
PSPsettings.radioFilterNone=get(handles.radioFilterNone,'Value');
PSPsettings.radioFilterFlat=get(handles.radioFilterFlat,'Value');
PSPsettings.editWindow=get(handles.editWindow,'String');
PSPsettings.editRiseMin=get(handles.editRiseMin,'String');
PSPsettings.editRiseMax=get(handles.editRiseMax,'String');
PSPsettings.radioAmpMethod=get(handles.radioAmpMethod,'Value');
PSPsettings.editAmpMethod=get(handles.editAmpMethod,'String');
PSPsettings.radioSDMethod=get(handles.radioSDMethod,'Value');
PSPsettings.editSDMethod=get(handles.editSDMethod,'String');

PSPsettings.stimTime=handles.stimTime;
PSPsettings.endTime=handles.endTime;
PSPsettings.baselineTime=handles.baselineTime;
PSPsettings.baselineTimeStart=handles.baselineTimeStart;
PSPsettings.artifactTime=handles.artifactTime;

filename='PSPsettings.mat';
uisave('PSPsettings',filename);
