unit DM.Main;

interface

uses
  System.SysUtils, System.Classes;

type
  TDMMain = class(TDataModule)
  private
    FApiKey: String;
    FUserName: String;
    FPassword: String;
    FNuovaPassword: String;
    FNonce: String;
    FBio: Boolean;
    FTentativi: Integer;
    FIdUser: String;
    procedure SetApiKey(const Value: String);
    procedure SetUserName(const Value: String);
    procedure SetBio(const Value: Boolean);
    function GetPassword: String;
    function GetNuovaPassword: String;
    function GetNonce: String;
    function GetIdDispositivo: String;
    function GetIdUser: String;
    procedure SetTentativi(const Value: Integer);
  public
    function ValutazionePassword(const APwd: String): Integer;
    procedure SalvaConfigurazione(const SalvaEdEsci: Boolean=False);
    procedure InizializzaSessione;
    procedure AggiornaPassword;
    property ApiKey: String read FApiKey write SetApiKey;
    property UserName: String read FUserName write SetUserName;
    property Password: String read GetPassword write FPassword;
    property NuovaPassword: String read GetNuovaPassword write FNuovaPassword;
    property Bio: Boolean read FBio write SetBio;
    property Nonce: String read GetNonce write FNonce;
    property IdDispositivo: String read GetIdDispositivo;
    property IdUser: String read GetIdUser write FIdUser;
    property Tentativi: Integer read FTentativi write SetTentativi;
  end;

var
  DMMain: TDMMain;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  Registry, Windows, System.IOUtils, EventBus, Event.Classes, System.Hash;

function TDMMain.ValutazionePassword(const APwd: String): Integer;
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
    if Pos(Copy(APwd,N,1),'\|!"£$%&/()=''?ì^[]{}ç@#°§<>,;.:-_àèéìò')>0 then begin
      Inc(Result);
      Break;
    end;
  end;
end;

procedure TDMMain.AggiornaPassword;
begin
  FPassword:=FNuovaPassword;
  FNuovaPassword:='';
end;

function TDMMain.GetIdDispositivo: String;
var
  dwLength: dword;
begin
  dwLength:=253;
  SetLength(Result,dwLength+1);
  if not Windows.GetComputerName(PChar(Result),dwLength) then
    Result:='unknown'
  else
    Result:=PChar(Result);
end;

function TDMMain.GetIdUser: String;
  function StringaCasualeDiNumeri: String;
  var
    N: Integer;
  begin
    Result:='';
    for N:=1 to 5 do
      Result:=Result+Chr(ord('0')+Random(10));
  end;
begin
  if Length(FIdUser)=0 then
    FIdUser:=StringaCasualeDiNumeri;
  Result:=FIdUser;
end;

function TDMMain.GetNonce: String;
var
  aGUID: TGUID;
begin
  if Length(FNonce)=0 then begin
    CreateGUID(aGUID);
    Result:=GUIDToString(aGUID);
    Result:=Copy(Result,2,Length(Result)-2);
  end
  else
    Result:=FNonce;
end;

function TDMMain.GetNuovaPassword: String;
begin
  Result:=THashSHA2.GetHashString(FNuovaPassword)
end;

function TDMMain.GetPassword: String;
begin
  Result:=THashSHA2.GetHashString(FPassword)
end;

procedure TDMMain.InizializzaSessione;
begin
  with TRegistry.Create do
    try
      if OpenKeyReadOnly('Software\Generazione Informatica\Autenticazione Passwordless') then begin
        if ValueExists('ApiKey') then
          FApiKey:=ReadString('ApiKey');
        if ValueExists('Username') then
          FUserName:=ReadString('Username');
        if ValueExists('Bio') then
          FBio:=ReadBool('Bio');
        CloseKey;
      end;
    finally
      Free;
    end;
  GlobalEventBus.Post(TOnAfterInizializzaSessione.Create(ApiKey,UserName,Bio));
end;

procedure TDMMain.SalvaConfigurazione(const SalvaEdEsci: Boolean);
begin
  with TRegistry.Create do
    try
      if OpenKey('Software\Generazione Informatica\Autenticazione Passwordless',True) then begin
        WriteString('ApiKey',FApiKey);
        WriteString('Username',FUserName);
        WriteBool('Bio',FBio);
        CloseKey;
      end;
    finally
      Free;
    end;
  GlobalEventBus.Post(TOnAfterSalvaConfigurazione.Create(SalvaEdEsci));
end;

procedure TDMMain.SetApiKey(const Value: String);
begin
  FApiKey := Value;
end;

procedure TDMMain.SetBio(const Value: Boolean);
begin
  FBio := Value;
  with TRegistry.Create do
    try
      if OpenKey('Software\Generazione Informatica\Autenticazione Passwordless',True) then begin
        WriteBool('Bio',FBio);
        CloseKey;
      end;
    finally
      Free;
    end;
end;

procedure TDMMain.SetTentativi(const Value: Integer);
begin
  FTentativi := Value;
end;

procedure TDMMain.SetUserName(const Value: String);
begin
  FUserName := Value;
end;

end.
