object fmFptrLog: TfmFptrLog
  Left = 536
  Top = 304
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Log'
  ClientHeight = 292
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    250
    292)
  PixelsPerInch = 96
  TextHeight = 13
  object lblLogFilePath: TTntLabel
    Left = 16
    Top = 40
    Width = 61
    Height = 13
    Caption = 'Log file path:'
  end
  object lblMaxLogFileCount: TTntLabel
    Left = 16
    Top = 88
    Width = 93
    Height = 13
    Caption = 'Maximum file count:'
  end
  object Label1: TLabel
    Left = 16
    Top = 136
    Width = 124
    Height = 13
    Caption = '0 - unlimited log files count'
  end
  object chbLogEnabled: TTntCheckBox
    Left = 8
    Top = 8
    Width = 97
    Height = 17
    Caption = 'Log file enabled'
    TabOrder = 0
    OnClick = PageChanged
  end
  object edtLogFilePath: TTntEdit
    Left = 16
    Top = 56
    Width = 225
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 1
    Text = 'edtLogFilePath'
    OnChange = PageChanged
  end
  object seMaxLogFileCount: TSpinEdit
    Left = 16
    Top = 104
    Width = 225
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
    OnChange = PageChanged
  end
end
