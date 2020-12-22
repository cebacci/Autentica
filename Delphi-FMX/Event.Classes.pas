unit Event.Classes;

interface

uses FMX.Graphics;

type
  TOnAfterInizializzaSessione = class(TObject)
  private
    FApiKey: String;
    FUserName: String;
    FBio: Boolean;
  public
    constructor Create(const aApiKey,aUserName: String; const aBio: Boolean);
    property ApiKey: String read FApiKey write FApiKey;
    property UserName: String read FUserName write FUserName;
    property Bio: Boolean read FBio write FBio;
  end;

  TOnAfterSalvaConfigurazione = class(TObject)
  private
    FUscita: Boolean;
  public
    constructor Create(const aUscita: Boolean);
    property Uscita: Boolean read FUscita write FUscita;
  end;

  TOnAfterAutenticazione = class(TObject)
  private
    FSuccess: Boolean;
    FErrorCode: Integer;
    FErrorMessage: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
  end;

  TOnAfterModificaPassword = class(TObject)
  private
    FSuccess: Boolean;
    FErrorCode: Integer;
    FErrorMessage: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
  end;

  TOnAfterPasswordDimenticata = class(TObject)
  private
    FSuccess: Boolean;
    FMessage: String;
    FErrorCode: Integer;
    FErrorMessage: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property &Message: String read FMessage write FMessage;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
  end;

  TOnAfterQRCodeApp = class(TObject)
  private
    FSuccess: Boolean;
    FBitmapAndroid: String;
    FBitmapIos: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property BitmapAndroid: String read FBitmapAndroid write FBitmapAndroid;
    property BitmapIos: String read FBitmapIos write FBitmapIos;
  end;

  TOnAfterQRCodeApiKey = class(TObject)
  private
    FSuccess: Boolean;
    FBitmapApiKey: String;
    FDescrizione: String;
    FLogo: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property BitmapApiKey: String read FBitmapApiKey write FBitmapApiKey;
    property Logo: String read FLogo write FLogo;
    property Descrizione: String read FDescrizione write FDescrizione;
  end;

  TOnAfterNuovoUtente = class(TObject)
  private
    FSuccess: Boolean;
    FID_USER: String;
  public
    constructor Create(const aSuccess: Boolean=False; const aID_USER: String='');
    property Success: Boolean read FSuccess write FSuccess;
    property ID_USER: String read FID_USER write FID_USER;
  end;

  TOnAfterCreaUtente = class(TObject)
  private
    FSuccess: Boolean;
    FMessage: String;
    FErrorCode: Integer;
    FErrorMessage: String;
  public
    property Success: Boolean read FSuccess write FSuccess;
    property &Message: String read FMessage write FMessage;
    property ErrorCode: Integer read FErrorCode write FErrorCode;
    property ErrorMessage: String read FErrorMessage write FErrorMessage;
  end;

implementation

{ TOnAfterInizializzaSessione }

constructor TOnAfterInizializzaSessione.Create(const aApiKey,aUserName: String; const aBio: Boolean);
begin
  FApiKey:=aApiKey;
  FUserName:=aUserName;
  FBio:=aBio;
end;

{ TOnAfterSalvaConfigurazione }

constructor TOnAfterSalvaConfigurazione.Create(const aUscita: Boolean);
begin
  FUscita:=aUscita;
end;

{ TOnAfterNuovoUtente }

constructor TOnAfterNuovoUtente.Create(const aSuccess: Boolean;
  const aID_USER: String);
begin
  FSuccess:=aSuccess;
  FID_USER:=aID_USER;
end;

end.


