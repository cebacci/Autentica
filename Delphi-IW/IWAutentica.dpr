program IWAutentica;

uses
  FastMM4,
  IWRtlFix,
  IWStart,
  SysUtils,
  Inifiles,
  ServerController in 'ServerController.pas' {IWServerController: TIWServerControllerBase},
  UserSessionUnit in 'UserSessionUnit.pas' {IWUserSession: TIWUserSessionBase},
  frmLogon in 'frmLogon.pas' {IWFormLogon: TIWAppForm},
  frmPasswordless in 'frmPasswordless.pas' {IWFormPasswordless: TIWAppForm};

{$R *.res}

begin
  with TIniFile.Create(ExtractFilePath(ParamStr(0))+'setup.ini') do begin
    try
      TIWStart.Execute(ReadBool('Setup','StandAlone',false));
    finally
      Free;
    end;
  end;
end.
