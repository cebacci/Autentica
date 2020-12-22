unit Event.Collector;

interface

uses
  System.SysUtils, System.Classes, EventBus, Event.Classes;

type
  TDMEventCollector = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterInizializzaSessione(AEvent: TOnAfterInizializzaSessione);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterSalvaConfigurazione(AEvent: TOnAfterSalvaConfigurazione);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterAutenticazione(AEvent: TOnAfterAutenticazione);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterModificaPassword(AEvent: TOnAfterModificaPassword);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterPasswordDimenticata(AEvent: TOnAfterPasswordDimenticata);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterQRCodeApp(AEvent: TOnAfterQRCodeApp);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterQRCodeApiKey(AEvent: TOnAfterQRCodeApiKey);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterNuovoUtente(AEvent: TOnAfterNuovoUtente);
    [Subscribe(TThreadMode.Main)]
    procedure OnAfterCreaUtente(AEvent: TOnAfterCreaUtente);
  end;

const
  cBorderSize=4;

var
  DMEventCollector: TDMEventCollector;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses Forms.Main, DM.Remote, DM.Main, FrameStand, Frames.LoginSenzaPassword, Frames.StandardLogin,
  FMX.DialogService, System.UITypes, System.Threading, FMX.Dialogs, IdCoderMIME, Vcl.Imaging.pngimage,
  Frames.AutenticazioneOk, Frames.PwdScaduta, Frames.DownloadApp, Frames.RegistraApiKey,
  Frames.NuovoUtente;

{ TDMLocal }

procedure TDMEventCollector.DataModuleCreate(Sender: TObject);
begin
  GlobalEventBus.RegisterSubscriberForEvents(Self);
end;

procedure TDMEventCollector.OnAfterAutenticazione(
  AEvent: TOnAfterAutenticazione);
var
  lFrameAutenticazioneOk: TFrameInfo<TFrameAutenticazioneOk>;
  lFramePwdScadutaInfo: TFrameInfo<TFramePwdScaduta>;
  lFrameStandardLoginInfo: TFrameInfo<TFrameStandardLogin>;
begin
  if AEvent.Success then begin
    FormMain.Waiting:=False;
    lFrameAutenticazioneOk:=FormMain.FrameStand.New<TFrameAutenticazioneOk>(FormMain.Layout, 'bluestand');
    DMRemote.AssegnaTokenAMemo(lFrameAutenticazioneOk.Frame.MemoToken.Lines);
    DMMain.Nonce:='';
    lFrameAutenticazioneOk.Show();
  end
  else if (AEvent.ErrorCode=305) or (AEvent.ErrorCode=310) or (AEvent.ErrorCode=311) then begin
    TDialogService.ShowMessage('Credenziali errate');
    DMMain.Tentativi:=DMMain.Tentativi+1;
    if DMMain.Tentativi>2 then begin
      FormMain.Close;
    end;
  end
  else if (AEvent.ErrorCode=312) or (AEvent.ErrorCode=313) then begin
    FormMain.Waiting:=False;
    lFramePwdScadutaInfo:=FormMain.FrameStand.New<TFramePwdScaduta>(FormMain.Layout, 'bluestand');
    lFramePwdScadutaInfo.Show;
  end
  else if (AEvent.ErrorCode>1400) then begin
    if DMMain.Bio then begin
      TDialogService.MessageDialog('Autenticazione via App non effettuata. Premi Ok per un nuovo tentativo o Annulla per interrompere.',
                                   TMsgDlgType.mtWarning,mbOKCancel,TMsgDlgBtn.mbOk,0,
                                   procedure(const AResult: TModalResult)
                                     begin
                                       case AResult of
                                         1: TTask.Run(DMRemote.AutenticazioneBio);
                                         2:
                                           begin
                                             DMMain.Bio:=False;
                                             FormMain.Waiting:=False;
                                             lFrameStandardLoginInfo:=FormMain.FrameStand.New<TFrameStandardLogin>(FormMain.Layout, 'bluestand');
                                             lFrameStandardLoginInfo.Frame.EditNomeUtente.Text:=DMMain.UserName;
                                             lFrameStandardLoginInfo.Show;
                                           end;
                                       end;
                                     end
                                   );
    end;
  end
  else begin
    TDialogService.ShowMessage('Autenticazione non riuscita per l''errore '+AEvent.ErrorCode.ToString+': "'+AEvent.ErrorMessage+'"');
  end;
