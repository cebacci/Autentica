unit Forms.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.ExtCtrls, SubjectStand, FrameStand, Frames.Wait,
  Frames.LoginSenzaPassword, Frames.StandardLogin, FMX.Edit,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFormMain = class(TForm)
    FrameStand: TFrameStand;
    ImageViewer: TImageViewer;
    StyleBook: TStyleBook;
    LabelApiKey: TLabel;
    EditApiKey: TEdit;
    Layout: TLayout;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FWaiting: Boolean;
    LFrameWaitInfo: TFrameInfo<TFrameWait>;
    procedure SetWaiting(const Value: Boolean);
  public
    { Public declarations }
    procedure UpdateMessageWaiting(const AText: string; const ASync: Boolean = True);
    property Waiting: Boolean read FWaiting write SetWaiting;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}

uses DM.Main, System.Threading;

procedure TFormMain.FormShow(Sender: TObject);
begin
  Waiting:=True;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TFormMain.SetWaiting(const Value: Boolean);
begin
  FWaiting:=Value;
  if FWaiting then begin
    LFrameWaitInfo:=FrameStand.New<TFrameWait>;
    LFrameWaitInfo.Show;
  end
  else
    FormMain.FrameStand.HideAndCloseAll;//(TFrameWait);
end;

procedure TFormMain.UpdateMessageWaiting(const AText: string;
  const ASync: Boolean);
begin
  if FWaiting then begin
    LFrameWaitInfo.Frame.UpdateMessageText(AText,ASync);
  end;
end;

end.
