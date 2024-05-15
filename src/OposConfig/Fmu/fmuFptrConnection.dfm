object fmFptrConnection: TfmFptrConnection
  Left = 546
  Top = 170
  Width = 287
  Height = 446
  Caption = 'Connection'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    271
    408)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMaxRetryCount: TTntLabel
    Left = 24
    Top = 216
    Width = 74
    Height = 13
    Caption = 'Connect retries:'
  end
  object lblByteTimeout: TTntLabel
    Left = 24
    Top = 184
    Width = 80
    Height = 13
    Caption = 'Byte timeout, ms:'
  end
  object lblBaudRate: TTntLabel
    Left = 24
    Top = 152
    Width = 46
    Height = 13
    Caption = 'Baudrate:'
  end
  object lblComPort: TTntLabel
    Left = 24
    Top = 120
    Width = 48
    Height = 13
    Caption = 'COM port:'
  end
  object lblRemotePort: TTntLabel
    Left = 24
    Top = 88
    Width = 61
    Height = 13
    Caption = 'Remote port:'
  end
  object lblRemoteHost: TTntLabel
    Left = 24
    Top = 56
    Width = 63
    Height = 13
    Caption = 'Remote host:'
  end
  object lblConnectionType: TTntLabel
    Left = 24
    Top = 24
    Width = 80
    Height = 13
    Caption = 'Connection type:'
  end
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 257
    Height = 297
    Anchors = [akLeft, akTop, akRight]
    Shape = bsFrame
  end
  object chbSearchByPort: TTntCheckBox
    Left = 24
    Top = 272
    Width = 233
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Find device on all available COM ports'
    TabOrder = 8
  end
  object chbSearchByBaudRate: TTntCheckBox
    Left = 24
    Top = 248
    Width = 233
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Find device on all available baud rates'
    TabOrder = 7
  end
  object cbMaxRetryCount: TTntComboBox
    Left = 128
    Top = 216
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    Items.Strings = (
      'INFINITE'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10')
  end
  object seByteTimeout: TSpinEdit
    Left = 128
    Top = 184
    Width = 129
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 5
    Value = 0
  end
  object cbBaudRate: TTntComboBox
    Left = 128
    Top = 152
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      '2400'
      '4800'
      '9600'
      '19200'
      '38400'
      '57600'
      '115200')
  end
  object cbComPort: TTntComboBox
    Left = 128
    Top = 120
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
  end
  object seRemotePort: TSpinEdit
    Left = 128
    Top = 88
    Width = 129
    Height = 22
    MaxValue = 0
    MinValue = 0
    TabOrder = 2
    Value = 0
  end
  object edtRemoteHost: TTntEdit
    Left = 128
    Top = 56
    Width = 129
    Height = 21
    TabOrder = 1
    Text = 'edtRemoteHost'
  end
  object cbConnectionType: TTntComboBox
    Left = 128
    Top = 24
    Width = 129
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'SERIAL'
      'SOCKET')
  end
  object btnConnect: TButton
    Left = 192
    Top = 376
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Connect'
    TabOrder = 9
    OnClick = btnConnectClick
  end
  object memResult: TMemo
    Left = 8
    Top = 312
    Width = 257
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 10
  end
end
