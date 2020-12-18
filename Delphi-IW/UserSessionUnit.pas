unit UserSessionUnit;

{
  This is a DataModule where you can add components or declare fields that are specific to
  ONE user. Instead of creating global variables, it is better to use this datamodule. You can then
  access the it using UserSession.
}
interface

uses
  IWUserSessionBase, SysUtils, Classes, frmLogon, frmPasswordless,
    Rest.Types, System.JSON, IdBaseComponent, IdCoder, IdCoder3to4, IdCoderMIME,
    IWCompLabel, IWCompExtCtrls;

type
  TIWUserSession = class(TIWUserSessionBase)
    IdDecoderMIME: TIdDecoderMIME;
    procedure IWUserSessionBaseCreate(Sender: TObject);
    procedure IWUserSessionBaseDestroy(Sender: TObject);
  private
    { Private declarations }
    AutenticaBaseURL: String;
    FResult: Boolean;
    FMsgErrore: String;
    FCodErrore: Integer;
    FToken: String;
    FApiKey: String;
    FUserName: String;
    FNonce: String;
    FExpiration: String;
    FRoles: String;
    FIdUser: String;
    FIssuedAt: String;
    FIssuer: String;
    FPassword: String;
    FBio: Boolean;
    FPrimaEsecuzione: Boolean;
    procedure SetApiKey(const Value: String);
    procedure SetIdUser(const Value: String);
    procedure SetIssuer(const Value: String);
    procedure SetNonce(const Value: String);
    procedure SetRoles(const Value: String);
    function GetExpiration: TDateTime;
    function GetIssuedAt: TDateTime;
    procedure ZoomQRCode(const AStream: TMemoryStream; const DestImage: TIWImage);
    procedure SetUserName(const Value: String);
    procedure SetPassword(const Value: String);
    procedure SetBio(const Value: Boolean);
  public
    { Public declarations }
    FormLogon: TIWFormLogon;
    FormPasswordless: TIWFormPasswordless;
    property PrimaEsecuzione: Boolean read FPrimaEsecuzione;
    property ApiKey: String read FApiKey write SetApiKey;
    property UserName: String read FUserName write SetUserName;
    property Password: String read FPassword write SetPassword;
    property Bio: Boolean read FBio write SetBio;
    property Token: String read FToken write FToken;
    property IdUser: String read FIdUser write SetIdUser;
    property Issuer: String read FIssuer write SetIssuer;
    property Roles: String read FRoles write SetRoles;
    property Nonce: String read FNonce write SetNonce;
    property IssuedAt: TDateTime read GetIssuedAt;
    property Expiration: TDateTime read GetExpiration;
    function ChiamataAutentica(const HTTPMethod: TRESTRequestMethod; const EndPoint: String;
                               const Parametri: TJSONObject;
                               var JSONResponse: TJSONObject; var AMsgErrore: String;
                               var ACodErrore: Integer): Boolean;
    function Autenticazione(out ErrorMessage: String;
                            out ErrorCode: Integer): Boolean;
    function AnnullaAutenticazioneBio(out ErrorMessage: String;
                                      out ErrorCode: Integer): Boolean;
    procedure DatiProgetto(const AIWImage: TIWImage; const AIWLabel: TIWLabel);
    procedure QRCodeAndroid(const AIWImage: TIWImage);
    procedure QRCodeApikeyUsername(const AIWImage: TIWImage);
    procedure QRCodeIos(const AIWImage: TIWImage);
  end;

const
  AutErrUnexcpectedOnCallAutentica=7;

implementation

uses Rest.Client, System.IniFiles, System.DateUtils, System.Hash, Vcl.Graphics, Winapi.Windows, Vcl.Imaging.pngimage;

{$R *.dfm}

function TIWUserSession.AnnullaAutenticazioneBio(out ErrorMessage: String;
  out ErrorCode: Integer): Boolean;
var
  Parametri,Risposta: TJSONObject;
begin
  Bio:=False;
  Parametri:=TJSONObject.Create;
  Risposta:=TJSONObject.Create;
  try
    Parametri.AddPair('apiKey',FApiKey);
    Parametri.AddPair('userName',FUserName);
    Result:=ChiamataAutentica(rmPOST,'AnnullaAutenticazioneBio',Parametri,Risposta,ErrorMessage,ErrorCode);
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
end;

function TIWUserSession.Autenticazione(out ErrorMessage: String;
                                       out ErrorCode: Integer): Boolean;
var
  EndPoint: String;
  Parametri,Risposta: TJSONObject;
  function GetNonce: String;
  var
    aGUID: TGUID;
  begin
    CreateGUID(aGUID);
    Result:=GUIDToString(aGUID);
    Result:=Copy(Result,2,Length(Result)-2);
  end;
