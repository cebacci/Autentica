program Autenticazione_FMXER;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.MainXER in 'Forms.MainXER.pas' {FormMain},
  DM.Main in 'DM.Main.pas' {DMMain: TDataModule},
  DM.Remote in 'DM.Remote.pas' {DMRemote: TDataModule},
  Event.Classes in 'Event.Classes.pas',
  Frames.TokenXER in 'Frames.TokenXER.pas' {FrameToken: TFrame},
  Frames.LogoXER in 'Frames.LogoXER.pas' {FrameLogo: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMMain, DMMain);
  Application.CreateForm(TDMRemote, DMRemote);
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
