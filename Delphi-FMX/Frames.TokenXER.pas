unit Frames.TokenXER;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Memo.Types, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.Menus,
  FMX.Layouts;

type
  TFrameToken = class(TFrame)
    MemoToken: TMemo;
    LabelTitle: TLabel;
    PopupMenu: TPopupMenu;
    CopiatokenrisultantesuAppunti1: TMenuItem;
    PanelBottom: TPanel;
    ButtonCopia: TButton;
    Layout: TLayout;
    procedure CopiatokenrisultantesuAppunti1Click(Sender: TObject);
    procedure ButtonCopiaClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses FMX.Platform, DM.Remote;

procedure TFrameToken.ButtonCopiaClick(Sender: TObject);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, Svc) then
    Svc.SetClipboard(DMRemote.Token);
end;

procedure TFrameToken.CopiatokenrisultantesuAppunti1Click(Sender: TObject);
begin
  ButtonCopiaClick(ButtonCopia);
end;

end.
