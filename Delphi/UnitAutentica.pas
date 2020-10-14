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
     Winapi.Windows, REST.Client, REST.Types;

const
  MsgNoApiKey='ApiKey non fornita';
  MsgNoToken='Token non fornito';
  MsgNoIdUser='IdUser non fornito';
  MsgNoCredentials='Operazione annullata. Credenziali non immesse';
  MsgNoUserName='Nome Utente non immesso';
  MsgNoPassword='Password non immessa';
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

  BtnCaptionModPassword='&Modifica Password';
  BtnConfirm='&Conferma';
  BtnCancel='&Annulla';
  BtnRequestPassword='&Richiedi Password';

  HintPwd: Array[0..5] of String = ('Valutazione della password immessa','Scadente','Scarsa','Insufficiente','Ci siamo quasi','Accettabile');

type
  TFormAutenticazione = class(TForm)
  private
    FApiKey: String;
    FNonce: String;
    FIDUser: String;
    FToken: String;
    FResult: Boolean;
    FMsgErrore: String;
    FOldPwd: String;
    FCodErrore,FTentativi: Integer;
    LabelMsg: TLabel;
    LabelPasswordDimenticata: TLabel;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
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
    procedure FormCreate(Sender: TObject);
    procedure FormAutenticazioneShow(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonRichiediNPwdClick(Sender: TObject);
    procedure ButtonModificaPasswordClick(Sender: TObject);
    procedure ButtonModificaPassword2Click(Sender: TObject);
    procedure LabelQuiClick(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditPasswordChange(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
  end;

  TFormCreaUtente = class(TForm)
  private
    FApiKey: String;
    FIDUser: String;
    FResult: Boolean;
    FMsgErrore: String;
    FCodErrore: Integer;
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
    procedure TimerTimer(Sender: TObject);
    procedure EditChange(Sender: TObject);
    procedure EditPasswordChange(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure ButtonAnnullaClick(Sender: TObject);
  end;

function ValutazionePassword(const APwd: String): Integer;
var
  N: Integer;
begin
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

function ChiamataAutentica(const Metodo: String; const Parametri: TJSONObject;
                           var JSONResponse: TJSONObject; var AToken,AMsgErrore: String; var ACodErrore: Integer): Boolean;
var
  AutenticaBaseURL: String;
  prvRestClient: TRESTClient;
  prvRestRequest: TRESTRequest;
  prvRestResponse: TRESTResponse;
  FreeJSONResponse: Boolean;
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
        HandleRedirects:=False;
      end;
      with prvRESTRequest do begin
        Client:=prvRESTClient;
        Method:=rmPOST;
        Resource:=Metodo;
        Params.Clear;
        AddParameter('body',Parametri,False);
        Params.ParameterByName('body').ContentType:=ctAPPLICATION_JSON;
        Params.ParameterByName('body').Kind:=pkREQUESTBODY;
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
          if (Metodo='Autenticazione') or (Metodo='RefreshToken') then
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

procedure TFormAutenticazione.ButtonAnnullaClick(Sender: TObject);
begin
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  Close;
end;

procedure TFormAutenticazione.ButtonConfermaClick(Sender: TObject);
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
      JSONRequest.AddPair('improntaPwd',THashSHA2.GetHashString(EditPassword.Text));
      if Length(FNonce)>0 then
        JSONRequest.AddPair('nonce',FNonce);
      FResult:=ChiamataAutentica('Autenticazione',JSONRequest,JSONResponse,FToken,FMsgErrore,FCodErrore);
      if (FCodErrore=305) or
         (FCodErrore=310) or
         (FCodErrore=311) then begin // Credenziali errate
        if FTentativi>=2 then begin
          Close;
          Exit;
        end;
        MessageBox(Handle,
                   PChar(MsgCredenzialiErrate),
                   PChar(Caption),
                   mb_IconError);
        Inc(FTentativi);
        EditPassword.SetFocus;
        Exit;
      end;
      if JSONResponse.Parse(BytesOf(TNetEncoding.Base64.Decode(ExtractWord(2,FToken,'.'))),0)>0 then
        FIDUser:=JSONResponse.GetValue<String>('ID_USER');
      if (FCodErrore=312) or
         (FCodErrore=313) then begin //Pwd scaduta
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

procedure TFormAutenticazione.EditChange(Sender: TObject);
begin
  Timer.Enabled:=False;
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

procedure TFormAutenticazione.FormAutenticazioneShow(Sender: TObject);
begin
  if Length(Trim(EditUserName.Text))>0 then begin
    if EditOldPassword.Visible then
      EditOldPassword.SetFocus
    else
      EditPassword.SetFocus;
  end;
end;

procedure TFormAutenticazione.FormCreate(Sender: TObject);
begin
  Name:='FormAutenticazione';
  BorderStyle:=bsDialog;
  Height:=200;
  Width:=500;
  Position:=poOwnerFormCenter;
  Caption:='Autentica GI';
  OnShow:=FormAutenticazioneShow;

  LabelMsg:=TLabel.Create(Self);
  LabelMsg.Name:='LabelMsg';
  LabelMsg.Parent:=Self;
  LabelMsg.AutoSize:=False;
  LabelMsg.Alignment:=taCenter;
  LabelMsg.Top:=10;
  LabelMsg.Left:=0;
  LabelMsg.Width:=500;
  LabelMsg.WordWrap:=False;
  LabelMsg.Caption:=LblInitialMessage;

  LabelUserName:=TLabel.Create(Self);
  LabelUserName.Name:='LabelUserName';
  LabelUserName.Parent:=Self;
  LabelUserName.Left:=30;
  LabelUserName.Top:=37;
  LabelUserName.Width:=67;
  LabelUserName.Height:=13;
  LabelUserName.Caption:=LblUserName;
  LabelUserName.FocusControl:=EditUserName;

  LabelPassword:=TLabel.Create(Self);
  LabelPassword.Name:='LabelPassword';
  LabelPassword.Parent:=Self;
  LabelPassword.Left:=30;
  LabelPassword.Top:=64;
  LabelPassword.Width:=50;
  LabelPassword.Height:=13;
  LabelPassword.Caption:=LblPassword;
  LabelPassword.FocusControl:=EditPassword;

  LabelPassword2:=TLabel.Create(Self);
  LabelPassword2.Name:='LabelPassword2';
  LabelPassword2.Parent:=Self;
  LabelPassword2.Left:=30;
  LabelPassword2.Top:=91;
  LabelPassword2.Width:=50;
  LabelPassword2.Height:=13;
  LabelPassword2.Caption:=LblPasswordAgain;
  LabelPassword2.FocusControl:=EditPassword;
  LabelPassword2.Visible:=False;

  LabelPasswordDimenticata:=TLabel.Create(Self);
  LabelPasswordDimenticata.Name:='LabelPasswordDimenticata';
  LabelPasswordDimenticata.Parent:=Self;
  LabelPasswordDimenticata.Left:=110;
  LabelPasswordDimenticata.Top:=91;
  LabelPasswordDimenticata.Width:=140;
  LabelPasswordDimenticata.Height:=13;
  LabelPasswordDimenticata.Caption:=LblForgottenPassword;

  EditUserName:=TEdit.Create(Self);
  EditUserName.Name:='EditUserName';
  EditUserName.Text:='';
  EditUserName.Parent:=Self;
  EditUserName.Left:=150;
  EditUserName.Top:=34;
  EditUserName.Width:=241;
  EditUserName.Height:=21;
  EditUserName.TabOrder:=0;
  EditUserName.OnChange:=EditChange;

  LabelOldPassword:=TLabel.Create(Self);
  LabelOldPassword.Name:='LabelOldPassword';
  LabelOldPassword.Parent:=Self;
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
  EditOldPassword.Parent:=Self;
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
  EditPassword.Parent:=Self;
  EditPassword.Left:=150;
  EditPassword.Top:=61;
  EditPassword.Width:=241;
  EditPassword.Height:=21;
  EditPassword.TabOrder:=2;
  EditPassword.PasswordChar:='*';
  EditPassword.OnChange:=EditChange;

  ImageQualityIndicator:=TImage.Create(Self);
  ImageQualityIndicator.Name:='ImageQualityIndicator';
  ImageQualityIndicator.Parent:=Self;
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
  EditPassword2.Parent:=Self;
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
  LabelQui.Parent:=Self;
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
  ButtonConferma.Parent:=Self;
  ButtonConferma.Left:=100;
  ButtonConferma.Top:=128;
  ButtonConferma.Width:=75;
  ButtonConferma.Height:=25;
  ButtonConferma.Caption:=BtnConfirm;
  ButtonConferma.Default:=True;
  ButtonConferma.TabOrder:=4;
  ButtonConferma.OnClick:=ButtonConfermaClick;

  ButtonAnnulla:=TButton.Create(Self);
  ButtonAnnulla.Name:='ButtonAnnulla';
  ButtonAnnulla.Parent:=Self;
  ButtonAnnulla.Left:=250;
  ButtonAnnulla.Top:=128;
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

  FResult:=False;
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  FTentativi:=0;
end;

function Autenticazione(const ApiKey,Nonce,Title: String;
                        var IdUser,Token,MsgErrore: String; var CodErrore: Integer): Boolean;
var
  FormAutenticazione: TFormAutenticazione;
begin
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
    FormAutenticazione.LabelPassword.Top:=91;
    FormAutenticazione.LabelPassword.Caption:=LblNewPassword;
    FormAutenticazione.LabelPassword2.Visible:=True;
    FormAutenticazione.LabelPassword2.Top:=118;
    FormAutenticazione.EditPassword2.Visible:=True;
    FormAutenticazione.LabelPasswordDimenticata.Visible:=False;
    FormAutenticazione.LabelQui.Visible:=False;
    FormAutenticazione.ButtonConferma.Top:=155;
    FormAutenticazione.ButtonConferma.Caption:=BtnCaptionModPassword;
    FormAutenticazione.ButtonConferma.Width:=100;
    FormAutenticazione.ButtonConferma.OnClick:=FormAutenticazione.ButtonModificaPassword2Click;
    FormAutenticazione.ButtonAnnulla.Top:=155;
    FormAutenticazione.EditOldPassword.Visible:=True;
    FormAutenticazione.EditPassword.Top:=88;
    FormAutenticazione.EditPassword.Text:='';
    FormAutenticazione.EditPassword.OnChange:=FormAutenticazione.EditPasswordChange;
    FormAutenticazione.EditPassword2.Top:=115;
    FormAutenticazione.EditPassword2.Text:='';
    FormAutenticazione.ImageQualityIndicator.Top:=84;
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

procedure TFormAutenticazione.TimerTimer(Sender: TObject);
begin
  Timer.Enabled:=False;
  FResult:=False;
  FMsgErrore:=MsgTimeout;
  FCodErrore:=AutErrTimeout;
  Close;
end;

{ TFormCreaUtente }

procedure TFormCreaUtente.ButtonAnnullaClick(Sender: TObject);
begin
  FMsgErrore:=MsgNoCredentials;
  FCodErrore:=AutErrNoCredentials;
  Close;
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

procedure TFormCreaUtente.FormCreate(Sender: TObject);
begin
  Name:='FormCreaUtente';
  BorderStyle:=bsDialog;
  Height:=250;
  Width:=500;
  Position:=poOwnerFormCenter;
  Caption:='Autenticazione Sicura';

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
  LabelMsg.Parent:=Self;
  LabelMsg.Left:=0;
  LabelMsg.Top:=10;
  LabelMsg.Width:=476;
  LabelMsg.Height:=13;
  LabelMsg.Alignment:=taCenter;
  LabelMsg.Anchors:=[akLeft, akTop, akRight];
  LabelMsg.AutoSize:=False;
  LabelMsg.Caption:=LblInitialCreateUser;

  LabelUserName.Name:='LabelUserName';
  LabelUserName.Parent:=Self;
  LabelUserName.Left:=30;
  LabelUserName.Top:=37;
  LabelUserName.Width:=67;
  LabelUserName.Height:=13;
  LabelUserName.Caption:=LblUserName;
  LabelUserName.FocusControl:=EditUserName;

  LabelEmail.Name:='LabelEmail';
  LabelEmail.Parent:=Self;
  LabelEmail.Left:=30;
  LabelEmail.Top:=64;
  LabelEmail.Width:=71;
  LabelEmail.Height:=13;
  LabelEmail.Caption:=LblEmailAddress;
  LabelEmail.FocusControl:=EditEmail;

  LabelPassword.Name:='LabelPassword';
  LabelPassword.Parent:=Self;
  LabelPassword.Left:=30;
  LabelPassword.Top:=101;
  LabelPassword.Width:=50;
  LabelPassword.Height:=13;
  LabelPassword.Caption:=LblPassword;
  LabelPassword.FocusControl:=EditPassword;

  LabelPassword2.Name:='LabelPassword2';
  LabelPassword2.Parent:=Self;
  LabelPassword2.Left:=30;
  LabelPassword2.Top:=128;
  LabelPassword2.Width:=80;
  LabelPassword2.Height:=13;
  LabelPassword2.Caption:=LblPasswordAgain;
  LabelPassword2.FocusControl:=EditPassword2;

  EditUserName.Name:='EditUserName';
  EditUserName.Parent:=Self;
  EditUserName.Left:=150;
  EditUserName.Top:=34;
  EditUserName.Width:=241;
  EditUserName.Height:=21;
  EditUserName.TabOrder:=0;
  EditUserName.Text:='';
  EditUserName.OnChange:=EditChange;

  EditEmail.Name:='EditEmail';
  EditEmail.Parent:=Self;
  EditEmail.Left:=150;
  EditEmail.Top:=61;
  EditEmail.Width:=241;
  EditEmail.Height:=21;
  EditEmail.TabOrder:=1;
  EditEmail.Text:='';
  EditEmail.OnChange:=EditChange;

  EditPassword.Name:='EditPassword';
  EditPassword.Parent:=Self;
  EditPassword.Left:=150;
  EditPassword.Top:=98;
  EditPassword.Width:=241;
  EditPassword.Height:=21;
  EditPassword.PasswordChar:='*';
  EditPassword.TabOrder:=2;
  EditPassword.Text:='';
  EditPassword.OnChange:=EditPasswordChange;

  ImageQualityIndicator.Name:='ImageQualityIndicator';
  ImageQualityIndicator.Parent:=Self;
  ImageQualityIndicator.Left:=414;
  ImageQualityIndicator.Top:=94;
  ImageQualityIndicator.Width:=30;
  ImageQualityIndicator.Height:=30;
  ImageQualityIndicator.Transparent:=True;
  ImageQualityIndicator.Hint:='';
  ImageQualityIndicator.ShowHint:=True;

  EditPassword2.Name:='EditPassword2';
  EditPassword2.Parent:=Self;
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
  ButtonConferma.Parent:=Self;
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
  ButtonAnnulla.Parent:=Self;
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

end.
