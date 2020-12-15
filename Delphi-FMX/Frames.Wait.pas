unit Frames.Wait;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Ani, FMX.Objects, FMX.Controls.Presentation, FMX.Layouts;

type
  TFrameWait = class(TFrame)
    MessageLabel: TLabel;
    BackgroundRectangle: TRectangle;
    ContentsLayout: TLayout;
    AniIndicator1: TAniIndicator;
  private
    { Private declarations }
    function GetMessageText: string;
    procedure SetMessageText(const Value: string);
  public
    { Public declarations }
    procedure UpdateMessageText(const AText: string; const ASync: Boolean = True);

    property MessageText: string read GetMessageText write SetMessageText;
  end;

implementation

{$R *.fmx}

{ TWaitFrame }

function TFrameWait.GetMessageText: string;
begin
  Result := MessageLabel.Text;
end;

procedure TFrameWait.SetMessageText(const Value: string);
begin
  MessageLabel.Text := Value;
end;

procedure TFrameWait.UpdateMessageText(const AText: string;
  const ASync: Boolean);
begin
  if not ASync then
    MessageText := AText
  else
    TThread.Synchronize(nil,
      procedure
      begin
        MessageText := AText;
      end
    );
end;

end.
