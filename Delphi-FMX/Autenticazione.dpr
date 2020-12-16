program Autenticazione;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.Main in 'Forms.Main.pas' {FormMain},
  Frames.StandardLogin in 'Frames.StandardLogin.pas' {FrameStandardLogin: TFrame},
  Frames.LoginSenzaPassword in 'Frames.LoginSenzaPassword.pas' {FrameLoginSenzaPassword: TFrame},
  DM.Remote in 'DM.Remote.pas' {DMRemote: TDataModule},
  Event.Classes in 'Event.Classes.pas',
  Event.Collector in 'Event.Collector.pas' {DMEventCollector: TDataModule},
  DM.Main in 'DM.Main.pas' {DMMain: TDataModule},
  Frames.AutenticazioneOk in 'Frames.AutenticazioneOk.pas' {FrameAutenticazioneOk: TFrame},
  Frames.PwdScaduta in 'Frames.PwdScaduta.pas' {FramePwdScaduta: TFrame},
  Frames.Wait in 'Frames.Wait.pas' {FrameWait: TFrame},
  Frames.DownloadApp in 'Frames.DownloadApp.pas' {FrameDownloadApp: TFrame},
  Frames.RegistraApiKey in 'Frames.RegistraApiKey.pas' {FrameRegistraApiKey: TFrame},
  Frames.NuovoUtente in 'Frames.NuovoUtente.pas' {FrameNuovoUtente: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMMain, DMMain);
  Application.CreateForm(TDMRemote, DMRemote);
  Application.CreateForm(TDMEventCollector, DMEventCollector);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
