function varargout = Eirik(varargin)
%EIRIK M-file for Eirik.fig
%      EIRIK, by itself, creates a new EIRIK or raises the existing
%      singleton*.
%
%      H = EIRIK returns the handle to a new EIRIK or the handle to
%      the existing singleton*.
%
%      EIRIK('Property','Value',...) creates a new EIRIK using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to Eirik_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      EIRIK('CALLBACK') and EIRIK('CALLBACK',hObject,...) call the
%      local function named CALLBACK in EIRIK.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Eirik

% Last Modified by GUIDE v2.5 21-Nov-2019 10:32:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Eirik_OpeningFcn, ...
                   'gui_OutputFcn',  @Eirik_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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


% --- Executes just before Eirik is made visible.
function Eirik_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for Eirik
handles.output = hObject;

handles.indexTrace=1;
handles.loadStatus=0;
handles.normTime=0.95;
set(handles.editNorm,'String',num2str(handles.normTime*1000));
set(handles.editNorm,'Enable','Off');
set(handles.editTreshAP,'Enable','Off');
set(handles.checkTraces,'Value',1);

wakeAllBoxes(hObject,handles);

handles.normFlag=0; %flag for changes on the baseline values. 

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Eirik wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Eirik_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadButton.
function LoadButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[handles.data,handles.fullname,handles.loadStatus]=dataBuilderEirik;
wakeAllBoxes(hObject,handles);
set(handles.loadedStatus,'String',handles.fullname);

[handles]=updateListboxEirik(hObject,handles);

guidata(hObject, handles);


function loadedStatus_Callback(hObject, eventdata, handles)
% hObject    handle to loadedStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadedStatus as text
%        str2double(get(hObject,'String')) returns contents of loadedStatus as a double


% --- Executes during object creation, after setting all properties.
function loadedStatus_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadedStatus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2
[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3
[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushSave.
function pushSave_Callback(hObject, eventdata, handles)
% hObject    handle to pushSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    data=handles.data;
    filename=strcat(handles.fullname(1:end-4),'.mat');
    uisave('data',filename);
catch
    disp('Please load a file first!');
end

% --- Executes on button press in pushExpTrace.
function pushExpTrace_Callback(hObject, eventdata, handles)
% hObject    handle to pushExpTrace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exportTraceHM(hObject,handles);

% --- Executes on button press in pushExpFig.
function pushExpFig_Callback(hObject, eventdata, handles)
% hObject    handle to pushExpFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%exportFigureEirik(hObject,handles);

oldKids = get(gca,'Children');

% make new figure and new axes
figure;
h = axes;

% put old children in new axes
copyobj(oldKids,h);

% --- Executes on button press in checkNorm.
function checkNorm_Callback(hObject, eventdata, handles)
% hObject    handle to checkNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkNorm
if get(hObject,'Value'),
    set(handles.editNorm,'Enable','On');
else
    set(handles.editNorm,'Enable','Off');
end

[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);

% --- Executes on button press in checkSelection.
function checkSelection_Callback(hObject, eventdata, handles)
% hObject    handle to checkSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkSelection
wakeSelectionBoxEirik(hObject,handles);
if get(hObject,'Value'),
    [handles]=selectionModeEirik(hObject,handles);
else
    [handles]=updateListboxEirik(hObject,handles);
end
guidata(hObject,handles);


% --- Executes on button press in checkCheck.
function checkCheck_Callback(hObject, eventdata, handles)
% hObject    handle to checkCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkCheck
if get(hObject,'Value'),
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).check(handles.indexCh(i))=1;
    end
else
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).check(handles.indexCh(i))=0;
    end
end
guidata(hObject,handles);


