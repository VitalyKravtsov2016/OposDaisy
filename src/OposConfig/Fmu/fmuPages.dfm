object fmPages: TfmPages
  Left = 461
  Top = 174
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  ClientHeight = 482
  ClientWidth = 584
  Color = clBtnFace
  Constraints.MinHeight = 520
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    584
    482)
  PixelsPerInch = 96
  TextHeight = 13
  object btnDefaults: TTntButton
    Left = 8
    Top = 450
    Width = 81
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Defaults'
    TabOrder = 2
    OnClick = btnDefaultsClick
  end
  object btnOK: TTntButton
    Left = 344
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TTntButton
    Left = 424
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object btnApply: TTntButton
    Left = 504
    Top = 450
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Apply'
    Enabled = False
    TabOrder = 5
    OnClick = btnApplyClick
  end
  object lbPages: TTntListBox
    Left = 8
    Top = 8
    Width = 145
    Height = 427
    Style = lbOwnerDrawFixed
    Anchors = [akLeft, akTop, akBottom]
    ItemHeight = 18
    TabOrder = 0
    OnClick = lbPagesClick
  end
  object pnlPage: TTntPanel
    Left = 160
    Top = 8
    Width = 418
    Height = 427
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'pnlPage'
    TabOrder = 1
  end
end
