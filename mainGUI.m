function varargout = mainGUI(varargin)
% PRATICA01GUI MATLAB code for pratica01GUI.fig
%      PRATICA01GUI, by itself, creates a new PRATICA01GUI or raises the existing
%      singleton*.
%
%      H = PRATICA01GUI returns the handle to a new PRATICA01GUI or the handle to
%      the existing singleton*.
%
%      PRATICA01GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PRATICA01GUI.M with the given input arguments.
%
%      PRATICA01GUI('Property','Value',...) creates a new PRATICA01GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pratica01GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pratica01GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pratica01GUI

% Last Modified by GUIDE v2.5 02-May-2016 20:32:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mainGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @mainGUI_OutputFcn, ...
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
end


% --- Executes just before pratica01GUI is made visible.
function mainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pratica01GUI (see VARARGIN)

% Choose default command line output for pratica01GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pratica01GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global count
count = 0;
end


% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end


% --------------------------------------------------------------------
function menu_Callback(hObject, eventdata, handles)
% hObject    handle to menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end


function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
end


% --------------------------------------------------------------------
function abrir_Callback(hObject, eventdata, handles)
% Funcao para abrir uma imagem

    global imgsArray   % Array com todas as imagens
    global count   % Contador referencia fase atual do processo
    global labels
    global labelsArray % Array com os textos de todas as operacoes
    global eh_roi
    global original_cortada
    
    original_cortada = [];
    eh_roi = false;
    
    labels = {'Imagem Original'; 'H + V'; 'Resultado K-means'; 'Imagem Binarizada'; 'Imagem Erodida'; 'Imagem Dilatada'; 'ROI'; 'PP automático'; 'Imagem Final'};
    
    [path_file, user_cancel] = imgetfile();
    if ~user_cancel
        count = 1;
        imgsArray = [];
        labelsArray = [];
    
        handles.arquivo = path_file;
        handles.atual = im2uint8(imread(path_file));
        imgsArray{count} = handles.atual;
        trocaHandles( hObject, handles );
        
        labelsArray{count} = labels(1);
        set(findobj(gcf, 'Tag', 'text1'), 'String', 'Anterior');
        set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
    end
    handles.px2min = NaN;
    guidata(hObject, handles);
end


% --------------------------------------------------------------------
function salvar_Callback(hObject, eventdata, handles)
% hObject    handle to salvar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global imgsArray
global count
global eh_roi
global original_cortada

    if count > 0
        [path_file, user_cancel] = imsave();
        if ~user_cancel
            imwrite(imgsArray{count}, path_file);
            handles.px2min = NaN;
            guidata(hObject, handles);
        end
        
        if eh_roi == true && ~isempty(original_cortada)
            eh_roi = false;
            
            [path_file, user_cancel] = imsave();
            if ~user_cancel
                imwrite(original_cortada, path_file);
                handles.px2min = NaN;
                guidata(hObject, handles);
            end
        end
    else
        msgbox('Imagem Atual nao foi gerada!', 'Error', 'Error');
    end
end
% --------------------------------------------------------------------


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    global imgsArray
    global count
    global labels
    global labelsArray
    global eh_roi
    global original_cortada
    
    count = count + 1;
    
    switch count
        case 2
            % Soma as bandas H e V do sistema de cor HSV %
            if isfield( handles, 'atual' )
                imgsArray{count} = preProcessamento(imgsArray{count - 1});
                trocaHandles(hObject, handles);
                
                labelsArray{count} = labels(count);
                set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
            else
                msgbox('Imagem nao foi carregada!', 'Error', 'Error');
            end

        case 3
            % --- Segmenta a imagem utilizando o Kmeans --- %
            if isfield( handles, 'atual' )
                imgsArray{count} = segmentacao(imgsArray{count - 1});
                trocaHandles(hObject, handles);
                
                labelsArray{count} = labels(count);
                set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
            else
                msgbox('Imagem nao foi carregada!', 'Error', 'Error');
            end

        case 4
            cor_semente = escolhaCor;
            imgsArray{count} = imgsArray{count-1}(:,:,cor_semente);    % Banda de cor que contem o fundo
            
            trocaHandles(hObject, handles);
                
            labelsArray{count} = labels(count);
            set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
            set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
        otherwise
            e_etapa = escolhaEtapa;
            
            if strcmp(e_etapa, 'Contar Sementes')
                if ~isempty(original_cortada)
                    imgsArray{count} = contaSementes(original_cortada, imgsArray{count-1});
                    trocaHandles(hObject, handles);

                    labelsArray{count} = labels(9);
                    set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                    set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
                    
                    count = count + 1;
                    imgsArray{count} = original_cortada;
                    trocaHandles(hObject, handles);

                    labelsArray{count} = labels(1);
                    set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                    set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