% --- Executes on button press in checkTraces.
function checkTraces_Callback(hObject, eventdata, handles)
% hObject    handle to checkTraces (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkTraces
[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);


function editNorm_Callback(hObject, eventdata, handles)
% hObject    handle to editNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNorm as text
%        str2double(get(hObject,'String')) returns contents of editNorm as a double
handles.normTime=str2num(get(hObject,'String'))/1000;
handles.normFlag=1;
[handles]=updateListboxEirik(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editNorm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkAPs.
function checkAPs_Callback(hObject, eventdata, handles)
% hObject    handle to checkAPs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkAPs
checkAPsEirik(hObject,handles);


function editTreshAP_Callback(hObject, eventdata, handles)
% hObject    handle to editTreshAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTreshAP as text
%        str2double(get(hObject,'String')) returns contents of editTreshAP as a double
checkAPsEirik(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editTreshAP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTreshAP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushAnal.
function pushAnal_Callback(hObject, eventdata, handles)
% hObject    handle to pushAnal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.checkSelection,'Value')
    rawdata=handles.data(handles.indexG).group(handles.indexP).rawdata;
    trace=NaN(1,size(handles.avrTrace,2),length(handles.indexCh));
    for i=1:length(handles.indexCh)
        trace(1,:,i)=rawdata(handles.indexTrace,:,handles.indexCh(i));
    end
else
    trace=NaN(1,size(handles.avrTrace,2),length(handles.indexCh));
    for i=1:length(handles.indexCh)
        trace(1,:,i)=handles.avrTrace(1,:,handles.indexCh(i));
    end
end
time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX;
unitY=handles.data(handles.indexG).group(handles.indexP).unitY;
PSPlab(time,trace,unitY);


function editNselected_Callback(hObject, eventdata, handles)
% hObject    handle to editNselected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNselected as text
%        str2double(get(hObject,'String')) returns contents of editNselected as a double
handles.indexTrace=round(str2double(get(handles.editNselected,'String')));
[handles]=selectionModeEirik(hObject,handles);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function editNselected_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNselected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushMinus.
function pushMinus_Callback(hObject, eventdata, handles)
% hObject    handle to pushMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.indexTrace=handles.indexTrace-1;
if handles.indexTrace<1, handles.indexTrace=1; end
[handles]=selectionModeEirik(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in pushPlus.
function pushPlus_Callback(hObject, eventdata, handles)
% hObject    handle to pushPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.indexTrace=handles.indexTrace+1;
[handles]=selectionModeEirik(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in radioInclude.
function radioInclude_Callback(hObject, eventdata, handles)
% hObject    handle to radioInclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioInclude
if get(hObject,'Value'),
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).include(handles.indexTrace,handles.indexCh(i))=1;
    end
else
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).include(handles.indexTrace,handles.indexCh(i))=0;
    end
end
[handles]=selectionModeEirik(hObject,handles);
guidata(hObject,handles);

% --- Executes on button press in radioExclude.
function radioExclude_Callback(hObject, eventdata, handles)
% hObject    handle to radioExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radioExclude
if get(hObject,'Value'),
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).include(handles.indexTrace,handles.indexCh(i))=0;
    end
else
    for i=1:length(handles.indexCh),
        handles.data(handles.indexG).group(handles.indexP).include(handles.indexTrace,handles.indexCh(i))=1;
    end
end
[handles]=selectionModeEirik(hObject,handles);
guidata(hObject,handles);


% --- Executes on button press in pushCut.
function pushCut_Callback(hObject, eventdata, handles)
% hObject    handle to pushCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time=(1:size(handles.avrTrace,2))*handles.data(handles.indexG).group(handles.indexP).intX;
%data1=handles.data.group(handles.indexG).rawdata;
vector=NaN(1,size(handles.avrTrace,2),length(handles.indexCh));
[handles]=avrTraceBuilder(hObject,handles); %recalculates the average traces. 
for i=1:length(handles.indexCh)
    vector(1,:,i)=handles.avrTrace(1,:,handles.indexCh(i));
end
for i=1:length(handles.indexCh)
    listCh{i}=handles.listCh{handles.indexCh(i)};
end
dataCh=handles.data(handles.indexG).group(handles.indexP).rawdata;
data=nan(size(dataCh,1),size(dataCh,2),length(listCh)); %prefills the variable with NaNs. 
for i=1:length(handles.indexCh)
    for j=1:size(dataCh,1)
        if handles.data(handles.indexG).group(handles.indexP).include(j,handles.indexCh(i))
             if get(handles.checkAPs,'Value'),
                    if ~handles.data(handles.indexG).group(handles.indexP).AP(j,handles.indexCh(i)),
                       data(j,:,i)=dataCh(j,:,handles.indexCh(i));
                    end
             else
            	data(j,:,i)=dataCh(j,:,handles.indexCh(i));
             end
        end
    end
end
unitY=handles.data(handles.indexG).group(handles.indexP).unitY;
Klipp(time,vector,data,listCh,unitY);


% --- Executes on button press in pushRasterplot.
function pushRasterplot_Callback(hObject, eventdata, handles)
% hObject    handle to pushRasterplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
makeRasterplot(hObject,handles);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oldKids = get(gca,'Children');

% make new figure and new axes
figure;
h = axes;

% put old children in new axes
copyobj(oldKids,h);


% --- Executes on button press in pushRastExp.
function pushRastExp_Callback(hObject, eventdata, handles)
% hObject    handle to pushRastExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

counter=0;
for i=1:length(handles.data)
    for j=1:length(handles.data(i).group)
        if ~handles.data(i).group(j).CS && handles.data(i).group(j).rast %checks for excluding Current Steps trials and it is included for rast analysis. 
            for k=1:size(handles.data(i).group(j).APtimes,2)
                %first it checks which trials have APs.
                tempList=[];
                for m=1:size(handles.data(i).group(j).APtimes,1)
                    if ~isempty(handles.data(i).group(j).APtimes{m,k})
                        tempList=[tempList m];
                    end
                end
                if ~isempty(tempList)
                    counter=counter+1;
                    tempAPtimes=cell(length(tempList),1);
                    for m=1:length(tempList)
                        if handles.data(i).group(j).include(m,k)
                            tempAPtimes{m}=handles.data(i).group(j).APtimes{m,k};
                        end
                    end
                    AP(counter).filename=handles.fullname;
                    AP(counter).groupname=handles.data(i).groupname;
                    AP(counter).protocol=handles.data(i).group(j).name;
                    AP(counter).Ch=handles.data(i).group(j).listCh(k);
                    AP(counter).APtimes=tempAPtimes;
                end                
            end
        end
    end
end 

if exist('AP','var')
    filename=strcat(handles.fullname(1:end-4),'_rast','.mat');
    uisave('AP',filename);
end


% --- Executes on button press in checkIncRast.
function checkIncRast_Callback(hObject, eventdata, handles)
% hObject    handle to checkIncRast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkIncRast
if get(hObject,'Value')
    handles.data(handles.indexG).group(handles.indexP).rast=1;
else
    handles.data(handles.indexG).group(handles.indexP).rast=0;
end

[handles]=updateListboxEirik(hObject,handles);
guidata(hObject, handles);