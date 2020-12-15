unit Frames.RegistraApiKey;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ExtCtrls, FMX.Controls.Presentation;

type
  TFrameRegistraApiKey = class(TFrame)
    LabelMessaggio: TLabel;
    ImageViewerQRCodeApiKey: TImageViewer;
    LabelUtente: TLabel;
    ButtonFatto: TButton;
    ButtonAnnulla: TButton;
    ImageViewerLogo: TImageViewer;
    LabelProgetto: TLabel;
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonFattoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DM.Main, System.Threading, Forms.Main;

procedure TFrameRegistraApiKey.ButtonAnnullaClick(Sender: TObject);
begin
  FormMain.Waiting:=True;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TFrameRegistraApiKey.ButtonFattoClick(Sender: TObject);
begin
  DMMain.Bio:=True;
  TTask.Run(procedure begin DMMain.SalvaConfigurazione end);
end;

end.
