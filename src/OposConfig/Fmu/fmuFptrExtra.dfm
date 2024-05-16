object fmFptrExtra: TfmFptrExtra
  Left = 744
  Top = 251
  Width = 259
  Height = 355
  Caption = 'Extra'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  DesignSize = (
    243
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object lblPollInterval: TTntLabel
    Left = 16
    Top = 24
    Width = 80
    Height = 13
    Caption = 'Poll interval, sec:'
  end
  object Bevel2: TBevel
    Left = 8
    Top = 8
    Width = 225
    Height = 65
    Shape = bsFrame
  end
  object lblUsrPassword: TTntLabel
    Left = 16
    Top = 96
    Width = 82
    Height = 13
    Caption = 'Operator number:'
  end
  object lblSysPassword: TTntLabel
    Left = 16
    Top = 128
    Width = 92
    Height = 13
    Caption = 'Operator password:'
  end
  object Bevel3: TBevel
    Left = 8
    Top = 80
    Width = 225
    Height = 97
    Shape = bsFrame
  end
  object lblRefundLine1: TTntLabel
    Left = 8
    Top = 184
    Width = 66
    Height = 13
    Caption = 'Refund line 1:'
  end
  object lblRefundLine2: TTntLabel
    Left = 8
    Top = 224
    Width = 66
    Height = 13
    Caption = 'Refund line 2:'
  end
  object sePollInterval: TSpinEdit
    Left = 112
    Top = 24
    Width = 113
    Height = 22
    MaxValue = 60
    MinValue = 0
    TabOrder = 0
    Value = 1
  end
  object seOperatorNumber: TSpinEdit
    Left = 120
    Top = 96
    Width = 105
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 1
    Value = 0
  end
  object seOperatorPassword: TSpinEdit
    Left = 120
    Top = 128
    Width = 105
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object edtRefundLine1: TTntEdit
    Left = 8
    Top = 200
    Width = 225
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    Text = 'edtRefundLine1'
  end
  object edtRefundLine2: TTntEdit
    Left = 8
    Top = 240
    Width = 225
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    Text = 'edtRefundLine1'
  end
end