end;

procedure TDMEventCollector.OnAfterCreaUtente(AEvent: TOnAfterCreaUtente);
var
  lFrameStandardLoginInfo: TFrameInfo<TFrameStandardLogin>;
begin
  if AEvent.Success then begin
    TDialogService.ShowMessage(AEvent.Message);
    DMMain.IdUser:='';
  end
  else
    TDialogService.ShowMessage('Richiesta di Creazione Utente non riuscita per l''errore '+AEvent.ErrorCode.ToString+': "'+AEvent.ErrorMessage+'"');
  FormMain.Waiting:=False;
  lFrameStandardLoginInfo:=FormMain.FrameStand.New<TFrameStandardLogin>(FormMain.Layout, 'bluestand');
  lFrameStandardLoginInfo.Frame.EditNomeUtente.Text:=DMMain.UserName;
  lFrameStandardLoginInfo.Frame.EditPassword.Text:='';
  lFrameStandardLoginInfo.Show();
end;

procedure TDMEventCollector.OnAfterInizializzaSessione(
  AEvent: TOnAfterInizializzaSessione);
var
  lFrameLoginSenzaPasswordInfo: TFrameInfo<TFrameLoginSenzaPassword>;
  lFrameStandardLoginInfo: TFrameInfo<TFrameStandardLogin>;
begin
  FormMain.Waiting:=False;
  FormMain.EditApiKey.Text:=AEvent.ApiKey;
  if AEvent.Bio and (Length(AEvent.UserName)>0) then begin
    lFrameLoginSenzaPasswordInfo:=FormMain.FrameStand.New<TFrameLoginSenzaPassword>(FormMain.Layout, 'bluestand');
    lFrameLoginSenzaPasswordInfo.Frame.EditNomeUtente.Text:=AEvent.UserName;
    lFrameLoginSenzaPasswordInfo.Show();
    TTask.Run(DMRemote.AutenticazioneBio);
  end
  else begin
    lFrameStandardLoginInfo:=FormMain.FrameStand.New<TFrameStandardLogin>(FormMain.Layout, 'bluestand');
    lFrameStandardLoginInfo.Frame.EditNomeUtente.Text:=AEvent.UserName;
    lFrameStandardLoginInfo.Frame.EditPassword.Text:='';
    lFrameStandardLoginInfo.Show();
  end;
end;

procedure TDMEventCollector.OnAfterModificaPassword(
  AEvent: TOnAfterModificaPassword);
begin
  FormMain.Waiting:=False;
  if AEvent.Success then begin
    DMMain.AggiornaPassword;
    FormMain.Waiting:=True;
    TTask.Run(DMRemote.Autenticazione);
  end
  else
    TDialogService.ShowMessage('Modifica Password non riuscita per l''errore '+AEvent.ErrorCode.ToString+': "'+AEvent.ErrorMessage+'"');
end;

procedure TDMEventCollector.OnAfterNuovoUtente(AEvent: TOnAfterNuovoUtente);
var
  lFrameNuovoUtenteInfo: TFrameInfo<TFrameNuovoUtente>;
begin
  FormMain.Waiting:=False;
  if AEvent.Success then begin
    lFrameNuovoUtenteInfo:=FormMain.FrameStand.New<TFrameNuovoUtente>(FormMain.Layout, 'bluestand');
    lFrameNuovoUtenteInfo.Frame.EditID_User.Text:= AEvent.ID_USER;
    lFrameNuovoUtenteInfo.Show;
  end;
end;

procedure TDMEventCollector.OnAfterPasswordDimenticata(
  AEvent: TOnAfterPasswordDimenticata);