%                     
%                     % Calcula a quantida de sementes na imagem
%                     fprintf('[Grupo %d] Contem %d sementes!\n', k, qntd);
% %                     imgsArray{count} = insertText(imgsArray{count},...
% %                                         round(pos(255).Centroid),qntd,'FontSize',...
% %                                         18,'BoxColor','blue','BoxOpacity',...
% %                                         0.4,'TextColor','white');
                else
                    msgbox('Imagem apenas com a ROI nao foi gerada!', 'Error', 'Error');
                    count = count - 1;
                end
                
            elseif strcmp(e_etapa, 'Pós-processamento')
                [e_mm, tam] = esolhaMM;
                tam = round(str2double(tam));

                if tam > 0
                    if strcmp(e_mm, 'Erosao')
                        imgsArray{count} = erode(imgsArray{count - 1}, tam);
                        trocaHandles(hObject, handles);

                        labelsArray{count} = labels(5);
                        set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                        set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
                    elseif strcmp(e_mm, 'Dilatacao')
                        imgsArray{count} = dilata(imgsArray{count - 1}, tam);
                        trocaHandles(hObject, handles);

                        labelsArray{count} = labels(6);
                        set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                        set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
                    end
                end
            elseif strcmp(e_etapa, 'Selecionar ROI')
                eh_roi = true;
                
                [imgsArray{count}, original_cortada] = selecionaROI(imgsArray{count - 1}, imgsArray{1});
                trocaHandles(hObject, handles);
                
                labelsArray{count} = labels(7);
                set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
            elseif strcmp(e_etapa, 'PP automático')
                
                imgsArray{count} = posProcessamentoAutomatico(imgsArray{count - 1});
                trocaHandles(hObject, handles);
                
                labelsArray{count} = labels(8);
                set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
                set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});
                
            end

    end
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)

    global imgsArray
    global count
    global labelsArray

    % Nao tenta retirar a imagem lida
    if count > 1
        imgsArray{count} = [];  % Apaga imagem atual do array
        labelsArray{count} = [];  % Apaga texto atual do array
        count = count - 1;      % Volta 1 imagem
        
        % Troca texto atual pelo anterior e anterior por uma mais anterior ainda
        if count ~= 1
            set(findobj(gcf, 'Tag', 'text1'), 'String', labelsArray{count - 1});
        else
            set(findobj(gcf, 'Tag', 'text1'), 'String', 'Anterior');
        end
        set(findobj(gcf, 'Tag', 'text2'), 'String', labelsArray{count});

        % Troca imagem atual pela anterior e anterior por uma mais anterior ainda
        trocaHandles(hObject, handles);
    end
end


function trocaHandles(hObject, handles)
    global count
    global imgsArray
    
    if count > 1
        % Imagem Anterior
        axes(handles.axes1);
        imshow(imgsArray{count - 1});
        handles.px2min = NaN;
        guidata(hObject, handles);
        
        % Imagem Atual
        axes(handles.axes2);
        imshow(imgsArray{count});
        handles.px2min = NaN;
        guidata(hObject, handles);
    elseif count == 1
        % Imagem Anterior
        axes(handles.axes1);
        imshow([]);
        handles.px2min = NaN;
        guidata(hObject, handles);
        
        % Imagem Atual
        axes(handles.axes2);
        imshow(imgsArray{count});
        handles.px2min = NaN;
        guidata(hObject, handles);
    end
end


function [e_mm, tam] = esolhaMM
    d = dialog('Position',[300 300 245 150],'Name','Pós-processamento');
    txt1 = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[10 80 80 30],...
           'String','Tipo de MM:');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[10 70 100 25],...
           'String',{'Erosao';'Dilatacao'},...
           'Callback',@popup_callback);
       
    txt2 = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[120 80 110 30],...
           'String','Tamanho do EL:');
       
    edit = uicontrol('Parent',d,...
           'Style','edit',...
           'Position',[120 70 40 25],...
           'String','',...
           'Callback',@edit_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Ok',...
           'Callback','delete(gcf)');
       
    e_mm = 'Erosao';
    tam = '0';
       
    % Wait for d to close before running to completion
    uiwait(d);
   
    function popup_callback(popup,callbackdata)
        % idx = popup.Value;
        % popup_items = popup.String;
        % This code uses dot notation to get properties.
        % Dot notation runs in R2014b and later.
        % For R2014a and earlier:
        idx = get(popup,'Value');
        popup_items = get(popup,'String');
        e_mm = char(popup_items(idx,:));
    end

    function edit_callback(edit,callbackdata)
        tam = get(edit,'String');
%         tam = round(str2double(text));
    end
end


function e_etapa = escolhaEtapa
    d = dialog('Position',[300 300 270 150],'Name','Proxima Etapa');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[0 90 280 35],...
           'String','Selecione a próxima etapa:');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[50 60 150 25],...
           'String',{'Contar Sementes';'Pós-processamento';'Selecionar ROI'},... % ;'PP automático'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Ok',...
           'Callback','delete(gcf)');
       
    e_etapa = 'Contar Sementes';
       
    % Wait for d to close before running to completion
    uiwait(d);
   
    function popup_callback(popup,callbackdata)
        idx = get(popup,'Value');
        popup_items = get(popup,'String');
        e_etapa = char(popup_items(idx,:));
    end
end


function e_cor = escolhaCor
    d = dialog('Position',[300 300 270 150],'Name','Contar Sementes');
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[0 90 280 35],...
           'String','A cor da(s) semente(s) na etapa atual é:');
       
    popup = uicontrol('Parent',d,...
           'Style','popup',...
           'Position',[50 60 150 25],...
           'String',{'Verde';'Vermelho'},...
           'Callback',@popup_callback);
       
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Ok',...
           'Callback','delete(gcf)');
       
    e_cor = 2;
       
    % Wait for d to close before running to completion
    uiwait(d);
   
    function popup_callback(popup,callbackdata)
        idx = get(popup,'Value');
        popup_items = get(popup,'String');
        text = char(popup_items(idx,:));
        
        if strcmp(text, 'Verde')
            e_cor = 2;
        elseif strcmp(text, 'Vermelho')
            e_cor = 1;
        end
    end
end
