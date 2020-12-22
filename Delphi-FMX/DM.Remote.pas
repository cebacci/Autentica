unit DM.Remote;

interface

uses
  System.SysUtils, System.Classes, JSon, IdBaseComponent, IdCoder, IdCoder3to4,
  Rest.Types, IdCoderMIME, Generics.Collections, Event.Classes;

type
  TDMRemote = class(TDataModule)
    IdDecoderMIME: TIdDecoderMIME;
  private
    FToken: String;
    FSuccess: Boolean;
    FErrorCode: Integer;
    FErrorMessage: String;
    FIDUser: String;
    { Private declarations }
  public
    { Public declarations }
    AutenticaBaseURL: String;
    function GetSettingFilename: String;
    property Token: String read FToken write FToken;
    procedure AssegnaTokenAMemo(const AStringList: TStrings);
    function ChiamataAutentica(const HTTPMethod: TRESTRequestMethod; const EndPoint: String;
                               const Parametri: TJSONObject;
                               var JSONResponse: TJSONObject; var AToken,AMsgErrore: String;
                               var ACodErrore: Integer): Boolean;
    procedure Autenticazione;
    procedure ModificaPassword;
    procedure PasswordDimenticata;
    procedure NuovoUtente;
    procedure CreaUtente;
    procedure QRCodeApp;
    procedure QRCodeApiKey;
    procedure AutenticazioneBio;
    procedure AnnullaAutenticazioneBio;
    constructor Create(AOwner: TComponent); override;
    //FMXER
    procedure AttemptLogin(const AOnSuccess: TProc = nil; const AOnError: TProc = nil);
    property Success: Boolean read FSuccess write FSuccess;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
    property IDUser: String read FIDUser write FIDUser;
  end;

var
  DMRemote: TDMRemote;

const
  AutErrUnexcpectedOnCallAutentica=7;

implementation

{$R *.dfm}

uses Rest.Client, System.IniFiles, System.IOUtils, System.Hash, EventBus, DM.Main,
  FMX.Graphics;

{ TDMRemoteCalls }

