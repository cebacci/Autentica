unit Forms.MainXER;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  SubjectStand, FormStand, System.ImageList, FMX.ImgList;

type
  TFormMain = class(TForm)
    Stands: TStyleBook;
    FormStand1: TFormStand;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure NavigatorStackPopkHandler(Sender: TObject);
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.fmx}


uses
  System.Threading, FMX.StdCtrls,
  FMXER.UI.Consts, FMXER.UI.Misc, FMXER.Navigator
, FMXER.ScaffoldForm, FMXER.ColumnForm, FMXER.BackgroundForm, FMXER.ContainerForm
, FMXER.LogoFrame, FMXER.ContainerFrame, FMXER.EditFrame, FMXER.ButtonFrame,
  FMX.ActnList, FMXER.TextFrame, FMXER.HorzDividerFrame, FMXER.VertScrollFrame,
  DM.Main, DM.Remote, Frames.TokenXER, Frames.LogoXER;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  inherited;

  DMMain.InizializzaSessione;

  Navigator(FormStand1) // initialization
  .DefineRoute<TColumnForm>( // route definition
     'login'
   , procedure (AForm: TColumnForm)
     begin
       AForm.AddFrame<TFrameLogo>(100);

       AForm.AddFrame<TEditFrame>(80
         , procedure (AFrame: TEditFrame)
           begin
             AFrame.Caption := 'ApiKey:';
             AFrame.Text := DMMain.ApiKey;
             AFrame.OnChangeProc :=
               procedure (ATracking: Boolean)
               begin
                 DMMain.ApiKey := AFrame.Text;
               end;
           end
       );
       AForm.AddFrame<TEditFrame>(80
         , procedure (AFrame: TEditFrame)
           begin
             AFrame.Caption := 'Username:';
             AFrame.Text := DMMain.UserName;
             AFrame.OnChangeProc :=
               procedure (ATracking: Boolean)
               begin
                 DMMain.UserName := AFrame.Text;
               end;
           end
       );
       AForm.AddFrame<TEditFrame>(80
         , procedure (AFrame: TEditFrame)
           begin
             AFrame.Caption := 'Password:';
             AFrame.Password := True;
             AFrame.OnChangeProc :=
               procedure (ATracking: Boolean)
               begin
                 DMMain.Password := AFrame.Text;
               end;
           end
       );

       AForm.AddFrame<TButtonFrame>(80
         , procedure (AFrame: TButtonFrame)
           begin
             AFrame.Text := 'Login';
             AFrame.ButtonControl.Width := 200;
             AFrame.IsDefault := True;

             AFrame.OnUpdateProc :=
               procedure(AAction: TAction)
               begin
                 AAction.Enabled := not (DMMain.ApiKey.Trim.IsEmpty)
                   and (not DMMain.Password.IsEmpty)
                   and (not DMMain.Password.IsEmpty);
               end;

             AFrame.OnClickProc :=
               procedure (AFrame: TButtonFrame)
               begin
                 DMRemote.AttemptLogin(
                   procedure  //OnSuccess
                   begin
                     DMMain.SalvaConfigurazione;
                     Navigator.StackPop;
                     Navigator.RouteTo('accessed');
                   end
                 , procedure  //On Error
                   begin
                     ShowMessage('Login non riuscito per errore "'+DMRemote.ErrorMessage+'"');
                   end
                 );
               end;
           end
       );
     end
  )
  .DefineRoute<TBackgroundForm>( // route definition
     'accessed'
   , procedure (ABackground: TBackgroundForm)
     begin
       ABackground.Fill.Color := TAppColors.MATERIAL_AMBER_800;

       ABackground.SetContentAsFrame<TVertScrollFrame>(
         procedure (AScroll: TVertScrollFrame)
         begin
           AScroll.SetContentAsForm<TColumnForm>(
             procedure(AColumn: TColumnForm)
             begin
               AColumn.AddFrame<TTextFrame>(100
                 , procedure (AText: TTextFrame)
                   begin
                     AText.Content := 'Autenticazione riuscita';
                   end);

               AColumn.AddFrame<THorzDividerFrame>(1); // ----------------------

               AColumn.AddFrame<TFrameToken>(400
                 , procedure(AFrame: TFrameToken)
                   begin
                     AFrame.Align:=TAlignLayout.Client;
                     DMRemote.AssegnaTokenAMemo(AFrame.MemoToken.Lines);
                   end);

               AColumn.AddFrame<THorzDividerFrame>(1); // ----------------------

               AColumn.AddFrame<TContainerFrame>(100
                 , procedure (AContainer: TContainerFrame)
                   begin
                     AContainer.SetContentAs<TButton>(
                       procedure (AButton: TButton)
                       begin
                         AButton.Text := 'Nuovo accesso';
                         AButton.Width:=200;
                         AButton.OnClick := NavigatorStackPopkHandler;
                         AButton.Align := TAlignLayout.Center;
                       end);
                   end);
             end);
         end);

     end
  );

  Navigator.RouteTo('login'); // initial route
end;

procedure TFormMain.NavigatorStackPopkHandler(Sender: TObject);
begin
  Navigator.StackPop;
  Navigator.RouteTo('login');
end;

end.
