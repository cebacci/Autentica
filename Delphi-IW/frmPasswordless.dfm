object IWFormPasswordless: TIWFormPasswordless
  Left = 0
  Top = 0
  Width = 812
  Height = 577
  RenderInvisibleControls = True
  OnRender = IWAppFormRender
  AllowPageAccess = True
  ConnectionMode = cmAny
  Title = 'Autentica Passwordless Experience'
  Background.Fixed = False
  HandleTabs = False
  LeftToRight = True
  LockUntilLoaded = True
  LockOnSubmit = True
  ShowHint = True
  DesignLeft = 2
  DesignTop = 2
  object IWImageAppAndroid: TIWImage
    Left = 104
    Top = 40
    Width = 112
    Height = 112
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    BorderOptions.Width = 0
    UseSize = False
    FriendlyName = 'IWImageAppAndroid'
    TransparentColor = clNone
    JpegOptions.CompressionQuality = 90
    JpegOptions.Performance = jpBestSpeed
    JpegOptions.ProgressiveEncoding = False
    JpegOptions.Smoothing = True
  end
  object IWLabelAppAndroid: TIWLabel
    Left = 32
    Top = 168
    Width = 267
    Height = 16
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'IWLabelAppAndroid'
    Caption = 'Punta qui per scaricare la App per Android'
  end
  object IWImageAppiOS: TIWImage
    Left = 512
    Top = 40
    Width = 112
    Height = 112
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    BorderOptions.Width = 0
    UseSize = False
    FriendlyName = 'IWImageAppAndroid'
    TransparentColor = clNone
    JpegOptions.CompressionQuality = 90
    JpegOptions.Performance = jpBestSpeed
    JpegOptions.ProgressiveEncoding = False
    JpegOptions.Smoothing = True
  end
  object IWLabelAppiOS: TIWLabel
    Left = 456
    Top = 168
    Width = 240
    Height = 16
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'IWLabelAppAndroid'
    Caption = 'Punta qui per scaricare la App per iOS'
  end
  object IWImageLogoProgetto: TIWImage
    Left = 32
    Top = 272
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
  object IWImageRegister: TIWImage
    Left = 560
    Top = 296
    Width = 112
    Height = 112
    RenderSize = False
    StyleRenderOptions.RenderSize = False
    BorderOptions.Width = 0
    UseSize = False
    FriendlyName = 'IWImageAppAndroid'
    TransparentColor = clNone
    JpegOptions.CompressionQuality = 90
    JpegOptions.Performance = jpBestSpeed
    JpegOptions.ProgressiveEncoding = False
    JpegOptions.Smoothing = True
  end
  object IWLabelRegister: TIWLabel
    Left = 512
    Top = 424
    Width = 211
    Height = 16
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    HasTabOrder = False
    FriendlyName = 'IWLabelAppAndroid'
    Caption = 'Punta qui per registrarti sulla App'
  end
  object IWButtonFatto: TIWButton
    Left = 296
    Top = 520
    Width = 120
    Height = 30
    Caption = 'Fatto'
    Color = clBtnFace
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'Fatto'
    OnClick = IWButtonFattoClick
  end
  object IWLabelDescrizione: TIWLabel
    Left = 32
    Top = 471
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
  object IWButtonAnnulla: TIWButton
    Left = 432
    Top = 520
    Width = 120
    Height = 30
    Caption = 'Annulla'
    Color = clBtnFace
    Font.Color = clNone
    Font.FontFamily = 'Tahoma, Geneva, sans-serif'
    Font.Size = 10
    Font.Style = []
    FriendlyName = 'Fatto'
    OnClick = IWButtonAnnullaClick
  end
end