begin
  Parametri:=TJSONObject.Create;
  Risposta:=TJSONObject.Create;
  try
    Parametri.AddPair('apiKey',FApiKey);
    Parametri.AddPair('userName',FUserName);
    if Bio then
      EndPoint:='autenticazioneBio'
    else begin
      EndPoint:='autenticazione';
      Parametri.AddPair('improntaPwd',FPassword);
    end;
    Parametri.AddPair('nonce',GetNonce);
    Parametri.AddPair('User-Agent',WebApplication.Request.UserAgent);
    Result:=ChiamataAutentica(rmPOST,EndPoint,Parametri,Risposta,ErrorMessage,ErrorCode);
    {
     Struttura della risposta
     "message":"Autenticazione effettuata con successo",
     "token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzUxMiJ9.XXX.XXX",
     "ID_USER":"XXX",
     "Issuer":"Autentica",
     "ROLES":"ADMIN",
     "NONCE":"XXX",
     "IssuedAt":"2020-12-16T14:30:09.000Z",
     "Expiration":"2020-12-17T13:30:09.000Z",
     "JWTId":"6CF9B203-2AE5-4545-B913-63CE777B3A28",
     "Claims":{"iss":"Autentica","ID_USER":"XXX","ROLES":"ADMIN","NONCE":"XXX","iat":1608125409,"exp":1608208209,"jti":"6CF9B203-2AE5-4545-B913-63CE777B3A28"}

    if Result then begin
      Risposta.TryGetValue<String>('token',FToken);
      Risposta.TryGetValue<String>('NONCE',FNonce);
      Risposta.TryGetValue<String>('Expiration',FExpiration);
      Risposta.TryGetValue<String>('ROLES',FRoles);
      Risposta.TryGetValue<String>('ID_USER',FIdUser);
      Risposta.TryGetValue<String>('IssuedAt',FIssuedAt);
      Risposta.TryGetValue<String>('Issuer',FIssuer);
    end;
  finally
    Parametri.DisposeOf;
    Risposta.DisposeOf;
  end;
end;

procedure TIWUserSession.QRCodeAndroid(const AIWImage: TIWImage);
var
  JSONResponse: TJSONObject;
  qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica(TRESTRequestMethod.rmGET,'qrcode/Android',nil,JSONResponse,FMsgErrore,FCodErrore);
    if FResult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,AIWImage);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

procedure TIWUserSession.QRCodeApikeyUsername(const AIWImage: TIWImage);
var
  JSONResponse: TJSONObject;
  qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica(TRESTRequestMethod.rmGET,'qrcode/'+FApiKey+'/'+FUserName,nil,JSONResponse,FMsgErrore,FCodErrore);
    if Fresult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,AIWImage);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

procedure TIWUserSession.QRCodeIos(const AIWImage: TIWImage);
var
  JSONResponse: TJSONObject;
  qrCodeEncoded: String;
  aStream: TMemoryStream;
begin
  JSONResponse:=TJSONObject.Create;
  try
    FResult:=ChiamataAutentica(TRESTRequestMethod.rmGET,'qrcode/iOS',nil,JSONResponse,FMsgErrore,FCodErrore);
    if Fresult then begin
      JSONResponse.TryGetValue<String>('qrCodeEncoded',qrCodeEncoded);
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(qrCodeEncoded,aStream);
        AStream.Seek(0,soBeginning);
        ZoomQRCode(aStream,AIWImage);
      finally
        aStream.Free;
      end;
    end;
  finally
    JSONResponse.Free;
  end;
end;

function TIWUserSession.ChiamataAutentica(const HTTPMethod: TRESTRequestMethod;
  const EndPoint: String; const Parametri: TJSONObject;
  var JSONResponse: TJSONObject; var AMsgErrore: String;
  var ACodErrore: Integer): Boolean;
var
  prvRestClient: TRESTClient;
  prvRestRequest: TRESTRequest;
  prvRestResponse: TRESTResponse;
  FreeJSONResponse: Boolean;
  lUserAgent: String;
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
        if Assigned(Parametri) then begin
          if Parametri.TryGetValue<String>('User-Agent',lUserAgent) then begin
            AddParameter('User-Agent',lUserAgent,TRESTRequestParameterKind.pkHTTPHEADER);
            AddParameter('Origin',lUserAgent,TRESTRequestParameterKind.pkHTTPHEADER);
          end;
        end;
        HandleRedirects:=False;
      end;
      with prvRESTRequest do begin
        Client:=prvRESTClient;
        Method:=HTTPMethod;
        Resource:=EndPoint;
        if EndPoint.ToLower='autenticazionebio' then
          Timeout:=62000;
        Params.Clear;
        if Assigned(Parametri) then begin
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

