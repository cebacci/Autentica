unit Frames.LoginSenzaPassword;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation;

type
  TFrameLoginSenzaPassword = class(TFrame)
    LabelNomeUtente: TLabel;
    EditNomeUtente: TEdit;
    LabelMessaggio: TLabel;
    AniIndicator: TAniIndicator;
    ButtonAnnulla: TButton;
    procedure ButtonAnnullaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DM.Main, Forms.Main, Frames.StandardLogin, FrameStand, DM.Remote;

procedure TFrameLoginSenzaPassword.ButtonAnnullaClick(Sender: TObject);
var
  lFrameStandardLoginInfo: TFrameInfo<TFrameStandardLogin>;
begin
  DMRemote.AnnullaAutenticazioneBio;
  FormMain.Waiting:=False;
  DMMain.Bio:=False;
  lFrameStandardLoginInfo:=FormMain.FrameStand.New<TFrameStandardLogin>(FormMain.Layout, 'bluestand');
  lFrameStandardLoginInfo.Frame.EditNomeUtente.Text:=DMMain.UserName;
  lFrameStandardLoginInfo.Show;
end;

end.
