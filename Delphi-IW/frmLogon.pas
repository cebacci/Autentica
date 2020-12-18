unit frmLogon;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWCompButton,
  IWCompEdit, Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl,
  IWControl, IWCompLabel, Vcl.Forms, IWVCLBaseContainer, IWContainer,
  IWHTMLContainer, IWHTML40Container, IWRegion, IWBaseComponent,
  IWBaseHTMLComponent, IWBaseHTML40Component, IWCompExtCtrls;

type
  TIWFormLogon = class(TIWAppForm)
    IWLabelNomeUtente: TIWLabel;
    IWEditNomeUtente: TIWEdit;
    IWRegionRisultato: TIWRegion;
    IWLabelToken: TIWLabel;
    IWEditToken: TIWEdit;
    IWLabelIdUser: TIWLabel;
    IWEditIdUser: TIWEdit;
    IWEditRoles: TIWEdit;
    IWLabelRoles: TIWLabel;
    IWEditNonce: TIWEdit;
    IWLabelNonce: TIWLabel;
    IWEditIssuer: TIWEdit;
    IWLabelIssuer: TIWLabel;
    IWEditIssuedAt: TIWEdit;
    IWLabelIssuedAt: TIWLabel;
    IWEditExpiration: TIWEdit;
    IWLabelExpiration: TIWLabel;
    IWRegionLogonConPassword: TIWRegion;
    IWLabelPassword: TIWLabel;
    IWEditPassword: TIWEdit;
    IWButtonLogon: TIWButton;
    IWButtonPasswordlessExperience: TIWButton;
    IWRegionLogonPasswordless: TIWRegion;
    IWLabelAutenticazioneBioInCorso: TIWLabel;
    IWButtonAnnulla: TIWButton;
    IWTimerLogonPasswordless: TIWTimer;
    IWImageLogoProgetto: TIWImage;
    IWLabelDescrizione: TIWLabel;
    procedure IWButtonLogonClick(Sender: TObject);
    procedure IWButtonPasswordlessExperienceClick(Sender: TObject);
    procedure IWAppFormRender(Sender: TObject);
    procedure IWTimerLogonPasswordlessAsyncTimer(Sender: TObject;
      EventParams: TStringList);
    procedure IWButtonAnnullaClick(Sender: TObject);
  public
  end;

implementation

{$R *.dfm}

uses ServerController;

procedure TIWFormLogon.IWAppFormRender(Sender: TObject);
begin
  UserSession.DatiProgetto(IWImageLogoProgetto,IWLabelDescrizione);
  if Length(UserSession.UserName)=0 then
    UserSession.UserName:=WebApplication.Request.GetCookieValue('UserName');
  IWEditNomeUtente.Text:=UserSession.UserName;
  if UserSession.PrimaEsecuzione then
    UserSession.Bio:=WebApplication.Request.GetCookieValue('Bio')='True';
  if UserSession.Bio and (Length(IWEditNomeUtente.Text)>0) then begin
    IWRegionLogonConPassword.Visible:=False;
    IWRegionLogonPasswordless.Visible:=True;
    IWRegionLogonPasswordless.Left:=IWRegionLogonConPassword.Left;
    IWTimerLogonPasswordless.Enabled:=True;
  end;
end;

procedure TIWFormLogon.IWButtonAnnullaClick(Sender: TObject);
begin
  UserSession.Bio:=False;
end;

procedure TIWFormLogon.IWButtonLogonClick(Sender: TObject);
var
  ErrorMessage: String;
  ErrorCode: Integer;
begin
  if Length(IWEditNomeUtente.Text)=0 then begin
    WebApplication.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  if not UserSession.Bio then
    if Length(IWEditPassword.Text)=0 then begin
      WebApplication.ShowMessage('Immettere una Password');
      Exit;
    end;
  UserSession.UserName:=IWEditNomeUtente.Text;
  UserSession.Password:=IWEditPassword.Text;
  if UserSession.Autenticazione('12345','',ErrorMessage,ErrorCode) then begin
    IWRegionLogonConPassword.Visible:=False;
    IWRegionLogonPasswordless.Visible:=False;
    IWRegionRisultato.Top:=IWRegionLogonConPassword.Top;
    IWRegionRisultato.Visible:=True;
    IWEditToken.Text:=UserSession.Token;
    IWEditIdUser.Text:=UserSession.IdUser;
    IWEditRoles.Text:=UserSession.Roles;
    IWEditNonce.Text:=UserSession.Nonce;
    IWEditIssuer.Text:=UserSession.Issuer;
    IWEditIssuedAt.Text:=FormatDateTime('dd/mm/yyyy hh:nn:ss',UserSession.IssuedAt);
    IWEditExpiration.Text:=FormatDateTime('dd/mm/yyyy hh:nn:ss',UserSession.Expiration);
  end
  else begin
    WebApplication.ShowMessage('Errore '+ErrorMessage);
    IWRegionLogonConPassword.Visible:=True;
    IWRegionLogonPasswordless.Visible:=False;
    IWRegionRisultato.Visible:=False;
  end;
end;

procedure TIWFormLogon.IWButtonPasswordlessExperienceClick(Sender: TObject);
begin
  if Length(IWEditNomeUtente.Text)=0 then begin
    WebApplication.ShowMessage('Immettere un Nome Utente');
    Exit;
  end;
  UserSession.UserName:=IWEditNomeUtente.Text;
  UserSession.FormPasswordless.Show;
end;

procedure TIWFormLogon.IWTimerLogonPasswordlessAsyncTimer(Sender: TObject;
  EventParams: TStringList);
begin
  IWTimerLogonPasswordless.Enabled:=False;
  IWButtonLogonClick(IWButtonLogon);
end;

initialization
  TIWFormLogon.SetAsMainForm;

end.