procedure TDMRemote.AnnullaAutenticazioneBio;
var
  Parametri,Risposta: TJSONObject;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('idDispositvo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    ChiamataAutentica(rmPOST,'AnnullaAutenticazioneBio',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
end;

procedure TDMRemote.AssegnaTokenAMemo(const AStringList: TStrings);
var
  lToken: String;
begin
  lToken:=FToken;
  AStringList.Clear;
  while Length(lToken)>0 do begin
    AStringList.Add(Copy(lToken,1,37));
    lToken:=Copy(lToken,38,MaxInt);
  end;
end;

procedure TDMRemote.AttemptLogin(const AOnSuccess, AOnError: TProc);
var
  Parametri,Risposta: TJSONObject;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('improntaPwd',DMMain.Password);
  Parametri.AddPair('nonce',DMMain.Nonce);
  Parametri.AddPair('idDispositvo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    FSuccess:=ChiamataAutentica(rmPOST,'autenticazione',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    FErrorMessage:=ErrorMessage;
    FErrorCode:=ErrorCode;
    Risposta.TryGetValue<String>('token',FToken);
    Risposta.TryGetValue<String>('ID_USER',FIDUser);
    if FIDUser.Trim.IsEmpty then
      Risposta.TryGetValue<String>('sub',FIDUser);
    if FSuccess then begin
      if Assigned(AOnSuccess) then
        AOnSuccess();
    end
    else begin
      if Assigned(AOnError) then
        AOnError();
    end;
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
end;

procedure TDMRemote.Autenticazione;
var
  Event: TOnAfterAutenticazione;
  Parametri,Risposta: TJSONObject;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterAutenticazione.Create;
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('improntaPwd',DMMain.Password);
  Parametri.AddPair('nonce',DMMain.Nonce);
  Parametri.AddPair('idDispositivo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmPOST,'autenticazione',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    Event.ErrorMessage:=ErrorMessage;
    Event.ErrorCode:=ErrorCode;
    Risposta.TryGetValue<String>('token',FToken);
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

procedure TDMRemote.AutenticazioneBio;
var
  Event: TOnAfterAutenticazione;
  Parametri,Risposta: TJSONObject;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterAutenticazione.Create;
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('nonce',DMMain.Nonce);
  Parametri.AddPair('idDispositivo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmPOST,'AutenticazioneBio',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    Event.ErrorMessage:=ErrorMessage;
    Event.ErrorCode:=ErrorCode;
    Risposta.TryGetValue<String>('token',FToken);
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

function TDMRemote.ChiamataAutentica(const HTTPMethod: TRESTRequestMethod; const EndPoint: String; const Parametri: TJSONObject;
                                     var JSONResponse: TJSONObject; var AToken,AMsgErrore: String; var ACodErrore: Integer): Boolean;
var
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
    {$IFDEF ANDROID}
    Result:='Android device';
    {$ENDIF}
    {$IFDEF IOS}
    Result:='iOS device';
    {$ENDIF}
  end;
begin
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
        AddParameter('User-Agent','Autenticazione FMX/2020.11.30/'+TOSVersion.Name, TRESTRequestParameterKind.pkHTTPHEADER);
        AddParameter('Origin',TOSVersion.ToString, TRESTRequestParameterKind.pkHTTPHEADER);
        HandleRedirects:=False;
      end;
      with prvRESTRequest do begin
        Client:=prvRESTClient;
        Method:=HTTPMethod;
        Resource:=EndPoint;
        if EndPoint='AutenticazioneBio' then
          Timeout:=62000;
        Params.Clear;
        if Assigned(Parametri) then begin
          Parametri.AddPair('idDispositivo',GetDispositivo);
          AddParameter('body',Parametri,False);
          Params.ParameterByName('body').ContentType:=ctAPPLICATION_JSON;
          Params.ParameterByName('body').Kind:=pkREQUESTBODY;
        end;
        Response:=prvRESTResponse;
        SynchronizedEvents:=False;
        URLAlreadyEncoded:=True;
      end;
      try
        prvRestRequest.Execute;
        if JSONResponse.Parse(BytesOf(prvRestResponse.Content),0)=0 then begin
          AMsgErrore:='Autentica - Method "'+EndPoint+'": Empty JSONResponse';
          ACodErrore:=1;
          Result:=False;
          Exit;
        end;
        if prvRestResponse.StatusCode<>200 then begin
          Result:=False;
          AMsgErrore:=JSONResponse.GetValue<String>('description');
          ACodErrore:=JSONResponse.GetValue<Integer>('error');
        end
        else begin
          if (EndPoint='Autenticazione') or (EndPoint='AutenticazioneBio') or (EndPoint='RefreshToken') then
            AToken:=JSONResponse.GetValue<String>('token');
          ACodErrore:=0;
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
      AMsgErrore:='Autentica - Metodo "'+EndPoint+'": '+E.Message;
      ACodErrore:=AutErrUnexcpectedOnCallAutentica;
      Result:=False;
    end;
  end;
end;

constructor TDMRemote.Create(AOwner: TComponent);
begin
  inherited;
  with TIniFile.Create(GetSettingFilename) do begin
    try
      AutenticaBaseURL:=ReadString('Setup','AutenticaBaseURL','https://ws-a.geninfo.it/rest/api');
    finally
      Free;
    end;
  end;
end;

procedure TDMRemote.CreaUtente;
var
  Event: TOnAfterCreaUtente;
  Parametri,Risposta: TJSONObject;
  aMessage,ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterCreaUtente.Create;
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('idUser',DMMain.IDUser);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('improntaPwd',DMMain.Password);
  Parametri.AddPair('idDispositvo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmPOST,'CreaUtente',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    Risposta.TryGetValue<String>('message',aMessage);
    Event.Message:=aMessage;
    Event.ErrorMessage:=ErrorMessage;
    Event.ErrorCode:=ErrorCode;
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

function TDMRemote.GetSettingFilename: String;
var
  FileName: String;
begin
  FileName:=ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  Result:=IncludeTrailingPathDelimiter(
{$IFDEF IOS}
    TPath.GetDocumentsPath
{$ELSE}
    TPath.GetHomePath
{$ENDIF}
    ) + FileName + '_Setup.ini';
end;

procedure TDMRemote.ModificaPassword;
var
  Event: TOnAfterModificaPassword;
  Parametri,Risposta: TJSONObject;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterModificaPassword.Create;
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userName',DMMain.UserName);
  Parametri.AddPair('improntaVecchiaPwd',DMMain.Password);
  Parametri.AddPair('improntaNuovaPwd',DMMain.NuovaPassword);
  Parametri.AddPair('idDispositvo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmPOST,'ModificaPassword',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    Event.ErrorMessage:=ErrorMessage;
    Event.ErrorCode:=ErrorCode;
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

procedure TDMRemote.NuovoUtente;
begin
  //Richiedi al tuo server un ID per il nuovo utente. Nel nostro esempio, DMMain genera un IdUser casuale
  Sleep(1000);
  GlobalEventBus.Post(TOnAfterNuovoUtente.Create(True,DMMain.IdUser));
end;

procedure TDMRemote.PasswordDimenticata;
var
  Event: TOnAfterPasswordDimenticata;
  Parametri,Risposta: TJSONObject;
  aMessage,ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterPasswordDimenticata.Create;
  Parametri:=TJSONObject.Create;
  Parametri.AddPair('apiKey',DMMain.ApiKey);
  Parametri.AddPair('userMail',DMMain.UserName);
  Parametri.AddPair('idDispositvo',DMMain.IdDispositivo);
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmPOST,'PasswordDimenticata',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    Risposta.TryGetValue<String>('message',aMessage);
    Event.Message:=aMessage;
    Event.ErrorMessage:=ErrorMessage;
    Event.ErrorCode:=ErrorCode;
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

procedure TDMRemote.QRCodeApiKey;
var
  Event: TOnAfterQRCodeApiKey;
  Parametri,Risposta: TJSONObject;
  qrCodeEncoded,encodedLogo,Descrizione,ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterQRCodeApiKey.Create;
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmGET,'qrcode/'+DMMain.ApiKey+'/'+DMMain.UserName,nil,Risposta,FToken,ErrorMessage,ErrorCode);
    if Event.Success then begin
      Risposta.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      Event.BitmapApiKey:=qrCodeEncoded;
    end;
  finally
    Risposta.DisposeOf;
  end;
  Risposta:=TJSONObject.Create;
  Parametri:=TJSONObject.Create;
  try
    Parametri.AddPair('apiKey',DMMain.ApiKey);
    Event.Success:=ChiamataAutentica(rmPost,'datiProgetto',Parametri,Risposta,FToken,ErrorMessage,ErrorCode);
    if Event.Success then begin
      Risposta.TryGetValue<String>('descrizione',Descrizione);
      Event.Descrizione:=Descrizione;
      Risposta.TryGetValue<String>('encodedLogo',encodedLogo);
      Event.Logo:=encodedLogo;
    end;
  finally
    Risposta.DisposeOf;
    Parametri.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

procedure TDMRemote.QRCodeApp;
var
  Event: TOnAfterQRCodeApp;
  Risposta: TJSONObject;
  qrCodeEncoded: String;
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  Event:=TOnAfterQRCodeApp.Create;
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmGET,'qrcode/Android',nil,Risposta,FToken,ErrorMessage,ErrorCode);
    if Event.Success then begin
      Risposta.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      Event.BitmapAndroid:=qrCodeEncoded;
    end;
  finally
    Risposta.DisposeOf;
  end;
  qrCodeEncoded:='';
  Risposta:=TJSONObject.Create;
  try
    Event.Success:=ChiamataAutentica(rmGET,'qrcode/iOS',nil,Risposta,FToken,ErrorMessage,ErrorCode);
    if Event.Success then begin
      Risposta.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      Event.BitmapIos:=qrCodeEncoded;
    end;
  finally
    Risposta.DisposeOf;
  end;
  GlobalEventBus.Post(Event);
end;

end.