begin
  if AEvent.Success then
    TDialogService.ShowMessage(AEvent.Message)
  else
    TDialogService.ShowMessage('Richiesta Nuova Password non riuscita per l''errore '+AEvent.ErrorCode.ToString+': "'+AEvent.ErrorMessage+'"');
  FormMain.Waiting:=False;
  TTask.Run(DMMain.InizializzaSessione);
end;

procedure TDMEventCollector.OnAfterQRCodeApiKey(AEvent: TOnAfterQRCodeApiKey);
var
  lFrameRegistraApiKeyInfo: TFrameInfo<TFrameRegistraApiKey>;
  aStream: TMemoryStream;
begin
  FormMain.Waiting:=False;
  if AEvent.Success then begin
    lFrameRegistraApiKeyInfo:=FormMain.FrameStand.New<TFrameRegistraApiKey>(FormMain.Layout, 'bluestand');
    lFrameRegistraApiKeyInfo.Frame.LabelUtente.Text:= 'Punta qui per registrare nella App l''utente "'+DMMain.UserName+'"';
    aStream:=TMemoryStream.Create;
    try
      lFrameRegistraApiKeyInfo.Frame.LabelProgetto.Text:=AEvent.Descrizione;
      TIdDecoderMIME.DecodeStream(AEvent.Logo,aStream);
      AStream.Seek(0,soBeginning);
      with lFrameRegistraApiKeyInfo.Frame.ImageViewerLogo do begin
        Bitmap.LoadFromStream(aStream);
        BitmapScale:=(Height-cBorderSize)/Bitmap.Height;
      end;
      aStream.Clear;
      TIdDecoderMIME.DecodeStream(AEvent.BitmapApiKey,aStream);
      AStream.Seek(0,soBeginning);
      with lFrameRegistraApiKeyInfo.Frame.ImageViewerQRCodeApiKey do begin
        Bitmap.LoadFromStream(aStream);
        BitmapScale:=(Height-cBorderSize)/Bitmap.Height;
      end;
    finally
      aStream.Free;
    end;
    lFrameRegistraApiKeyInfo.Show();
  end
  else
    TDialogService.ShowMessage('Richiesta QRCode per Utente non riuscita');
end;

procedure TDMEventCollector.OnAfterQRCodeApp(AEvent: TOnAfterQRCodeApp);
var
  lFrameDownloadAppInfo: TFrameInfo<TFrameDownloadApp>;
  aStream: TMemoryStream;
begin
  FormMain.Waiting:=False;
  if AEvent.Success then begin
    lFrameDownloadAppInfo:=FormMain.FrameStand.New<TFrameDownloadApp>(FormMain.Layout, 'bluestand');
    aStream:=TMemoryStream.Create;
    try
      TIdDecoderMIME.DecodeStream(AEvent.BitmapAndroid,aStream);
      AStream.Seek(0,soBeginning);
      with lFrameDownloadAppInfo.Frame.ImageViewerQRCodeAndroid do begin
        Bitmap.LoadFromStream(aStream);
        BitmapScale:=(Height-cBorderSize)/Bitmap.Height;
      end;
      aStream.Clear;
      TIdDecoderMIME.DecodeStream(AEvent.BitmapIos,aStream);
      AStream.Seek(0,soBeginning);
      with lFrameDownloadAppInfo.Frame.ImageViewerQRCodeIos do begin
        Bitmap.LoadFromStream(aStream);
        BitmapScale:=(Height-cBorderSize)/Bitmap.Height;
      end;
    finally
      aStream.Free;
    end;
    lFrameDownloadAppInfo.Show();
  end
  else
    TDialogService.ShowMessage('Richiesta QRCode per App non riuscita');
end;

procedure TDMEventCollector.OnAfterSalvaConfigurazione(
  AEvent: TOnAfterSalvaConfigurazione);
begin
  if AEvent.Uscita then
    FormMain.Close
  else begin
    FormMain.Waiting:=True;
    TTask.Run(DMMain.InizializzaSessione);
  end;
end;

end.
