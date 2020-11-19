object FrmHttpParam: TFrmHttpParam
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #31995#32479#21442#25968
  ClientHeight = 402
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 493
    Top = 17
    Width = 75
    Height = 25
    Caption = #30830#23450'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 493
    Top = 51
    Width = 75
    Height = 25
    Caption = #21462#28040'(&N)'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 479
    Height = 385
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'HttpParam'
      ExplicitWidth = 281
      ExplicitHeight = 165
      object memoHttpParams: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 465
        Height = 351
        Align = alClient
        Lines.Strings = (
          'memoHttpParams')
        TabOrder = 0
        ExplicitLeft = 4
        ExplicitTop = 17
        ExplicitWidth = 455
        ExplicitHeight = 320
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'SMTPParam'
      ImageIndex = 1
      ExplicitWidth = 281
      ExplicitHeight = 165
      object memoSMTPParams: TMemo
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 465
        Height = 351
        Align = alClient
        Lines.Strings = (
          'memoHttpParams')
        TabOrder = 0
        ExplicitLeft = 6
        ExplicitTop = 6
      end
    end
  end
end
