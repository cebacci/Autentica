unit Frames.AutenticazioneOk;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Controls.Presentation, FMX.Menus;

type
  TFrameAutenticazioneOk = class(TFrame)
    LabelMessaggio: TLabel;
    MemoToken: TMemo;
    ButtonTorna: TButton;
    PopupMenu: TPopupMenu;
    CopiatokenrisultantesuAppunti1: TMenuItem;
    ButtonCopia: TButton;
    procedure CopiatokenrisultantesuAppunti1Click(Sender: TObject);
    procedure MemoTokenKeyDown(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure ButtonTornaClick(Sender: TObject);
    procedure ButtonCopiaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DM.Remote, FMX.Platform, DM.Main, System.Threading, Forms.Main;

procedure TFrameAutenticazioneOk.ButtonCopiaClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
    Svc.SetClipboard(DMRemote.Token);
end;

procedure TFrameAutenticazioneOk.ButtonTornaClick(Sender: TObject);
begin
  FormMain.Waiting:=True;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TFrameAutenticazioneOk.CopiatokenrisultantesuAppunti1Click(
  Sender: TObject);
begin
  ButtonCopiaClick(ButtonCopia);
end;

procedure TFrameAutenticazioneOk.MemoTokenKeyDown(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if (Key=67) and (ssCtrl in Shift) then begin
    ButtonCopiaClick(ButtonCopia);
    Key:=0;
  end;
end;

end.
