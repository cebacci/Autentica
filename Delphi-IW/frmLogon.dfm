object IWFormLogon: TIWFormLogon
  Left = 0
  Top = 0
  Width = 889
  Height = 773
  RenderInvisibleControls = True
  OnRender = IWAppFormRender
  AllowPageAccess = True
  ConnectionMode = cmAny
  Title = 'Autentica IW'
  Background.Fixed = False
  HandleTabs = False
  LeftToRight = True
  LockUntilLoaded = True
  LockOnSubmit = True
  ShowHint = True
  DesignSize = (
    889
    773)
  DesignLeft = 2
  DesignTop = 2
  object IWLabelNomeUtente: TIWLabel
    Left = 88
    Top = 248
    Width = 86
    Height = 16
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'IWLabelNomeUtente'
    Caption = 'Nome Utente:'
  end
  object IWEditNomeUtente: TIWEdit
    Left = 184
    Top = 242
    Width = 249
    Height = 32
    StyleRenderOptions.RenderBorder = False
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'IWEditNomeUtente'
    SubmitOnAsyncEvent = True
  end
  object IWImageLogoProgetto: TIWImage
    Left = 296
    Top = 8
    Width = 353
    Height = 193
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    BorderOptions.Width = 0
    UseSize = False
    FriendlyName = 'IWImageLogoProgetto'
    TransparentColor = clNone
    JpegOptions.CompressionQuality = 90
    JpegOptions.Performance = jpBestSpeed
    JpegOptions.ProgressiveEncoding = False
    JpegOptions.Smoothing = True
  end
  object IWLabelDescrizione: TIWLabel
    Left = 296
    Top = 207
    Width = 353
    Height = 16
    Alignment = taCenter
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    AutoSize = False
    FriendlyName = 'IWLabelDescrizione'
    Caption = '...'
  end
  object IWRegionRisultato: TIWRegion
    Left = 64
    Top = 424
    Width = 499
    Height = 340
    Visible = False
    RenderInvisibleControls = True
    Anchors = [akLeft, akTop, akRight, akBottom]
    BorderOptions.NumericWidth = 0
    DesignSize = (
      499
      340)
    object IWLabelToken: TIWLabel
      Left = 24
      Top = 21
      Width = 44
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'Token:'
    end
    object IWEditToken: TIWEdit
      Left = 120
      Top = 14
      Width = 353
      Height = 32
      Anchors = [akLeft, akTop, akRight]
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelIdUser: TIWLabel
      Left = 24
      Top = 66
      Width = 60
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'ID_USER:'
    end
    object IWEditIdUser: TIWEdit
      Left = 120
      Top = 59
      Width = 289
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWEditRoles: TIWEdit
      Left = 120
      Top = 104
      Width = 353
      Height = 32
      Anchors = [akLeft, akTop, akRight]
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelRoles: TIWLabel
      Left = 24
      Top = 111
      Width = 47
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'ROLES:'
    end
    object IWEditNonce: TIWEdit
      Left = 120
      Top = 149
      Width = 289
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelNonce: TIWLabel
      Left = 24
      Top = 156
      Width = 44
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'Nonce:'
    end
    object IWEditIssuer: TIWEdit
      Left = 120
      Top = 211
      Width = 289
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelIssuer: TIWLabel
      Left = 24
      Top = 218
      Width = 44
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'Issuer:'
    end
    object IWEditIssuedAt: TIWEdit
      Left = 120
      Top = 256
      Width = 289
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelIssuedAt: TIWLabel
      Left = 24
      Top = 263
      Width = 63
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'Issued At:'
    end
    object IWEditExpiration: TIWEdit
      Left = 120
      Top = 301
      Width = 289
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditToken'
      ReadOnly = True
      SubmitOnAsyncEvent = True
    end
    object IWLabelExpiration: TIWLabel
      Left = 24
      Top = 308
      Width = 67
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelToken'
      Caption = 'Expiration:'
    end
  end
  object IWRegionLogonConPassword: TIWRegion
    Left = 64
    Top = 280
    Width = 499
    Height = 130
    RenderInvisibleControls = True
    BorderOptions.NumericWidth = 0
    object IWLabelPassword: TIWLabel
      Left = 24
      Top = 20
      Width = 66
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelPassword'
      Caption = 'Password:'
    end
    object IWEditPassword: TIWEdit
      Left = 120
      Top = 14
      Width = 249
      Height = 32
      StyleRenderOptions.RenderBorder = False
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWEditPassword'
      SubmitOnAsyncEvent = True
      PasswordPrompt = True
      DataType = stPassword
    end
    object IWButtonLogon: TIWButton
      Left = 120
      Top = 84
      Width = 120
      Height = 30
      Caption = 'Logon'
      Color = clBtnFace
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWButtonLogon'
      OnClick = IWButtonLogonClick
    end
    object IWButtonPasswordlessExperience: TIWButton
      Left = 280
      Top = 84
      Width = 216
      Height = 30
      Caption = 'Prova la Passwordless Experience'
      Color = clBtnFace
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWButtonPasswordlessExperience'
      OnClick = IWButtonPasswordlessExperienceClick
    end
  end
  object IWRegionLogonPasswordless: TIWRegion
    Left = 608
    Top = 280
    Width = 499
    Height = 130
    Visible = False
    RenderInvisibleControls = True
    BorderOptions.NumericWidth = 0
    object IWLabelAutenticazioneBioInCorso: TIWLabel
      Left = 69
      Top = 52
      Width = 427
      Height = 16
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      HasTabOrder = False
      FriendlyName = 'IWLabelAutenticazioneBioInCorso'
      Caption = 
        'Autenticazione In Corso, usa la App Autentica con lettura biomet' +
        'rica'
    end
    object IWButtonAnnulla: TIWButton
      Left = 192
      Top = 88
      Width = 120
      Height = 30
      Caption = 'Annulla'
      Color = clBtnFace
      Font.Color = clNone
      Font.FontFamily = 'Tahoma, Geneva, sans-serif'
      Font.Size = 10
      Font.Style = []
      FriendlyName = 'IWButtonAnnulla'
      OnClick = IWButtonAnnullaClick
    end
  end
  object IWTimerLogonPasswordless: TIWTimer
    Enabled = False
    Interval = 100
    ShowAsyncLock = False
    OnAsyncTimer = IWTimerLogonPasswordlessAsyncTimer
    Left = 640
    Top = 352
  end
end
