function varargout = radial_profile_exec(varargin)
% RADIAL_PROFILE_EXEC MATLAB code for radial_profile_exec.fig
%      RADIAL_PROFILE_EXEC, by itself, creates a new RADIAL_PROFILE_EXEC or raises the existing
%      singleton*.
%
%      H = RADIAL_PROFILE_EXEC returns the handle to a new RADIAL_PROFILE_EXEC or the handle to
%      the existing singleton*.
%
%      RADIAL_PROFILE_EXEC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RADIAL_PROFILE_EXEC.M with the given input arguments.
%
%      RADIAL_PROFILE_EXEC('Property','Value',...) creates a new RADIAL_PROFILE_EXEC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before radial_profile_exec_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to radial_profile_exec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help radial_profile_exec

% Last Modified by GUIDE v2.5 21-Dec-2018 10:44:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @radial_profile_exec_OpeningFcn, ...
                   'gui_OutputFcn',  @radial_profile_exec_OutputFcn, ...
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


% --- Executes just before radial_profile_exec is made visible.
function radial_profile_exec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to radial_profile_exec (see VARARGIN)

% Choose default command line output for radial_profile_exec
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes radial_profile_exec wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = radial_profile_exec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%enter initial file
[file_1,path_1,success]=uigetfile;
handles.filename_1=file_1
handles.pathname_1=path_1

guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%enter 2nd file
[file_2,path_2,success]=uigetfile;
handles.filename_2=file_2
handles.pathname_2=path_2

guidata(hObject, handles);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%go button

%for the eroded thresholded images
f_1=handles.filename_1;
p_1=handles.pathname_1;

%for the eroded thresholded images
f_2=handles.filename_2;
p_2=handles.pathname_2;

[cell_indiv_data1,all_angle_ret1,all_int_ret1,entire_avg]=radial_profile_calc_func(p_1,f_1,f_2);

%storing the cell array with the individual slices info
handles.cell_indiv_slices=cell_indiv_data1;

%clearing the figure
axes(handles.axes2); 
cla reset;

axes(handles.axes2);
plot(all_angle_ret1,all_int_ret1,'r.','LineWidth',4,'MarkerEdgeColor',[0.6,0.6,.6],'MarkerSize',12); hold on;
plot(entire_avg(:,1),entire_avg(:,2),'k','LineWidth',1.5);
xlabel('Angle (deg.)'); ylabel('Intensity'); title('All Data Combined'); legend('Raw Data','Average');xlim([0 360]);

guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%getting the cell array
cell_to_save=handles.cell_indiv_slices;

for k=1:size(cell_to_save,1)
   
    %number
    num_save_tmp=cell_to_save(k,1);
    num_save=num_save_tmp{1};
    
    %open file for writing
    fileID = fopen(strcat('Ind_slice_#_',num2str(num_save),'.txt'),'w');
    
    slice_data_tmp=cell_to_save(k,2);
    slice_data=slice_data_tmp{1};
    
    john=size(slice_data)
    
    %loading text file
    for v=1:numel(slice_data(:,1))
        
        if v==1
            fprintf(fileID,'%12s %12s\n','Angle(Deg.)','Intensity');
        end
        
        fprintf(fileID,'%12.8f %12.8f\n',slice_data(v,3),slice_data(v,5));
        
    end
    
    fclose(fileID);
    
    clear num_save_tmp; clear num_save;
    clear fileID; clear slice_data_tmp; clear slice_data;
    
end


guidata(hObject, handles);


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all;
