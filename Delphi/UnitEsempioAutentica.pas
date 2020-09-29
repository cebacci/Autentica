unit UnitEsempioAutentica;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses UnitAutentica;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  MyApiKey,MyNonce: String;
  IdUser,lToken,MsgErrore: String;
  CodErrore: Integer;
begin
  MyApiKey:='565D4ADF-3975-454C-9F63-1755C2C49BAF';
  MyNonce:='ABC123';
  if not UnitAutentica.Autenticazione(MyApiKey,MyNonce,Caption,IdUser,lToken,MsgErrore,CodErrore) then begin
    MessageBox(Handle,
               Pchar('Autenticazione non riuscita a causa del seguente errore:"'#13#10#13#10 +
                     MsgErrore+#13#10#13#10+
                     'Cod. Errore: '+CodErrore.ToString),
               Pchar(Caption),
               mb_IconError);
    Exit;
  end;
  ShowMessage('Benvenuto, '+IdUser);
end;

end.
