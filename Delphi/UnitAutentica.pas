unit UnitAutentica;

interface

const
  AutNoError=0;
  AutErrNoApiKey=1;
  AutErrTimeout=2;
  AutErrNoCredentials=3;
  AutErrUnexpectedOnConfirm=4;
  AutErrUnexpectedOnChangePassword=5;
  AutErrUnexpectedOnRequestNewPwd=6;
  AutErrUnexpectedOnCallAutentica=7;
  AutErrEmptyJSONResponse=8;
  AutErrNoIdUser=9;
  AutErrNoToken=10;

var
  vOrigin: String;
  vUserAgent: String;

function ValutazionePassword(const APwd: String): Integer;  //Min=0 Max=5
function Autenticazione(const ApiKey,Nonce,Title: String;
                        var IdUser,Token,MsgErrore: String; var CodErrore: Integer): Boolean;
function CreaUtente(const ApiKey,Title,IdUser: String;
                    var MsgErrore: String; var CodErrore: Integer): Boolean;
function RefreshToken(const ApiKey: String; var Token: String;
                      var MsgErrore: String; var CodErrore: Integer): Boolean;
function ModificaPassword(const ApiKey,Title,UserOMail: String;
                          var MsgErrore: String; var CodErrore: Integer;
                          const AHandle: Integer=0; const ACaption: String=''): Boolean;
function ResetPassword(const ApiKey,UserOMail: String;
                       var MsgErrore: String; var CodErrore: Integer;
                       const AHandle: Integer=0; const ACaption: String=''): Boolean;
function CreateUser(const ApiKey,UserName,IDUser,Email: String;
                    var MsgErrore: String; var CodErrore: Integer;
                    const AHandle: Integer=0; const ACaption: String=''): Boolean;

implementation

uses Vcl.Forms, Vcl.Controls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.StdCtrls, System.IniFiles, System.Win.Registry,
     System.Classes, System.SysUtils, System.Json, System.Hash, System.NetEncoding, System.Math, System.Types,
     Winapi.Windows, REST.Client, REST.Types, IdCoderMIME, System.Threading;

const
  MsgNoApiKey='ApiKey non fornita';
  MsgNoToken='Token non fornito';
  MsgNoIdUser='IdUser non fornito';
  MsgNoCredentials='Operazione annullata. Credenziali non immesse';
  MsgNoUserName='Nome Utente non immesso';
  MsgNoPassword='Password non immessa';
  MsgTimeoutBio='Autenticazione con App non effettuata. Premere su Conferma per un nuovo tentativo o su Annulla per annullare';
  MsgBioInterrotto='Autenticazione con App interrotta. Premere su Conferma per un nuovo tentativo o su Annulla per annullare';
  MsgCredenzialiErrate='Credenziali errate';
  MsgPasswordExpired='La password ט scaduta. Immetti due volte la nuova password';
  MsgNoNewPassword='Immettere il campo Nuova Password';
  MsgNoRepeatPassword='Immettere il campo Ripeti Password';
  MsgPasswordsDontMatch='Le Password immesse non corrispondono. Riprovare.';
  MsgPasswordsNotGood='La Password immessa non rispetta i requisiti minimi. Continuare?';
  MsgNoUserNameEmail='Immettere il campo Nome Utente o Email';
  MsgNewPasswordSent='Password temporanea inviata alla casella email memorizzata';
  MsgNewUserCreated='Nuovo utente creato e email inviata';
  MsgTimeout='Tempo scaduto. Credenziali non immesse';
  MsgNoEmail='Se non si inserisce la Password, ט necessario specificare una Email per l''invio di una Password temporanea';
  MsgInvalidEmail='L''indirizzo email immesso non sembra essere valido';

  LblInitialMessage='Autenticazione Utente';
  LblUserName='&Nome Utente:';
  LblPassword='&Password:';
  LblOldPassword='&Vecchia Password:';
  LblNewPassword='N&uova Password:';
  LblPasswordAgain='&Ripeti Password:';
  LblForgottenPassword='Nome Utente o Password Dimenticata? Clicca';
  LblHere='&Qui';
  LblUserNameOrEmail='&Nome Utente o Email:';
  LblRequestNewPassword='Password dimenticata';
  LblInitialCreateUser='Creazione Utente';
  LblEmailAddress='&Indirizzo Email:';
  LblModificaPassword='Modifica Password';
  LblPrerequisiti='I prerequisiti sono di possedere uno smartphone di ultima genera' +
                  'zione, di aver predisposto su di esso l'#39'utilizzo della propria i' +
                  'mpronta biometrica ed aver scaricato la nostra App di Autenticaz' +
                  'ione Senza Password.';
  LblAppAndroid='Punta qui per scaricare la App per Android';
  LblAppIos='Punta qui per scaricare la App per iOS';
  LblApiKeyUtente='Premi "+" e punta qui per registrare nella App il progetto %1 con l''utente %2';

  BtnCaptionModPassword='&Modifica Password';
  BtnConfirm='&Conferma';
  BtnCancel='&Annulla';
  BtnPasswordless='&Sperimenta l''esperienza Senza Password';
  BtnRequestPassword='&Richiedi Password';

  HintPwd: Array[0..5] of String = ('Valutazione della password immessa','Scadente','Scarsa','Insufficiente','Ci siamo quasi','Accettabile');

