unit Frames.StandardLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation;

type
  TFrameStandardLogin = class(TFrame)
    LabelNomeUtente: TLabel;
    EditNomeUtente: TEdit;
    LabelPassword: TLabel;
    EditPassword: TEdit;
    ButtonConferma: TButton;
    ButtonAnnulla: TButton;
    ButtonPasswordLess: TButton;
    ButtonPwdDimenticata: TButton;
    ButtonNuovUtente: TButton;
    procedure ButtonAnnullaClick(Sender: TObject);
    procedure ButtonConfermaClick(Sender: TObject);
    procedure ButtonPwdDimenticataClick(Sender: TObject);
    procedure ButtonPasswordLessClick(Sender: TObject);
    procedure ButtonNuovUtenteClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.fmx}

uses Forms.Main, DM.Main, System.Threading, FMX.DialogService, DM.Remote;

procedure TFrameStandardLogin.ButtonAnnullaClick(Sender: TObject);
begin
  TTask.Run(procedure begin DMMain.SalvaConfigurazione(True) end);
end;

procedure TFrameStandardLogin.ButtonConfermaClick(Sender: TObject);
begin
  if Length(Trim(FormMain.EditApiKey.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una ApiKey');
    Exit;
  end;
  if Length(Trim(EditNomeUtente.Text))=0 then begin
    TDialogService.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  if Length(Trim(EditPassword.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una Password');
    Exit;
  end;
  DMMain.ApiKey:=FormMain.EditApiKey.Text;
  DMMain.UserName:=EditNomeUtente.Text;
  DMMain.Password:=EditPassword.Text;
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.Autenticazione);
end;

procedure TFrameStandardLogin.ButtonNuovUtenteClick(Sender: TObject);
begin
  if Length(Trim(FormMain.EditApiKey.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una ApiKey');
    Exit;
  end;
  if Length(Trim(EditNomeUtente.Text))=0 then begin
    TDialogService.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  DMMain.ApiKey:=FormMain.EditApiKey.Text;
  DMMain.UserName:=EditNomeUtente.Text;
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.NuovoUtente);
end;

procedure TFrameStandardLogin.ButtonPasswordLessClick(Sender: TObject);
begin
  if Length(Trim(FormMain.EditApiKey.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una ApiKey');
    Exit;
  end;
  if Length(Trim(EditNomeUtente.Text))=0 then begin
    TDialogService.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  DMMain.ApiKey:=FormMain.EditApiKey.Text;
  DMMain.UserName:=EditNomeUtente.Text;
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.QRCodeApp);
end;

procedure TFrameStandardLogin.ButtonPwdDimenticataClick(Sender: TObject);
begin
  if Length(Trim(FormMain.EditApiKey.Text))=0 then begin
    TDialogService.ShowMessage('Immettere una ApiKey');
    Exit;
  end;
  if Length(Trim(EditNomeUtente.Text))=0 then begin
    TDialogService.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  DMMain.ApiKey:=FormMain.EditApiKey.Text;
  DMMain.UserName:=EditNomeUtente.Text;
  FormMain.Waiting:=True;
  TTask.Run(DMRemote.PasswordDimenticata);
end;

end.
