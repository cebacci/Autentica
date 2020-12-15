unit Frames.DownloadApp;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.ExtCtrls, FMX.Controls.Presentation;

type
  TFrameDownloadApp = class(TFrame)
    LabelMessaggio: TLabel;
    ImageViewerQRCodeAndroid: TImageViewer;
    ImageViewerQRCodeIos: TImageViewer;
    LabelAndroid: TLabel;
    LabelIos: TLabel;
    ButtonFatto: TButton;
    ButtonAnnulla: TButton;
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonFattoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DM.Main, System.Threading, DM.Remote, Forms.Main;

procedure TFrameDownloadApp.ButtonAnnullaClick(Sender: TObject);
begin
  FormMain.Waiting:=True;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TFrameDownloadApp.ButtonFattoClick(Sender: TObject);
begin
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.QRCodeApiKey);
end;

end.
