unit frmPasswordless;

interface

uses
  Classes, SysUtils, IWAppForm, IWApplication, IWColor, IWTypes, IWCompButton,
  IWCompLabel, Vcl.Controls, IWVCLBaseControl, IWBaseControl, IWBaseHTMLControl,
  IWControl, IWCompExtCtrls;

type
  TIWFormPasswordless = class(TIWAppForm)
    IWImageAppAndroid: TIWImage;
    IWLabelAppAndroid: TIWLabel;
    IWImageAppiOS: TIWImage;
    IWLabelAppiOS: TIWLabel;
    IWImageLogoProgetto: TIWImage;
    IWImageRegister: TIWImage;
    IWLabelRegister: TIWLabel;
    IWButtonFatto: TIWButton;
    IWLabelDescrizione: TIWLabel;
    IWButtonAnnulla: TIWButton;
    procedure IWAppFormRender(Sender: TObject);
    procedure IWButtonFattoClick(Sender: TObject);
    procedure IWButtonAnnullaClick(Sender: TObject);
  public
  end;

implementation

{$R *.dfm}

uses ServerController;


procedure TIWFormPasswordless.IWAppFormRender(Sender: TObject);
begin
  UserSession.QRCodeAndroid(IWImageAppAndroid);
  UserSession.QRCodeIos(IWImageAppiOS);
  UserSession.DatiProgetto(IWImageLogoProgetto,IWLabelDescrizione);
  UserSession.QRCodeApikeyUsername(IWImageRegister);
end;

procedure TIWFormPasswordless.IWButtonAnnullaClick(Sender: TObject);
begin
  UserSession.Bio:=False;
  UserSession.FormLogon.Show;
end;

procedure TIWFormPasswordless.IWButtonFattoClick(Sender: TObject);
begin
  UserSession.Bio:=True;
  UserSession.FormLogon.Show;
end;

end.