type
  TFormAutenticazione = class(TForm)
  private
    FApiKey: String;
    FNonce: String;
    FIDUser: String;
    FToken: String;
    FBio,FResult: Boolean;
    FMsgErrore: String;
    FOldPwd: String;
    FCodErrore,FTentativi: Integer;
    PanelTop,PanelClient: TPanel;
    ImageLogoApp: TImage;
    LabelDescApp: TLabel;
    LabelMsg: TLabel;
    LabelPasswordDimenticata: TLabel;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
    ButtonPasswordless: TButton;
    LabelPassword: TLabel;
    LabelPassword2: TLabel;
    LabelUserName: TLabel;
    LabelOldPassword: TLabel;
    Timer: TTimer;
    EditUserName: TEdit;
    EditPassword: TEdit;
    EditPassword2: TEdit;
    EditOldPassword: TEdit;
    LabelQui: TLabel;
    ImageQualityIndicator: TImage;
    PanelBio: TPanel;
    ButtonAnnullaBio: TButton;
    TimerBio: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormAutenticazioneShow(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonRichiediNPwdClick(Sender: TObject);
    procedure ButtonModificaPasswordClick(Sender: TObject);
    procedure ButtonModificaPassword2Click(Sender: TObject);
    procedure ButtonPasswordlessClick(Sender: TObject);
    procedure LabelQuiClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditPasswordChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure TimerBioTimer(Sender: TObject);
    procedure ButtonAnnullaBioClick(Sender: TObject);
    procedure MostraDatiProgetto;
  end;

  TFormCreaUtente = class(TForm)
  private
    FApiKey: String;
    FIDUser: String;
    FResult: Boolean;
    FMsgErrore: String;
    FCodErrore: Integer;
    PanelTop,PanelClient: TPanel;
    ImageLogoApp: TImage;
    LabelDescApp: TLabel;
    LabelMsg: TLabel;
    LabelUserName: TLabel;
    EditUserName: TEdit;
    LabelEmail: TLabel;
    EditEmail: TEdit;
    LabelPassword: TLabel;
    Timer: TTimer;
    EditPassword: TEdit;
    EditPassword2: TEdit;
    LabelPassword2: TLabel;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
    ImageQualityIndicator: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormCreaUtenteShow(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditPasswordChange(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure MostraDatiProgetto;
  end;

  TFormPasswordless = class(TForm)
  private
    FApiKey: String;
    FMsgErrore: String;
    FUserName: String;
    FCodErrore: Integer;
    LabelMsg: TLabel;
    LabelAppAndroid: TLabel;
    LabelAppIos: TLabel;
    LabelApiKeyUtente: TLabel;
    ImageAppAndroid: TImage;
    ImageAppIos: TImage;
    ImageLogoApp: TImage;
    ImageApiKeyUtente: TImage;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
    FResult: Boolean;
    FDescrizione: String;
    procedure FormCreate(Sender: TObject);
    procedure FormPasswordlessShow(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure MostraDatiProgetto;
    procedure QRCodeAndroid;
    procedure QRCodeApikeyUsername;
    procedure QRCodeIos;
    procedure ZoomQRCode(const AStream: TMemoryStream; const DestImage: TImage);
  end;

{$region 'Private functions'}

procedure Init;
begin
  if vOrigin.Trim.IsEmpty then
    vOrigin:=TOSVersion.ToString;
  if vUserAgent.Trim.IsEmpty then
    vUserAgent:='UnitAutentica/2020.11.25/'+TOSVersion.Name;
end;

procedure ZoomImage(const AStream: TMemoryStream; const DestImage: TImage);
var
  WICImage: TWICImage;
  SourceBitmap,TempBitmap: Vcl.Graphics.TBitmap;
begin
  WICImage:=TWICImage.Create;
  SourceBitmap:=Vcl.Graphics.TBitmap.Create;
  TempBitmap:=Vcl.Graphics.TBitmap.Create;
  try
    WICImage.LoadFromStream(aStream);
    WICImage.ImageFormat:=wifBmp;
    SourceBitmap.Width:=WICImage.Width;
    SourceBitmap.Height:=WICImage.Height;
    SourceBitmap.Assign(WICImage);
    TempBitmap.Width:=DestImage.Width;
    TempBitmap.Height:=DestImage.Height;
    SetStretchBltMode(TempBitmap.Canvas.Handle,STRETCH_HALFTONE);
    SetBrushOrgEx(TempBitmap.Canvas.Handle,0,0,nil);
    StretchBlt(TempBitmap.Canvas.Handle,
               0,0,TempBitmap.Width,TempBitmap.Height,
               SourceBitmap.Canvas.Handle,
               0,0,SourceBitmap.Width,SourceBitmap.Height,
               SRCCOPY);
    DestImage.Picture.Bitmap.Assign(TempBitmap);
  finally
    WICImage.Free;
    SourceBitmap.Free;
    TempBitmap.Free;
  end;
end;

procedure DrawPieSlice(const Canvas: TCanvas; const Center: TPoint;
  const Radius: Integer; const StartDegrees, StopDegrees: Double);
const
  Offset=0;  {to make 0 degrees start to the right}
var
  X1,X2,X3,X4: Integer;
  Y1,Y2,Y3,Y4: Integer;
begin
  X1:=Center.X-Radius;
  Y1:=Center.Y-Radius;
  X2:=Center.X+Radius;
  Y2:=Center.Y+Radius;
  {negative signs on "Y" values to correct for "flip" from normal math
  defintion for "Y" dimension}
  X3:=Center.X+Round(Radius*Cos(DegToRad(Offset+StartDegrees)));
  Y3:=Center.y-Round(Radius*Sin(DegToRad(Offset+StartDegrees)));
  X4:=Center.X+Round(Radius*Cos(DegToRad(Offset+StopDegrees)));
  Y4:=Center.y-Round(Radius*Sin(DegToRad(Offset+StopDegrees)));
  Canvas.Pie(X1,Y1,X2,Y2,X3,Y3,X4,Y4);
end;

function WordCount(S,Sep: String): Integer;
var
  I: Integer;
begin
  if Length(S)=0 then begin
    Result:=0;
    Exit;
  end;
  if S[Length(S)]=Sep then
    Result:=0
  else
    Result:=1;
  for I:=1 to Length(S) do
    if S[I]=Sep then
      Inc(Result);
end;

function ExtractWord(N: Integer; S,Sep: String): String;
var
  I,W: Integer;
begin
  Result:='';
  W:=0;
  for I:=1 to Length(S) do begin
    if S[I]=Sep then begin
      Inc(W);
      if W=N then
        Exit;
      Result:='';
    end
    else
      Result:=Result+S[I];
  end;
  Inc(W);
  if W=N then
    Exit;
  Result:='';
end;

{$endregion}

{$region 'Public functions'}

function ChiamataAutentica(const Metodo: String; const Parametri: TJSONObject;
                           var JSONResponse: TJSONObject; var AToken,AMsgErrore: String; var ACodErrore: Integer): Boolean;
var
  AutenticaBaseURL: String;
  prvRestClient: TRESTClient;
  prvRestRequest: TRESTRequest;
  prvRestResponse: TRESTResponse;
  FreeJSONResponse: Boolean;
  function GetDispositivo: String;
  begin
    {$IFDEF MSWINDOWS}
    Result:=GetEnvironmentVariable('COMPUTERNAME')+' con '+TOSVersion.Name;
    {$ENDIF}
    {$IFDEF MACOS}
    Result:=GetEnvironmentVariable('COMPUTERNAME')+' con '+TOSVersion.Name;
    {$ENDIF}
    {$IFDEF UNIX}
    Result:=GetEnvironmentVariable('COMPUTERNAME')+' con '+TOSVersion.Name;
    {$ENDIF}
    {$IFDEF ANDROID}
    Result:='Android device';
    {$ENDIF}
    {$IFDEF IOS}
    Result:='iOS device';
    {$ENDIF}
  end;
begin
  with TIniFile.Create(ExtractFilePath(ParamStr(0))+'Setup.ini') do begin
    try
      AutenticaBaseURL:=ReadString('Setup','AutenticaBaseURL','https://ws-a.geninfo.it/rest/api');
    finally
      Free;
    end;
  end;
  try
    prvRestClient:=TRESTClient.Create(AutenticaBaseURL);
    prvRestRequest:=TRESTRequest.Create(Nil);
    prvRestResponse:=TRESTResponse.Create(Nil);
    FreeJSONResponse:=False;
    if not Assigned(JSONResponse) then begin
      JSONResponse:=TJSONObject.Create;
      FreeJSONResponse:=True;
    end;
    try
      with prvRESTClient do begin
        Accept:='application/json, text/plain; q=0.9, text/html;q=0.8,';
        AcceptCharset:='UTF-8, *;q=0.8';
        ContentType:='application/json; charset=utf-8';
        AddParameter('User-Agent',vUserAgent,TRESTRequestParameterKind.pkHTTPHEADER);
        AddParameter('Origin',vOrigin,TRESTRequestParameterKind.pkHTTPHEADER);
        HandleRedirects:=False;
      end;
      with prvRESTRequest do begin
        Client:=prvRESTClient;
        Resource:=Metodo;
        Params.Clear;
        if Metodo='AutenticazioneBio' then
          Timeout:=62000;
        Params.Clear;
        if Assigned(Parametri) then begin
          Method:=rmPOST;
          Parametri.AddPair('idDispositivo',GetDispositivo);
          AddParameter('body',Parametri,False);
          Params.ParameterByName('body').ContentType:=ctAPPLICATION_JSON;
          Params.ParameterByName('body').Kind:=pkREQUESTBODY;
        end
        else
          Method:=rmGet;
        Response:=prvRESTResponse;
        SynchronizedEvents:=False;
        URLAlreadyEncoded:=True;
      end;
      try
        prvRestRequest.Execute;
        if JSONResponse.Parse(BytesOf(prvRestResponse.Content),0)=0 then begin
          AMsgErrore:='Autentica - Method "'+Metodo+'": Empty JSONResponse';
          ACodErrore:=AutErrEmptyJSONResponse;
          Result:=False;
          Exit;
        end;
        if prvRestResponse.StatusCode<>200 then begin
          Result:=False;
          AMsgErrore:=JSONResponse.GetValue<String>('description');
          ACodErrore:=JSONResponse.GetValue<Integer>('error');
        end
        else begin
          if (Metodo='Autenticazione') or (Metodo='AutenticazioneBio') or (Metodo='RefreshToken') then
            AToken:=JSONResponse.GetValue<String>('token');
          ACodErrore:=AutNoError;
          AMsgErrore:='';
          Result:=True;
        end;
      except
        Result:=False;
        AMsgErrore:=prvRestResponse.Content;
        ACodErrore:=prvRestResponse.StatusCode;
      end;
    finally
      prvRestClient.Free;
      prvRestRequest.Free;
      prvRestResponse.Free;
      if FreeJSONResponse then
        JSONResponse.Free;
    end;
  except
    on E:Exception do begin
      AMsgErrore:='Autentica - Metodo "'+Metodo+'": '+E.Message;
      ACodErrore:=AutErrUnexpectedOnCallAutentica;
      Result:=False;
    end;
  end;
end;

function Autenticazione(const ApiKey,Nonce,Title: String;
                        var IdUser,Token,MsgErrore: String; var CodErrore: Integer): Boolean;
var
  FormAutenticazione: TFormAutenticazione;
begin
  Init;
  IdUser:='';
  Token:='';
  Result:=False;
  if Length(ApiKey)=0 then begin
    CodErrore:=AutErrNoApiKey;
    MsgErrore:=MsgNoApiKey;
    Exit;
  end;
  FormAutenticazione:=TFormAutenticazione.CreateNew(Application);
  try
    FormAutenticazione.FormCreate(FormAutenticazione);
    FormAutenticazione.FApiKey:=ApiKey;
    FormAutenticazione.FNonce:=Nonce;
    if Length(Trim(Title))>0 then begin
      FormAutenticazione.Caption:=Title;
      with TRegistry.Create do
        try
          if OpenKeyReadOnly('SOFTWARE\Generazione Informatica\Autentica') then begin
            FormAutenticazione.EditUserName.Text:=ReadString(Title);
            if ValueExists('Bio') then
              FormAutenticazione.FBio:=ReadBool('Bio');
            CloseKey;
          end;
        finally
          Free;
        end;
    end;
    FormAutenticazione.ShowModal;
    Result:=FormAutenticazione.FResult;
    IdUser:=FormAutenticazione.FIDUser;
    Token:=FormAutenticazione.FToken;
    MsgErrore:=FormAutenticazione.FMsgErrore;
    CodErrore:=FormAutenticazione.FCodErrore;
    if (Length(Trim(Title))>0) and (CodErrore=AutNoError) then begin
      with TRegistry.Create do
        try
          if OpenKey('SOFTWARE\Generazione Informatica\Autentica',True) then begin
            WriteString(Title,FormAutenticazione.EditUserName.Text);
            CloseKey;
          end;
        finally
          Free;
        end;
    end;
  finally
    FormAutenticazione.Free;
  end;
end;

function CreaUtente(const ApiKey,Title,IdUser: String;
                    var MsgErrore: String; var CodErrore: Integer): Boolean;
var
  FormCreaUtente: TFormCreaUtente;
begin
  Init;
  Result:=False;
  if Length(ApiKey)=0 then begin
    CodErrore:=AutErrNoApiKey;
    MsgErrore:=MsgNoApiKey;
    Exit;
  end;
  if Length(IdUser)=0 then begin
    CodErrore:=AutErrNoIdUser;
    MsgErrore:=MsgNoIdUser;
    Exit;
  end;
  FormCreaUtente:=TFormCreaUtente.CreateNew(Application);
  try
    FormCreaUtente.FormCreate(FormCreaUtente);
    FormCreaUtente.FApiKey:=ApiKey;
    FormCreaUtente.FIDUser:=IdUser;
    if Length(Trim(Title))>0 then
      FormCreaUtente.Caption:=Title;
    FormCreaUtente.ShowModal;
    Result:=FormCreaUtente.FResult;
    MsgErrore:=FormCreaUtente.FMsgErrore;
    CodErrore:=FormCreaUtente.FCodErrore;
  finally
    FormCreaUtente.Free;
  end;
end;

function RefreshToken(const ApiKey: String; var Token: String;
                      var MsgErrore: String; var CodErrore: Integer): Boolean;
var
  JSONRequest,JSONResponse: TJSONObject;
begin
  Init;
  try
    JSONRequest:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(ApiKey));
      JSONRequest.AddPair('token',Token);
      Result:=ChiamataAutentica('RefreshToken',JSONRequest,JSONResponse,Token,MsgErrore,CodErrore);
    finally
      JSONRequest.Free;
    end;
  except
    on E:Exception do begin
      MsgErrore:=E.Message;
      CodErrore:=AutErrUnexpectedOnConfirm;
      Result:=False;
    end;
  end;
end;

function ModificaPassword(const ApiKey,Title,UserOMail: String;
                          var MsgErrore: String; var CodErrore: Integer;
                          const AHandle: Integer=0; const ACaption: String=''): Boolean;
var
  FormAutenticazione: TFormAutenticazione;
begin
  Init;
  Result:=False;
  if Length(ApiKey)=0 then begin
    CodErrore:=AutErrNoApiKey;
    MsgErrore:=MsgNoApiKey;
    Exit;
  end;
  FormAutenticazione:=TFormAutenticazione.CreateNew(Application);
  try
    FormAutenticazione.FormCreate(FormAutenticazione);
    FormAutenticazione.FApiKey:=ApiKey;
    if Length(Trim(Title))>0 then begin
      FormAutenticazione.Caption:=Title;
      with TRegistry.Create do
        try
          if OpenKeyReadOnly('SOFTWARE\Generazione Informatica\Autentica') then begin
            FormAutenticazione.EditUserName.Text:=ReadString(Title);
            CloseKey;
          end;
        finally
          Free;
        end;
    end;
    FormAutenticazione.Height:=250;
    FormAutenticazione.LabelMsg.Caption:=LblModificaPassword;
    FormAutenticazione.LabelOldPassword.Visible:=True;
    FormAutenticazione.LabelPassword.Top:=291;
    FormAutenticazione.LabelPassword.Caption:=LblNewPassword;
    FormAutenticazione.LabelPassword2.Visible:=True;
    FormAutenticazione.LabelPassword2.Top:=318;
    FormAutenticazione.EditPassword2.Visible:=True;
    FormAutenticazione.LabelPasswordDimenticata.Visible:=False;
    FormAutenticazione.LabelQui.Visible:=False;
    FormAutenticazione.ButtonConferma.Top:=255;
    FormAutenticazione.ButtonConferma.Caption:=BtnCaptionModPassword;
    FormAutenticazione.ButtonConferma.Width:=100;
    FormAutenticazione.ButtonConferma.OnClick:=FormAutenticazione.ButtonModificaPassword2Click;
    FormAutenticazione.ButtonAnnulla.Top:=355;
    FormAutenticazione.EditOldPassword.Visible:=True;
    FormAutenticazione.EditPassword.Top:=288;
    FormAutenticazione.EditPassword.Text:='';
    FormAutenticazione.EditPassword.OnChange:=FormAutenticazione.EditPasswordChange;
    FormAutenticazione.EditPassword2.Top:=315;
    FormAutenticazione.EditPassword2.Text:='';
    FormAutenticazione.ImageQualityIndicator.Top:=284;
    FormAutenticazione.ShowModal;
    Result:=FormAutenticazione.FResult;
    MsgErrore:=FormAutenticazione.FMsgErrore;
    CodErrore:=FormAutenticazione.FCodErrore;
    if (Length(Trim(Title))>0) and (CodErrore=AutNoError) then begin
      with TRegistry.Create do
        try
          if OpenKey('SOFTWARE\Generazione Informatica\Autentica',True) then begin
            WriteString(Title,FormAutenticazione.EditUserName.Text);
            CloseKey;
          end;
        finally
          Free;
        end;
    end;
  finally
    FormAutenticazione.Free;
  end;
end;

function ResetPassword(const ApiKey,UserOMail: String;
                       var MsgErrore: String; var CodErrore: Integer;
                       const AHandle: Integer=0; const ACaption: String=''): Boolean;
var
  JSONRequest,JSONResponse: TJSONObject;
  NonInteressa: String;
begin
  Init;
  try
    JSONRequest:=TJSONObject.Create;
    JSONResponse:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(ApiKey));
      JSONRequest.AddPair('userMail',TJSONString.Create(UserOMail));
      Result:=ChiamataAutentica('PasswordDimenticata',JSONRequest,JSONResponse,NonInteressa,MsgErrore,CodErrore);
      if Result then begin
        if AHandle>0 then
          MessageBox(AHandle,
                     PChar(MsgNewPasswordSent),
                     PChar(ACaption),
                     mb_IconInformation);
      end
      else begin
        if AHandle>0 then
          MessageBox(AHandle,
                     PChar(MsgErrore),
                     PChar(ACaption),
                     mb_IconError);
      end;
    finally
      JSONRequest.Free;
      JSONResponse.Free;
    end;
  except
    on E:Exception do begin
      MsgErrore:=E.Message;
      CodErrore:=AutErrUnexpectedOnConfirm;
      Result:=False;
    end;
  end;
end;

function CreateUser(const ApiKey,UserName,IDUser,Email: String;
                    var MsgErrore: String; var CodErrore: Integer;
                    const AHandle: Integer=0; const ACaption: String=''): Boolean;
var
  JSONRequest,JSONResponse: TJSONObject;
  NonInteressa: String;
begin
  Init;
  try
    JSONRequest:=TJSONObject.Create;
    JSONResponse:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(ApiKey));
      JSONRequest.AddPair('userName',UserName);
      JSONRequest.AddPair('idUser',IDUser);
      JSONRequest.AddPair('email',Email);
      Result:=ChiamataAutentica('CreaUtente',JSONRequest,JSONResponse,NonInteressa,MsgErrore,CodErrore);
      if Result then begin
        if AHandle>0 then
          MessageBox(AHandle,
                     PChar(MsgNewUserCreated),
                     PChar(ACaption),
                     mb_IconInformation);
      end
      else begin
        if AHandle>0 then
          MessageBox(AHandle,
                     PChar(MsgErrore),
                     PChar(ACaption),
                     mb_IconError);
      end;
    finally
      JSONRequest.Free;
      JSONResponse.Free;
    end;
  except
    on E:Exception do begin
      MsgErrore:=E.Message;
      CodErrore:=AutErrUnexpectedOnConfirm;
      Result:=False;
    end;
  end;
end;

function ValutazionePassword(const APwd: String): Integer;
var
  N: Integer;
begin
  Init;
  Result:=0;
  if Length(APwd)>=8 then
    Inc(Result);
  for N:=1 to Length(APwd) do begin
    if Pos(Copy(APwd,N,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ')>0 then begin
      Inc(Result);
      Break;
    end;
  end;
  for N:=1 to Length(APwd) do begin
    if Pos(Copy(APwd,N,1),'abcdefghijklmnopqrstuvwxyz')>0 then begin
      Inc(Result);
      Break;
    end;
  end;
  for N:=1 to Length(APwd) do begin
    if Pos(Copy(APwd,N,1),'0123456789')>0 then begin
      Inc(Result);
      Break;
    end;
  end;
  for N:=1 to Length(APwd) do begin
    if Pos(Copy(APwd,N,1),'\|!"£$%&/()=''?ל^[]{}ח@#°§<>,;.:-_אטילע')>0 then begin
      Inc(Result);
      Break;
    end;
  end;
end;
{$endregion}

function DatiProgetto(const cApiKey: String;
                      out oDescrizione,oEncodedLogo,oMsgErrore: String;
                      out oCodErrore: Integer): Boolean;
var
  JSONResponse,Parametri: TJSONObject;
  NonUsato: String;
begin
  JSONResponse:=TJSONObject.Create;
  Parametri:=TJSONObject.Create;
  try
    Parametri.AddPair('apiKey',cApiKey);
    Result:=ChiamataAutentica('datiProgetto',Parametri,JSONResponse,NonUsato,oMsgErrore,oCodErrore);
    if Result then begin
      JSONResponse.TryGetValue<String>('encodedLogo',oEncodedLogo);
      JSONResponse.TryGetValue<String>('descrizione',oDescrizione);
    end;
  finally
    JSONResponse.Free;
    Parametri.Free;
  end;
end;

{$region 'TFormAutenticazione'}

procedure TFormAutenticazione.FormCreate(Sender: TObject);
begin
  Name:='FormAutenticazione';
  BorderStyle:=bsDialog;
  Height:=470;
  Width:=470;
  Position:=poOwnerFormCenter;
  Caption:='Autentica GI';
  OnShow:=FormAutenticazioneShow;

  PanelTop:=TPanel.Create(Self);
  PanelTop.Name:='PanelTop';
  PanelTop.Parent:=Self;
  PanelTop.Caption:='';
  PanelTop.Align:=alTop;
  PanelTop.TabOrder:=0;

  PanelClient:=TPanel.Create(Self);
  PanelClient.Name:='PanelClient';
  PanelClient.Parent:=Self;
  PanelClient.Caption:='';
  PanelClient.Align:=alClient;
  PanelClient.TabOrder:=1;

  ImageLogoApp:=TImage.Create(Self);
  ImageLogoApp.Name:='ImageLogoApp';
  ImageLogoApp.Parent:=PanelTop;
  ImageLogoApp.Top:=10;
  ImageLogoApp.Left:=95;
  ImageLogoApp.Width:=280;
  ImageLogoApp.Height:=180;

  LabelDescApp:=TLabel.Create(Self);
  LabelDescApp.Name:='LabelDescApp';
  LabelDescApp.Parent:=PanelTop;
  LabelDescApp.AutoSize:=False;
  LabelDescApp.Alignment:=taCenter;
  LabelDescApp.Top:=200;
  LabelDescApp.Left:=0;
  LabelDescApp.Width:=470;
  LabelDescApp.WordWrap:=False;

  LabelMsg:=TLabel.Create(Self);
  LabelMsg.Name:='LabelMsg';
  LabelMsg.Parent:=PanelClient;
  LabelMsg.AutoSize:=False;
  LabelMsg.Alignment:=taCenter;
  LabelMsg.Top:=10;
  LabelMsg.Left:=0;
  LabelMsg.Width:=500;
  LabelMsg.WordWrap:=False;
  LabelMsg.Caption:=LblInitialMessage;

  LabelUserName:=TLabel.Create(Self);
  LabelUserName.Name:='LabelUserName';
  LabelUserName.Parent:=PanelClient;
  LabelUserName.Left:=30;
  LabelUserName.Top:=37;
  LabelUserName.Width:=67;
  LabelUserName.Height:=13;
  LabelUserName.Caption:=LblUserName;
  LabelUserName.FocusControl:=EditUserName;

  LabelPassword:=TLabel.Create(Self);
  LabelPassword.Name:='LabelPassword';
  LabelPassword.Parent:=PanelClient;
  LabelPassword.Left:=30;
  LabelPassword.Top:=64;
  LabelPassword.Width:=50;
  LabelPassword.Height:=13;
  LabelPassword.Caption:=LblPassword;
  LabelPassword.FocusControl:=EditPassword;

  LabelPassword2:=TLabel.Create(Self);
  LabelPassword2.Name:='LabelPassword2';
  LabelPassword2.Parent:=PanelClient;
  LabelPassword2.Left:=30;
  LabelPassword2.Top:=91;
  LabelPassword2.Width:=50;
  LabelPassword2.Height:=13;
  LabelPassword2.Caption:=LblPasswordAgain;
  LabelPassword2.FocusControl:=EditPassword;
  LabelPassword2.Visible:=False;

  LabelPasswordDimenticata:=TLabel.Create(Self);
  LabelPasswordDimenticata.Name:='LabelPasswordDimenticata';
  LabelPasswordDimenticata.Parent:=PanelClient;
  LabelPasswordDimenticata.Left:=110;
  LabelPasswordDimenticata.Top:=91;
  LabelPasswordDimenticata.Width:=140;
  LabelPasswordDimenticata.Height:=13;
  LabelPasswordDimenticata.Caption:=LblForgottenPassword;

  EditUserName:=TEdit.Create(Self);
  EditUserName.Name:='EditUserName';
  EditUserName.Text:='';
  EditUserName.Parent:=PanelClient;
  EditUserName.Left:=150;
  EditUserName.Top:=34;
  EditUserName.Width:=241;
  EditUserName.Height:=21;
  EditUserName.TabOrder:=0;
  EditUserName.OnChange:=EditChange;

  LabelOldPassword:=TLabel.Create(Self);
  LabelOldPassword.Name:='LabelOldPassword';
  LabelOldPassword.Parent:=PanelClient;
  LabelOldPassword.Left:=30;
  LabelOldPassword.Top:=64;
  LabelOldPassword.Width:=50;
  LabelOldPassword.Height:=13;
  LabelOldPassword.Caption:=LblOldPassword;
  LabelOldPassword.FocusControl:=EditPassword;
  LabelOldPassword.Visible:=False;

  EditOldPassword:=TEdit.Create(Self);
  EditOldPassword.Name:='EditOldPassword';
  EditOldPassword.Text:='';
  EditOldPassword.Parent:=PanelClient;
  EditOldPassword.Left:=150;
  EditOldPassword.Top:=61;
  EditOldPassword.Width:=241;
  EditOldPassword.Height:=21;
  EditOldPassword.TabOrder:=1;
  EditOldPassword.PasswordChar:='*';
  EditOldPassword.OnChange:=EditChange;
  EditOldPassword.Visible:=False;

  EditPassword:=TEdit.Create(Self);
  EditPassword.Name:='EditPassword';
  EditPassword.Text:='';
  EditPassword.Parent:=PanelClient;
  EditPassword.Left:=150;
  EditPassword.Top:=61;
  EditPassword.Width:=241;
  EditPassword.Height:=21;
  EditPassword.TabOrder:=2;
  EditPassword.PasswordChar:='*';
  EditPassword.OnChange:=EditChange;

  ImageQualityIndicator:=TImage.Create(Self);
  ImageQualityIndicator.Name:='ImageQualityIndicator';
  ImageQualityIndicator.Parent:=PanelClient;
  ImageQualityIndicator.Left:=414;
  ImageQualityIndicator.Top:=57;
  ImageQualityIndicator.Width:=30;
  ImageQualityIndicator.Height:=30;
  ImageQualityIndicator.Transparent:=True;
  ImageQualityIndicator.Hint:='';
  ImageQualityIndicator.ShowHint:=True;

  EditPassword2:=TEdit.Create(Self);
  EditPassword2.Name:='EditPassword2';
  EditPassword2.Text:='';
  EditPassword2.Parent:=PanelClient;
  EditPassword2.Left:=150;
  EditPassword2.Top:=88;
  EditPassword2.Width:=241;
  EditPassword2.Height:=21;
  EditPassword2.TabOrder:=3;
  EditPassword2.PasswordChar:='*';
  EditPassword2.OnChange:=EditChange;
  EditPassword2.Visible:=False;

  LabelQui:=TLabel.Create(Self);
  LabelQui.Name:='LabelQui';
  LabelQui.Parent:=PanelClient;
  LabelQui.Left:=330;
  LabelQui.Top:=91;
  LabelQui.Width:=16;
  LabelQui.Height:=13;
  LabelQui.Cursor:=crHandPoint;
  LabelQui.Caption:=LblHere;
  LabelQui.Color:=clBlue;
  LabelQui.ParentColor:=False;
  LabelQui.OnClick:=LabelQuiClick;

  ButtonConferma:=TButton.Create(Self);
  ButtonConferma.Name:='ButtonConferma';
  ButtonConferma.Parent:=PanelClient;
  ButtonConferma.Left:=125;
  ButtonConferma.Top:=128;
  ButtonConferma.Width:=75;
  ButtonConferma.Height:=25;
  ButtonConferma.Caption:=BtnConfirm;
  ButtonConferma.Default:=True;
  ButtonConferma.TabOrder:=4;
  ButtonConferma.OnClick:=ButtonConfermaClick;

  ButtonAnnulla:=TButton.Create(Self);
  ButtonAnnulla.Name:='ButtonAnnulla';
  ButtonAnnulla.Parent:=PanelClient;
  ButtonAnnulla.Left:=275;
  ButtonAnnulla.Top:=128;
  ButtonAnnulla.Width:=75;
  ButtonAnnulla.Height:=25;
  ButtonAnnulla.Cancel:=True;
  ButtonAnnulla.Caption:=BtnCancel;
  ButtonAnnulla.TabOrder:=5;
  ButtonAnnulla.OnClick:=ButtonAnnullaClick;

  ButtonPasswordless:=TButton.Create(Self);
  ButtonPasswordless.Name:='ButtonPasswordless';
  ButtonPasswordless.Parent:=PanelClient;
  ButtonPasswordless.Left:=125;
  ButtonPasswordless.Top:=170;
  ButtonPasswordless.Width:=225;
  ButtonPasswordless.Height:=30;
  ButtonPasswordless.Cancel:=False;
  ButtonPasswordless.Caption:=BtnPasswordless;
  ButtonPasswordless.TabOrder:=6;
  ButtonPasswordless.OnClick:=ButtonPasswordlessClick;

  PanelBio:=TPanel.Create(Self);
  PanelBio.Name:='PanelBio';
  PanelBio.Cursor:=crHourGlass;
  PanelBio.Parent:=Self;
  PanelBio.ParentBackground:=False;
  PanelBio.Left:=50;
  PanelBio.Top:=30;
  PanelBio.Width:=400;
  PanelBio.Height:=150;
  PanelBio.Caption:='Effettuare l''autenticazione con la App AutenticazioneSicura';
  PanelBio.Visible:=False;
  PanelBio.TabOrder:=7;

  ButtonAnnullaBio:=TButton.Create(Self);
  ButtonAnnullaBio.Name:='ButtonAnnullaBio';
  ButtonAnnullaBio.Parent:=PanelBio;
  ButtonAnnullaBio.Left:=160;
  ButtonAnnullaBio.Top:=105;
  ButtonAnnullaBio.Width:=75;
  ButtonAnnullaBio.Height:=25;
  ButtonAnnullaBio.Caption:=BtnCancel;
  ButtonAnnullaBio.TabOrder:=0;
  ButtonAnnullaBio.OnClick:=ButtonAnnullaBioClick;

  Timer:=TTimer.Create(Self);
  Timer.Enabled:=False;
  Timer.Name:='Timer';
  Timer.Interval:=30000;
  Timer.OnTimer:=TimerTimer;
  Timer.Enabled:=True;

  TimerBio:=TTimer.Create(Self);
  TimerBio.Name:='TimerBio';
  TimerBio.Interval:=100;
  TimerBio.OnTimer:=TimerBioTimer;
  TimerBio.Enabled:=False;

  FTentativi:=0;
end;

procedure TFormAutenticazione.FormAutenticazioneShow(Sender: TObject);
begin
  MostraDatiProgetto;
  FResult:=False;
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  if Length(Trim(EditUserName.Text))>0 then begin
    if EditOldPassword.Visible then
      EditOldPassword.SetFocus
    else
      EditPassword.SetFocus;
  end;
  if FBio then
    TimerBio.Enabled:=True;
end;

procedure TFormAutenticazione.ButtonConfermaClick(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
  procedure StopBio;
  begin
    if FBio then begin
      with TRegistry.Create do
        try
          if OpenKey('SOFTWARE\Generazione Informatica\Autentica',True) then begin
            WriteBool('Bio',False);
            CloseKey;
          end;
        finally
          Free;
        end;
    end;
  end;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserName),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  if not FBio then
    if Length(Trim(EditPassword.Text))=0 then begin
      MessageBox(Handle,
                 PChar(MsgNoPassword),
                 PChar(Caption),
                 mb_IconError);
      EditPassword.SetFocus;
      Exit;
    end;
  try
    JSONRequest:=TJSONObject.Create;
    JSONResponse:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userName',EditUserName.Text);
      if not FBio then
        JSONRequest.AddPair('improntaPwd',THashSHA2.GetHashString(EditPassword.Text));
      if Length(FNonce)>0 then
        JSONRequest.AddPair('nonce',FNonce);
      if FBio then begin
        PanelBio.Visible:=True;
        ButtonPasswordless.Enabled:=False;
        Application.ProcessMessages;
        FCodErrore:=-1;
        TTask.Run(procedure
                   begin
                     FResult:=ChiamataAutentica('AutenticazioneBio',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
                   end);
        while FCodErrore<0 do
          Application.ProcessMessages;
      end
      else begin
        StopBio;
        FResult:=ChiamataAutentica('Autenticazione',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
      end;
      if FBio then begin
        PanelBio.Visible:=False;
        ButtonPasswordless.Enabled:=True;
        Application.ProcessMessages;
      end;
      if FCodErrore=1414 then begin
        MessageBox(Handle,
                   PChar(MsgBioInterrotto),
                   PChar(Caption),
                   mb_IconInformation);
        Exit;
      end;
      if FCodErrore=1415 then begin
        MessageBox(Handle,
                   PChar(MsgTimeoutBio),
                   PChar(Caption),
                   mb_IconExclamation);
        Exit;
      end;
      if (FCodErrore=305) or
         (FCodErrore=310) or
         (FCodErrore=311) or
         (FCodErrore=1405) or
         (FCodErrore=1410) or
         (FCodErrore=1411) then begin // Credenziali errate
        if FTentativi>=2 then begin
          StopBio;
          Close;
          Exit;
        end;
        MessageBox(Handle,
                   PChar(MsgCredenzialiErrate),
                   PChar(Caption),
                   mb_IconError);
        Inc(FTentativi);
        EditPassword.SetFocus;
        StopBio;
        Exit;
      end;
      if JSONResponse.Parse(BytesOf(TNetEncoding.Base64.Decode(ExtractWord(2,FToken,'.'))),0)>0 then
        if not JSONResponse.TryGetValue('ID_USER',FIDUser) then
          JSONResponse.TryGetValue('sub',FIDUser);
      if (FCodErrore=312) or
         (FCodErrore=313) or
         (FCodErrore=1412) or
         (FCodErrore=1413) then begin //Pwd scaduta
        FOldPwd:=EditPassword.Text;
        LabelMsg.Caption:=MsgPasswordExpired;
        LabelPassword.Caption:=LblNewPassword;
        LabelPassword2.Visible:=True;
        EditPassword2.Visible:=True;
        LabelPasswordDimenticata.Visible:=False;
        LabelQui.Visible:=False;
        ButtonConferma.Caption:=BtnCaptionModPassword;
        ButtonConferma.Width:=100;
        ButtonConferma.OnClick:=ButtonModificaPasswordClick;
        EditPassword.Text:='';
        EditPassword.OnChange:=EditPasswordChange;
        EditPassword.SetFocus;
        EditPassword2.Text:='';
        Exit;
      end;
      Close;
    finally
      JSONRequest.Free;
      JSONResponse.Free;
    end;
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnConfirm;
      FResult:=False;
      Close;
    end;
  end;
end;

procedure TFormAutenticazione.ButtonAnnullaClick(Sender: TObject);
begin
  if FBio then
    ButtonAnnullaBioClick(Self);
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  Close;
end;

procedure TFormAutenticazione.ButtonRichiediNPwdClick(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserNameEmail),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  try
    JSONRequest:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userMail',EditUserName.Text);
      FResult:=ChiamataAutentica('PasswordDimenticata',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
      if FResult then begin
        MessageBox(Handle,
                   PChar(MsgNewPasswordSent),
                   PChar(Caption),
                   mb_IconInformation);
        LabelUserName.Caption:=LblUserName;
        LabelPassword.Visible:=True;
        EditPassword.Visible:=True;
        LabelPasswordDimenticata.Visible:=False;
        LabelQui.Visible:=False;
        ButtonConferma.Caption:=BtnConfirm;
        ButtonConferma.Width:=75;
        ButtonConferma.OnClick:=ButtonConfermaClick;
        EditUserName.Text:='';
      end
      else begin
        MessageBox(Handle,
                   PChar(FMsgErrore),
                   PChar(Caption),
                   mb_IconError);
      end;
      EditUserName.SetFocus;
    finally
      JSONRequest.Free;
    end;
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnRequestNewPwd;
      FResult:=False;
      Close;
    end;
  end;
end;

procedure TFormAutenticazione.ButtonModificaPasswordClick(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserName),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  if Length(Trim(EditPassword.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoNewPassword),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if Length(Trim(EditPassword2.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoRepeatPassword),
               PChar(Caption),
               mb_IconError);
    EditPassword2.SetFocus;
    Exit;
  end;
  if EditPassword.Text<>EditPassword2.Text then begin
    MessageBox(Handle,
               PChar(MsgPasswordsDontMatch),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if ImageQualityIndicator.Tag<5 then begin
    if MessageBox(Handle,
                  PChar(MsgPasswordsNotGood),
                  PChar(Caption),
                  mb_IconExclamation+mb_YesNo+mb_DefButton2)=idNo then begin
      EditPassword.SetFocus;
      Exit;
    end;
  end;
  try
    JSONRequest:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userName',EditUserName.Text);
      JSONRequest.AddPair('improntaVecchiaPwd',THashSHA2.GetHashString(FOldPwd));
      JSONRequest.AddPair('improntaNuovaPwd',THashSHA2.GetHashString(EditPassword.Text));
      FResult:=ChiamataAutentica('ModificaPassword',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
      if FResult then begin
        LabelUserName.Caption:=LblUserName;
        LabelPassword.Visible:=True;
        EditPassword.Visible:=True;
        LabelPasswordDimenticata.Visible:=False;
        LabelQui.Visible:=False;
        ButtonConferma.Caption:=BtnConfirm;
        ButtonConferma.Width:=75;
        ButtonConferma.OnClick:=ButtonConfermaClick;
        ButtonConfermaClick(ButtonConferma);
      end
      else begin
        MessageBox(Handle,
                   PChar(FMsgErrore),
                   PChar(Caption),
                   mb_IconError);
        EditUserName.SetFocus;
      end;
    finally
      JSONRequest.Free;
    end;
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnChangePassword;
      FResult:=False;
      Close;
    end;
  end;
end;

procedure TFormAutenticazione.ButtonModificaPassword2Click(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserName),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  if Length(Trim(EditPassword.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoNewPassword),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if Length(Trim(EditPassword2.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoRepeatPassword),
               PChar(Caption),
               mb_IconError);
    EditPassword2.SetFocus;
    Exit;
  end;
  if EditPassword.Text<>EditPassword2.Text then begin
    MessageBox(Handle,
               PChar(MsgPasswordsDontMatch),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if ImageQualityIndicator.Tag<5 then begin
    if MessageBox(Handle,
                  PChar(MsgPasswordsNotGood),
                  PChar(Caption),
                  mb_IconExclamation+mb_YesNo+mb_DefButton2)=idNo then begin
      EditPassword.SetFocus;
      Exit;
    end;
  end;
  try
    JSONRequest:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userName',EditUserName.Text);
      JSONRequest.AddPair('improntaVecchiaPwd',THashSHA2.GetHashString(EditOldPassword.Text));
      JSONRequest.AddPair('improntaNuovaPwd',THashSHA2.GetHashString(EditPassword.Text));
      FResult:=ChiamataAutentica('ModificaPassword',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
      if FResult then begin
        Close;
      end
      else begin
        MessageBox(Handle,
                   PChar(FMsgErrore),
                   PChar(Caption),
                   mb_IconError);
        EditUserName.SetFocus;
      end;
    finally
      JSONRequest.Free;
    end;
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnChangePassword;
      FResult:=False;
      Close;
    end;
  end;
end;

procedure TFormAutenticazione.ButtonPasswordlessClick(Sender: TObject);
var
  FormPasswordless: TFormPasswordless;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserName),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  FormPasswordless:=TFormPasswordless.CreateNew(Application);
  try
    FormPasswordless.FormCreate(FormPasswordless);
    FormPasswordless.FApiKey:=FApiKey;
    FormPasswordless.FUserName:=EditUserName.Text;
    if FormPasswordless.ShowModal=mrOk then begin
      FBio:=True;
      TimerBio.Enabled:=True;
    end;
  finally
    FormPasswordless.Free;
  end;
end;

procedure TFormAutenticazione.LabelQuiClick(Sender: TObject);
begin
  Timer.Enabled:=False;
  LabelMsg.Caption:=LblRequestNewPassword;
  LabelUserName.Caption:=LblUserNameOrEmail;
  LabelPassword.Visible:=False;
  EditPassword.Visible:=False;
  LabelPasswordDimenticata.Visible:=False;
  LabelQui.Visible:=False;
  ButtonConferma.Caption:=BtnRequestPassword;
  ButtonConferma.Width:=100;
  ButtonConferma.OnClick:=ButtonRichiediNPwdClick;
  EditUserName.SetFocus;
end;

procedure TFormAutenticazione.EditChange(Sender: TObject);
begin
  Timer.Enabled:=False;
  if (Sender is TEdit) and
     ((Sender as TEdit).Name='EditPassword') then
    FBio:=False;
end;

procedure TFormAutenticazione.EditPasswordChange(Sender: TObject);
  procedure DrawIndicator(const AVal: Integer);
  var
    Center: TPoint;
    Bitmap: Vcl.Graphics.TBitmap;
    Radius: Integer;
  const
    APerc: array[0..5] of Integer=(88,18,-54,-126,-178,90);
  begin
    Assert(ImageQualityIndicator.Width = ImageQualityIndicator.Height);
    Bitmap:=Vcl.Graphics.TBitmap.Create;
    try
      Bitmap.Width:=ImageQualityIndicator.Width;
      Bitmap.Height:=ImageQualityIndicator.Height;
      Bitmap.PixelFormat:=pf24bit;
      if AVal=5 then begin
        Bitmap.Canvas.Brush.Color:=clLime;
        Bitmap.Canvas.Pen.Color:=clLime;
      end
      else begin
        Bitmap.Canvas.Brush.Color:=clRed;
        Bitmap.Canvas.Pen.Color:=clRed;
      end;
      Center:=Point(Bitmap.Width div 2,Bitmap.Height div 2);
      Radius:=Bitmap.Width div 2;
      DrawPieSlice(Bitmap.Canvas,Center,Radius,APerc[AVal],90);
      ImageQualityIndicator.Picture.Graphic:=Bitmap;
      ImageQualityIndicator.Hint:=HintPwd[AVal];
      ImageQualityIndicator.Tag:=AVal;
    finally
      Bitmap.Free;
    end;
  end;
begin
  Timer.Enabled:=False;
  DrawIndicator(ValutazionePassword((Sender as TEdit).Text));
end;

procedure TFormAutenticazione.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  FResult:=False;
  FMsgErrore:=MsgTimeout;
  FCodErrore:=AutErrTimeout;
  Close;
end;

procedure TFormAutenticazione.TimerBioTimer(Sender: TObject);
begin
  TimerBio.Enabled:=False;
  ButtonConfermaClick(ButtonConferma);
end;

procedure TFormAutenticazione.ButtonAnnullaBioClick(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
  lMsgErrore: String;
  lCodErrore: Integer;
begin
  if FBio then begin
    with TRegistry.Create do
      try
        if OpenKey('SOFTWARE\Generazione Informatica\Autentica',True) then begin
          WriteBool('Bio',False);
          CloseKey;
        end;
      finally
        Free;
      end;
    JSONRequest:=TJSONObject.Create;
    JSONResponse:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userName',EditUserName.Text);
      FResult:=ChiamataAutentica('AnnullaAutenticazioneBio',JSONRequest,JSONResponse,FToken,lMsgErrore,lCodErrore);
    finally
      JSONRequest.Free;
      JSONResponse.Free;
    end;
  end;
end;

procedure TFormAutenticazione.MostraDatiProgetto;
var
  encodedLogo,FDescrizione: String;
  aStream: TMemoryStream;
begin
  FResult:=DatiProgetto(FApiKey,FDescrizione,encodedLogo,FMsgErrore,FCodErrore);
  if FResult then begin
    LabelDescApp.Caption:=FDescrizione;
    if encodedLogo.Trim.IsEmpty then begin
      Self.Height:=270;
      PanelTop.Height:=20;
      LabelDescApp.Top:=3;
      PanelBio.Top:=30;
    end
    else begin
      Self.Height:=470;
      PanelTop.Height:=220;
      LabelDescApp.Top:=200;
      PanelBio.Top:=230;
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(encodedLogo,aStream);
        AStream.Seek(0,soBeginning);
        ZoomImage(aStream,ImageLogoApp);
      finally
        aStream.Free;
      end;
    end;
  end;
end;

{$endregion }

{$region 'TFormCreaUtente'}

procedure TFormCreaUtente.FormCreate(Sender: TObject);
begin
  Name:='FormCreaUtente';
  BorderStyle:=bsDialog;
  Height:=250;
  Width:=450;
  Position:=poOwnerFormCenter;
  Caption:='Autenticazione Sicura';
  OnShow:=FormCreaUtenteShow;

  PanelTop:=TPanel.Create(Self);
  PanelTop.Name:='PanelTop';
  PanelTop.Parent:=Self;
  PanelTop.Caption:='';
  PanelTop.Align:=alTop;
  PanelTop.TabOrder:=0;

  PanelClient:=TPanel.Create(Self);
  PanelClient.Name:='PanelClient';
  PanelClient.Parent:=Self;
  PanelClient.Caption:='';
  PanelClient.Align:=alClient;
  PanelClient.TabOrder:=1;

  ImageLogoApp:=TImage.Create(Self);
  ImageLogoApp.Name:='ImageLogoApp';
  ImageLogoApp.Parent:=PanelTop;
  ImageLogoApp.Top:=10;
  ImageLogoApp.Left:=95;
  ImageLogoApp.Width:=280;
  ImageLogoApp.Height:=180;

  LabelDescApp:=TLabel.Create(Self);
  LabelDescApp.Name:='LabelDescApp';
  LabelDescApp.Parent:=PanelTop;
  LabelDescApp.AutoSize:=False;
  LabelDescApp.Alignment:=taCenter;
  LabelDescApp.Top:=200;
  LabelDescApp.Left:=0;
  LabelDescApp.Width:=470;
  LabelDescApp.WordWrap:=False;

  LabelMsg:=TLabel.Create(Self);
  LabelUserName:=TLabel.Create(Self);
  LabelEmail:=TLabel.Create(Self);
  LabelPassword:=TLabel.Create(Self);
  ImageQualityIndicator:=TImage.Create(Self);
  LabelPassword2:=TLabel.Create(Self);
  EditUserName:=TEdit.Create(Self);
  EditEmail:=TEdit.Create(Self);
  EditPassword:=TEdit.Create(Self);
  EditPassword2:=TEdit.Create(Self);

  LabelMsg.Name:='LabelMsg';
  LabelMsg.Parent:=PanelClient;
  LabelMsg.Left:=0;
  LabelMsg.Top:=10;
  LabelMsg.Width:=PanelClient.Width;
  LabelMsg.Height:=13;
  LabelMsg.Alignment:=taCenter;
  LabelMsg.Anchors:=[akLeft, akTop, akRight];
  LabelMsg.AutoSize:=False;
  LabelMsg.Caption:=LblInitialCreateUser;

  LabelUserName.Name:='LabelUserName';
  LabelUserName.Parent:=PanelClient;
  LabelUserName.Left:=30;
  LabelUserName.Top:=37;
  LabelUserName.Width:=67;
  LabelUserName.Height:=13;
  LabelUserName.Caption:=LblUserName;
  LabelUserName.FocusControl:=EditUserName;

  LabelEmail.Name:='LabelEmail';
  LabelEmail.Parent:=PanelClient;
  LabelEmail.Left:=30;
  LabelEmail.Top:=64;
  LabelEmail.Width:=71;
  LabelEmail.Height:=13;
  LabelEmail.Caption:=LblEmailAddress;
  LabelEmail.FocusControl:=EditEmail;

  LabelPassword.Name:='LabelPassword';
  LabelPassword.Parent:=PanelClient;
  LabelPassword.Left:=30;
  LabelPassword.Top:=101;
  LabelPassword.Width:=50;
  LabelPassword.Height:=13;
  LabelPassword.Caption:=LblPassword;
  LabelPassword.FocusControl:=EditPassword;

  LabelPassword2.Name:='LabelPassword2';
  LabelPassword2.Parent:=PanelClient;
  LabelPassword2.Left:=30;
  LabelPassword2.Top:=128;
  LabelPassword2.Width:=80;
  LabelPassword2.Height:=13;
  LabelPassword2.Caption:=LblPasswordAgain;
  LabelPassword2.FocusControl:=EditPassword2;

  EditUserName.Name:='EditUserName';
  EditUserName.Parent:=PanelClient;
  EditUserName.Left:=150;
  EditUserName.Top:=34;
  EditUserName.Width:=241;
  EditUserName.Height:=21;
  EditUserName.TabOrder:=0;
  EditUserName.Text:='';
  EditUserName.OnChange:=EditChange;

  EditEmail.Name:='EditEmail';
  EditEmail.Parent:=PanelClient;
  EditEmail.Left:=150;
  EditEmail.Top:=61;
  EditEmail.Width:=241;
  EditEmail.Height:=21;
  EditEmail.TabOrder:=1;
  EditEmail.Text:='';
  EditEmail.OnChange:=EditChange;

  EditPassword.Name:='EditPassword';
  EditPassword.Parent:=PanelClient;
  EditPassword.Left:=150;
  EditPassword.Top:=98;
  EditPassword.Width:=241;
  EditPassword.Height:=21;
  EditPassword.PasswordChar:='*';
  EditPassword.TabOrder:=2;
  EditPassword.Text:='';
  EditPassword.OnChange:=EditPasswordChange;

  ImageQualityIndicator.Name:='ImageQualityIndicator';
  ImageQualityIndicator.Parent:=PanelClient;
  ImageQualityIndicator.Left:=414;
  ImageQualityIndicator.Top:=94;
  ImageQualityIndicator.Width:=30;
  ImageQualityIndicator.Height:=30;
  ImageQualityIndicator.Transparent:=True;
  ImageQualityIndicator.Hint:='';
  ImageQualityIndicator.ShowHint:=True;

  EditPassword2.Name:='EditPassword2';
  EditPassword2.Parent:=PanelClient;
  EditPassword2.Left:=150;
  EditPassword2.Top:=125;
  EditPassword2.Width:=241;
  EditPassword2.Height:=21;
  EditPassword2.PasswordChar:='*';
  EditPassword2.TabOrder:=3;
  EditPassword2.Text:='';
  EditPassword2.OnChange:=EditChange;

  ButtonConferma:=TButton.Create(Self);
  ButtonConferma.Name:='ButtonConferma';
  ButtonConferma.Parent:=PanelClient;
  ButtonConferma.Left:=100;
  ButtonConferma.Top:=170;
  ButtonConferma.Width:=75;
  ButtonConferma.Height:=25;
  ButtonConferma.Caption:=BtnConfirm;
  ButtonConferma.Default:=True;
  ButtonConferma.TabOrder:=4;
  ButtonConferma.OnClick:=ButtonConfermaClick;

  ButtonAnnulla:=TButton.Create(Self);
  ButtonAnnulla.Name:='ButtonAnnulla';
  ButtonAnnulla.Parent:=PanelClient;
  ButtonAnnulla.Left:=250;
  ButtonAnnulla.Top:=170;
  ButtonAnnulla.Width:=75;
  ButtonAnnulla.Height:=25;
  ButtonAnnulla.Cancel:=True;
  ButtonAnnulla.Caption:=BtnCancel;
  ButtonAnnulla.TabOrder:=5;
  ButtonAnnulla.OnClick:=ButtonAnnullaClick;

  Timer:=TTimer.Create(Self);
  Timer.Enabled:=False;
  Timer.Name:='Timer';
  Timer.Interval:=30000;
  Timer.OnTimer:=TimerTimer;
  Timer.Enabled:=True;
end;

procedure TFormCreaUtente.FormCreaUtenteShow(Sender: TObject);
begin
  MostraDatiProgetto;
  FResult:=False;
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
end;

procedure TFormCreaUtente.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  FResult:=False;
  FMsgErrore:=MsgTimeout;
  FCodErrore:=AutErrTimeout;
  Close;
end;

procedure TFormCreaUtente.EditChange(Sender: TObject);
begin
  Timer.Enabled:=False;
end;

procedure TFormCreaUtente.EditPasswordChange(Sender: TObject);
  procedure DrawIndicator(const AVal: Integer);
  var
    Center: TPoint;
    Bitmap: Vcl.Graphics.TBitmap;
    Radius: Integer;
  const
    APerc: array[0..5] of Integer=(88,18,-54,-126,-178,90);
  begin
    Assert(ImageQualityIndicator.Width = ImageQualityIndicator.Height);
    Bitmap:=Vcl.Graphics.TBitmap.Create;
    try
      Bitmap.Width:=ImageQualityIndicator.Width;
      Bitmap.Height:=ImageQualityIndicator.Height;
      Bitmap.PixelFormat:=pf24bit;
      if AVal=5 then begin
        Bitmap.Canvas.Brush.Color:=clLime;
        Bitmap.Canvas.Pen.Color:=clLime;
      end
      else begin
        Bitmap.Canvas.Brush.Color:=clRed;
        Bitmap.Canvas.Pen.Color:=clRed;
      end;
      Center:=Point(Bitmap.Width div 2,Bitmap.Height div 2);
      Radius:=Bitmap.Width div 2;
      DrawPieSlice(Bitmap.Canvas,Center,Radius,APerc[AVal],90);
      ImageQualityIndicator.Picture.Graphic:=Bitmap;
      ImageQualityIndicator.Hint:=HintPwd[AVal];
      ImageQualityIndicator.Tag:=AVal;
    finally
      Bitmap.Free;
    end;
  end;
begin
  Timer.Enabled:=False;
  DrawIndicator(ValutazionePassword((Sender as TEdit).Text));
end;

procedure TFormCreaUtente.ButtonConfermaClick(Sender: TObject);
var
  JSONRequest,JSONResponse: TJSONObject;
  NonInteressa: String;
  function IndirizzoEmailValido(const UnIndirizzo: String): Boolean;
    function CountOfChar(const Ch: Char; const S: string): Integer;
    var
      I: Integer;
    begin
      Result:=0;
      for I:=1 to Length(S) do
        if S[I] = Ch then
          Inc(Result);
    end;
  begin
    if (CountOfChar('@',UnIndirizzo)<>1) or
       (Pos('.',UnIndirizzo)=0) or
       (Copy(UnIndirizzo,Length(UnIndirizzo),1)='.') then
      Result:=False
    else
      Result:=True;
  end;
begin
  Timer.Enabled:=False;
  if Length(Trim(EditUserName.Text))=0 then begin
    MessageBox(Handle,
               PChar(MsgNoUserName),
               PChar(Caption),
               mb_IconError);
    EditUserName.SetFocus;
    Exit;
  end;
  if (Length(Trim(EditEmail.Text))>0) and
     (not IndirizzoEmailValido(EditEmail.Text)) then begin
    MessageBox(Handle,
               PChar(MsgInvalidEmail),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if (not IndirizzoEmailValido(EditUserName.Text)) and
     (Length(Trim(EditEmail.Text))=0) and
     (Length(Trim(EditPassword.Text))=0) then begin
    MessageBox(Handle,
               PChar(MsgNoEmail),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if (Length(Trim(EditPassword.Text))>0) and
     (Length(Trim(EditPassword2.Text))=0) then begin
    MessageBox(Handle,
               PChar(MsgNoRepeatPassword),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if (Length(Trim(EditPassword.Text))>0) and
     (EditPassword.Text<>EditPassword2.Text) then begin
    MessageBox(Handle,
               PChar(MsgPasswordsDontMatch),
               PChar(Caption),
               mb_IconError);
    EditPassword.SetFocus;
    Exit;
  end;
  if (Length(Trim(EditPassword.Text))>0) and
     (ImageQualityIndicator.Tag<5) then begin
    if MessageBox(Handle,
                  PChar(MsgPasswordsNotGood),
                  PChar(Caption),
                  mb_IconExclamation+mb_YesNo+mb_DefButton2)=idNo then begin
      EditPassword.SetFocus;
      Exit;
    end;
  end;
  try
    JSONRequest:=TJSONObject.Create;
    try
      JSONRequest.AddPair('apiKey',TJSONString.Create(FApiKey));
      JSONRequest.AddPair('userName',EditUserName.Text);
      JSONRequest.AddPair('idUser',FIDUser);
      if (Length(Trim(EditPassword.Text))>0) then
        JSONRequest.AddPair('improntaPwd',THashSHA2.GetHashString(EditPassword.Text));
      if (Length(Trim(EditEmail.Text))>0) then
        JSONRequest.AddPair('email',EditEmail.Text);
      FResult:=ChiamataAutentica('CreaUtente',JSONRequest,JSONResponse,NonInteressa,FMsgErrore,FCodErrore);
      Close;
    finally
      JSONRequest.Free;
    end;
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnConfirm;
      FResult:=False;
      Close;
    end;
  end;
end;

procedure TFormCreaUtente.ButtonAnnullaClick(Sender: TObject);
begin
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  Close;
end;

procedure TFormCreaUtente.MostraDatiProgetto;
var
  encodedLogo,FDescrizione: String;
  aStream: TMemoryStream;
begin
  FResult:=DatiProgetto(FApiKey,FDescrizione,encodedLogo,FMsgErrore,FCodErrore);
  if FResult then begin
    LabelDescApp.Caption:=FDescrizione;
    if encodedLogo.Trim.IsEmpty then begin
      Self.Height:=270;
      PanelTop.Height:=20;
      LabelDescApp.Top:=3;
    end
    else begin
      Self.Height:=470;
      PanelTop.Height:=220;
      LabelDescApp.Top:=200;
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(encodedLogo,aStream);
        AStream.Seek(0,soBeginning);
        ZoomImage(aStream,ImageLogoApp);
      finally
        aStream.Free;
      end;
    end;
  end;
end;

{$endregion}

{$region 'TFormPasswordless'}

procedure TFormPasswordless.FormCreate(Sender: TObject);
begin
  Name:='FormPasswordless';
  BorderStyle:=bsDialog;
  BorderWidth:=10;
  Caption:='Autenticazione Passwordless';
  ClientHeight:=480;
  ClientWidth:=647;
  Color:=clBtnFace;
  OldCreateOrder:=False;
  PixelsPerInch:=96;
  Position:=poScreenCenter;
  OnShow:=FormPasswordlessShow;

  LabelMsg:=TLabel.Create(Self);
  ImageAppAndroid:=TImage.Create(Self);
  ImageAppIos:=TImage.Create(Self);
  LabelAppAndroid:=TLabel.Create(Self);
  LabelAppIos:=TLabel.Create(Self);
  ImageLogoApp:=TImage.Create(Self);
  LabelApiKeyUtente:=TLabel.Create(Self);
  ImageApiKeyUtente:=TImage.Create(Self);
  ButtonConferma:=TButton.Create(Self);
  ButtonAnnulla:=TButton.Create(Self);

  LabelMsg.Name:='LabelMsg';
  LabelMsg.Parent:=Self;
  LabelMsg.Left:=0;
  LabelMsg.Top:=0;
  LabelMsg.Width:=647;
  LabelMsg.Height:=33;
  LabelMsg.Align:=alTop;
  LabelMsg.Alignment:=taCenter;
  LabelMsg.Caption:=LblPrerequisiti;
  LabelMsg.WordWrap:=True;

  ImageAppAndroid.Name:='ImageAppAndroid';
  ImageAppAndroid.Parent:=Self;
  ImageAppAndroid.Left:=88;
  ImageAppAndroid.Top:=40;
  ImageAppAndroid.Width:=105;
  ImageAppAndroid.Height:=105;

  LabelAppAndroid.Name:='LabelAppAndroid';
  LabelAppAndroid.Parent:=Self;
  LabelAppAndroid.Left:=88;
  LabelAppAndroid.Top:=151;
  LabelAppAndroid.Width:=105;
  LabelAppAndroid.Height:=42;
  LabelAppAndroid.Alignment:=taCenter;
  LabelAppAndroid.AutoSize:=False;
  LabelAppAndroid.Caption:=LblAppAndroid;
  LabelAppAndroid.WordWrap:=True;

  ImageAppIos.Name:='ImageAppIos';
  ImageAppIos.Parent:=Self;
  ImageAppIos.Left:=424;
  ImageAppIos.Top:=40;
  ImageAppIos.Width:=105;
  ImageAppIos.Height:=105;

  LabelAppIos.Name:='LabelAppIos';
  LabelAppIos.Parent:=Self;
  LabelAppIos.Left:=424;
  LabelAppIos.Top:=151;
  LabelAppIos.Width:=105;
  LabelAppIos.Height:=42;
  LabelAppIos.Alignment:=taCenter;
  LabelAppIos.AutoSize:=False;
  LabelAppIos.Caption:=LblAppIos;
  LabelAppIos.WordWrap:=True;

  ImageLogoApp.Name:='ImageLogoApp';
  ImageLogoApp.Parent:=Self;
  ImageLogoApp.Left:=10;
  ImageLogoApp.Top:=214;
  ImageLogoApp.Width:=280;
  ImageLogoApp.Height:=180;

  ImageApiKeyUtente.Name:='ImageApiKeyUtente';
  ImageApiKeyUtente.Parent:=Self;
  ImageApiKeyUtente.Left:=424;
  ImageApiKeyUtente.Top:=234;
  ImageApiKeyUtente.Width:=105;
  ImageApiKeyUtente.Height:=105;

  LabelApiKeyUtente.Name:='LabelApiKeyUtente';
  LabelApiKeyUtente.Parent:=Self;
  LabelApiKeyUtente.Left:=350;
  LabelApiKeyUtente.Top:=353;
  LabelApiKeyUtente.Width:=225;
  LabelApiKeyUtente.Height:=62;
  LabelApiKeyUtente.Alignment:=taCenter;
  LabelApiKeyUtente.AutoSize:=False;
  LabelApiKeyUtente.Caption:=LblApiKeyUtente;
  LabelApiKeyUtente.WordWrap:=True;

  ButtonConferma.Name:='ButtonConferma';
  ButtonConferma.Parent:=Self;
  ButtonConferma.Left:=208;
  ButtonConferma.Top:=431;
  ButtonConferma.Width:=75;
  ButtonConferma.Height:=25;
  ButtonConferma.Caption:=BtnConfirm;
  ButtonConferma.Default:=True;
  ButtonConferma.TabOrder:=0;
  ButtonConferma.ModalResult:=mrOk;
  ButtonConferma.OnClick:=ButtonConfermaClick;

  ButtonAnnulla.Name:='ButtonAnnulla';
  ButtonAnnulla.Parent:=Self;
  ButtonAnnulla.Left:=360;
  ButtonAnnulla.Top:=431;
  ButtonAnnulla.Width:=75;
  ButtonAnnulla.Height:=25;
  ButtonAnnulla.Cancel:=True;
  ButtonAnnulla.Caption:=BtnCancel;
  ButtonAnnulla.TabOrder:=1;
  ButtonAnnulla.ModalResult:=mrCancel;
end;

procedure TFormPasswordless.FormPasswordlessShow(Sender: TObject);
begin
  try
    TTask.Run(QRCodeAndroid);
    TTask.Run(QRCodeIos);
    TTask.Run(QRCodeApikeyUsername);
    MostraDatiProgetto;
    LabelApiKeyUtente.Caption:=StringReplace(LabelApiKeyUtente.Caption,'%1',FDescrizione,[]);
    LabelApiKeyUtente.Caption:=StringReplace(LabelApiKeyUtente.Caption,'%2',FUserName,[]);
  except
    on E:Exception do begin
      FMsgErrore:=E.Message;
      FCodErrore:=AutErrUnexpectedOnConfirm;
      Close;
    end;
  end;
end;

procedure TFormPasswordless.ButtonConfermaClick(Sender: TObject);
begin
  with TRegistry.Create do
    try
      if OpenKey('SOFTWARE\Generazione Informatica\Autentica',True) then begin
        WriteBool('Bio',True);
        CloseKey;
      end;
    finally
      Free;
    end;
end;

procedure TFormPasswordless.MostraDatiProgetto;
var
  encodedLogo: String;
  aStream: TMemoryStream;
begin
  FResult:=DatiProgetto(FApiKey,FDescrizione,encodedLogo,FMsgErrore,FCodErrore);
  if FResult then begin
    if not encodedLogo.Trim.IsEmpty then begin
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(encodedLogo,aStream);
        AStream.Seek(0,soBeginning);
        ZoomImage(aStream,ImageLogoApp);
      finally
        aStream.Free;
      end;
    end;
  end;
end;

procedure TFormPasswordless.QRCodeAndroid;
var
  JSONResponse: TJSONObject;
  NonUsato,qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica('qrcode/Android',nil,JSONResponse,NonUsato,FMsgErrore,FCodErrore);
    if Fresult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,ImageAppAndroid);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

procedure TFormPasswordless.QRCodeApikeyUsername;
var
  JSONResponse: TJSONObject;
  NonUsato,qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica('qrcode/'+FApiKey+'/'+FUserName,nil,JSONResponse,NonUsato,FMsgErrore,FCodErrore);
    if Fresult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,ImageApiKeyUtente);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

procedure TFormPasswordless.QRCodeIos;
var
  JSONResponse: TJSONObject;
  NonUsato,qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica('qrcode/iOS',nil,JSONResponse,NonUsato,FMsgErrore,FCodErrore);
    if Fresult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,ImageAppIos);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

procedure TFormPasswordless.ZoomQRCode(const AStream: TMemoryStream; const DestImage: TImage);
var
  SourceBitmap,TempBitmap: Vcl.Graphics.TBitmap;
begin
  SourceBitmap:=Vcl.Graphics.TBitmap.Create;
  TempBitmap:=Vcl.Graphics.TBitmap.Create;
  try
    SourceBitmap.LoadFromStream(aStream);
    TempBitmap.Width:=DestImage.Width;
    TempBitmap.Height:=DestImage.Height;
    SetStretchBltMode(TempBitmap.Canvas.Handle,STRETCH_ANDSCANS);
    SetBrushOrgEx(TempBitmap.Canvas.Handle,0,0,nil);
    StretchBlt(TempBitmap.Canvas.Handle,
               0,0,TempBitmap.Width,TempBitmap.Height,
               SourceBitmap.Canvas.Handle,
               0,0,SourceBitmap.Width,SourceBitmap.Height,
               SRCCOPY);
    DestImage.Picture.Bitmap.Assign(TempBitmap);
  finally
    SourceBitmap.Free;
    TempBitmap.Free;
  end;
end;

{$endregion}

end.
