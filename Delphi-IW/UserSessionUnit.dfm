object IWUserSession: TIWUserSession
  OldCreateOrder = False
  OnCreate = IWUserSessionBaseCreate
  OnDestroy = IWUserSessionBaseDestroy
  Height = 150
  Width = 215
  object IdDecoderMIME: TIdDecoderMIME
    FillChar = '='
    Left = 88
    Top = 56
  end
end