procedure ZoomImage(const AStream: TMemoryStream; const DestImage: TIWImage);
var
  PngImage: TPngImage;
  SourceBitmap,TempBitmap: Vcl.Graphics.TBitmap;
begin
  PngImage:=TPngImage.Create;
  SourceBitmap:=Vcl.Graphics.TBitmap.Create;
  TempBitmap:=Vcl.Graphics.TBitmap.Create;
  try
    PngImage.LoadFromStream(aStream);
    SourceBitmap.Width:=PngImage.Width;
    SourceBitmap.Height:=PngImage.Height;
    SourceBitmap.Assign(PngImage);
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
    PngImage.Free;
    SourceBitmap.Free;
    TempBitmap.Free;
  end;
end;

procedure TIWUserSession.DatiProgetto(const AIWImage: TIWImage; const AIWLabel: TIWLabel);
var
  Parametri,JSONResponse: TJSONObject;
  lEncodedLogo,lDescrizione: String;
  aStream: TMemoryStream;
begin
  Parametri:=TJSONObject.Create;
  JSONResponse:=TJSONObject.Create;
  try
    Parametri.AddPair('apiKey',FApiKey);
    FResult:=ChiamataAutentica(TRESTRequestMethod.rmPOST,'datiProgetto',Parametri,JSONResponse,FMsgErrore,FCodErrore);
    if FResult then begin
      JSONResponse.TryGetValue<String>('encodedLogo',lEncodedLogo);
      JSONResponse.TryGetValue<String>('descrizione',lDescrizione);
      AIWLabel.Text:=lDescrizione;
      aStream:=TMemoryStream.Create;
      try
        TIdDecoderMIME.DecodeStream(lEncodedLogo,aStream);
        AStream.Seek(0,soBeginning);
        ZoomImage(aStream,AIWImage);
      finally
        aStream.Free;
      end;
    end;
  finally
    Parametri.Free;
    JSONResponse.Free;
  end;
end;

function TIWUserSession.GetExpiration: TDateTime;
begin
  Result:=ISO8601ToDate(FExpiration,True);
end;

function TIWUserSession.GetIssuedAt: TDateTime;
begin
  Result:=ISO8601ToDate(FIssuedAt,True);
end;

procedure TIWUserSession.IWUserSessionBaseCreate(Sender: TObject);
begin
  FormLogon:=TIWFormLogon.Create(WebApplication);
  FormPasswordless:=TIWFormPasswordless.Create(WebApplication);
  with TIniFile.Create(ExtractFilePath(ParamStr(0))+'Setup.ini') do begin
    try
      AutenticaBaseURL:=ReadString('Setup','AutenticaBaseURL','https://ws-a.geninfo.it/rest/api');
    finally
      Free;
    end;
  end;
  FPrimaEsecuzione:=True;
  FApiKey:='XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';  //Personalizza con la tua API-KEY
end;

procedure TIWUserSession.IWUserSessionBaseDestroy(Sender: TObject);
begin
  FormLogon.Free;
  FormPasswordless.Free;
end;

procedure TIWUserSession.SetApiKey(const Value: String);
begin
  FApiKey := Value;
end;

procedure TIWUserSession.SetBio(const Value: Boolean);
begin
  FBio := Value;
  if Value then begin
    WebApplication.Response.Cookies.AddCookie('Bio','True','/',Now+30);
  end
  else begin
    WebApplication.Response.Cookies.AddCookie('Bio','False','/',Now+30);
  end;
  FPrimaEsecuzione:=False;
end;

procedure TIWUserSession.SetIdUser(const Value: String);
begin
  FIdUser := Value;
end;

procedure TIWUserSession.SetIssuer(const Value: String);
begin
  FIssuer := Value;
end;

procedure TIWUserSession.SetNonce(const Value: String);
begin
  FNonce := Value;
end;

procedure TIWUserSession.SetPassword(const Value: String);
begin
  FPassword := THashSHA2.GetHashString(Value);
end;

procedure TIWUserSession.SetRoles(const Value: String);
begin
  FRoles := Value;
end;

procedure TIWUserSession.SetUserName(const Value: String);
begin
  FUserName:=Value;
  WebApplication.Response.Cookies.AddCookie('UserName',FUserName,'/',Now+30);
end;

procedure TIWUserSession.ZoomQRCode(const AStream: TMemoryStream;
  const DestImage: TIWImage);
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

end.
