unit Frames.NuovoUtente;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Edit, FMX.Controls.Presentation;

type
  TFrameNuovoUtente = class(TFrame)
    LabelPassword: TLabel;
    EditPassword: TEdit;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
    LabelMessaggio: TLabel;
    LabelRipetiPassword: TLabel;
    EditRipetiPassword: TEdit;
    LabelNomeUtente: TLabel;
    EditNomeUtente: TEdit;
    LabelID_User: TLabel;
    EditID_User: TEdit;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure EditPasswordChangeTracking(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses DM.Main, System.Threading, FMX.DialogService, DM.Remote, Forms.Main;

procedure TFrameNuovoUtente.ButtonAnnullaClick(Sender: TObject);
begin
  FormMain.Waiting:=True;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TFrameNuovoUtente.ButtonConfermaClick(Sender: TObject);
begin
  if Length(Trim(EditID_User.Text))=0 then begin
    TDialogService.ShowMessage('Immettere un ID User');
    Exit;
  end;
  if Length(Trim(EditNomeUtente.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una Nome Utente');
    Exit;
  end;
  if Length(Trim(EditPassword.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una Nuova Password');
    Exit;
  end;
  if Length(Trim(EditRipetiPassword.Text))=0 then begin
    TDialogService.ShowMessage('Ripetere la Nuova Password');
    Exit;
  end;
  if EditPassword.Text<>EditRipetiPassword.Text then begin
    TDialogService.ShowMessage('Le Password immesse non corrispondono');
    Exit;
  end;
  if not Rectangle5.Visible then begin
    TDialogService.ShowMessage('La Nuova Password non rispetta le norme in merito');
    Exit;
  end;
  DMMain.UserName:=EditNomeUtente.Text;
  DMMain.NuovaPassword:=EditPassword.Text;
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.CreaUtente);
end;

procedure TFrameNuovoUtente.EditPasswordChangeTracking(Sender: TObject);
  procedure DrawIndicator(const aValue: Integer);
  begin
    Rectangle1.Visible:=aValue>0;
    Rectangle2.Visible:=aValue>1;
    Rectangle3.Visible:=aValue>2;
    Rectangle4.Visible:=aValue>3;
    Rectangle5.Visible:=aValue>4;
  end;
begin
  DrawIndicator(DMMain.ValutazionePassword((Sender as TEdit).Text));
end;

end.
