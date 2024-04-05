unit DatecsTypes;

interface

uses
  ByteUtils;

const  
///////////////////////////////////////////////////////////////////////////////
// Encoding constants

  EncodingNone      = 0;
  EncodingAuto      = 1;
  EncodingSelected  = 2;


type
  { TDatecsStatus }

  TDatecsStatus = record
    Data: string;
    // Byte 0
    GeneralError: Boolean;
    PrinterError: Boolean;
    DisplayDisconnected: Boolean;
    ClockNotSet: Boolean;
    InvalidCommandCode: Boolean;
    InvalidDataSyntax: Boolean;
    // Byte 1
    WrongPassword: Boolean;
    CutterError: Boolean;
    MemoryCleared: Boolean;
    InvalidCommandInMode: Boolean;
    SumsOverflow: Boolean;
    // Byte 2
    NonfiscalRecOpened: Boolean;
    JournalPaperNearEnd: Boolean;
    FiscalRecOpened: Boolean;
    JournalPaperEmpty: Boolean;
    ReceiptPaperNearEnd: Boolean;
    RecJrnPaperNearEnd: Boolean;
    RecJrnStationEmpty: Boolean;


    JrnSmallFont: Boolean; // 3.6, ����������� ����� �� ����������� �����
    DisplayCP866: Boolean; // 3.5, ������� ������� ������� (Windows 1251)
    PrinterCP866: Boolean; // 3.4, ������� �������� ������� DOS/Windows 1251
    TransparentDisplay: Boolean; // 3.3, ����� "���������� �������"
    AutoCut: Boolean; // 3.2, �������������� ������� ����
    BaudRate: Integer; // 3.0-3.1, �������� ����������������� �����

    FMError: Boolean; // 4.5
    FMOverflow: Boolean; // 4.4, ���������� ������ �����������
    FM50Zreports: Boolean; // 4.3, � ���������� ������ ���� ����� �� ������� ���� ��� 50 Z-�������
    FMMissing: Boolean; // 4.2, ��� ������ ���������� ������
    FMWriteError: Boolean; // 4.0, �������� ������ ��� ������ � ���������� ������

    SerialNumber: Boolean; // 5.5, ���������� � ��������� ����� �����������������
    TaxRatesSet: Boolean; // 5.4, ��������� ������ ����������
    Fiscalized: Boolean; // 5.3, ���������� ���������������
    FMFormatted: Boolean; // 5.1, ���������� ������ ��������������
    FMReadOnly: Boolean; // 5.0, ���������� ������ ����������� � ����� Read Only.
  end;

const
  LF = #10;
  CRLF = #13#10;
  SErrorOK: WideString = '�������� ��������� �������';
  SInvalidParams: WideString = '�������� ��������� �������';
  SError1	= '���������� ������� COM ����';
  SError2	= '������ ��������� ������� COM �����';
  SError3	= '������ ��������� ����� COM �����';
  SError4	= '���������� �������� ��������� COM �����';
  SError5	= '�������� �������� ��� �����,  ����� ����������� 19200 ���';
  SError6	= '���������� ���������� �������� COM �����';
  SError7	= '������ ��������� ����� � ���������� �������������';
  SError8	= '����������� �������� �� ������ ���������� �����������';
  SError10: WideString = '���� � ����� �� �����������';
  SError11: WideString = '��������� ������� (������� ����������) �� ���������';
  SError12: WideString = '����������� ������� ��� ����������� �����';
  SError13: WideString = '������ ������������. ������� ��������� ������� ���������';
  SError14: WideString = '������ ������������. �� ����� ���������� �����';
  SError15: WideString = '������ ������������. ������� ��������� ����� ��� ������ ������';
  SError16: WideString = '������ ������������. ������ ���';
  SError17: WideString = '������ ������������. �� �������� ����� �� ����. �������� Z-�����';
  SError18: WideString = '������ ������������. �� ������ ��������� ������';
  SError19: WideString = '������ ������������. ��������� ����� ������� �� �����';
  SError20: WideString = '������ ������������. ����������� ������� ��� ����������� �����';
  SError21: WideString = '������ ������������. ���� � ����� �� �����������';
  SError22: WideString = '������ ��������� ���������� ������:' + LF +
    '��������������� ���������� ������' + LF +
    '��������� ����� ��� �����' + LF +
    '����/����� �� �����������';

  SError23	= '������ ��������� ����������� ������:' + LF +
    '��������� ����� �� �����' + LF +
    '����/����� �� �����������' + LF +
    '������ ���' + LF +
    '���������� ������� Z-�����';

  SError24: WideString = '������ ��������� ����������/������������������ ������';
  SError25: WideString = '������ �������� ������������� ����. ���������� ������ ���������������';
  SError26: WideString = '������ �������� ������������� ����. ������ ���������� ����';
  SError27: WideString = '������ �������� ������������� ����. ������������ ��� ��� ������';
  SError28: WideString = '������ �������� ������������� ����. ���� � ����� �� �����������';
  SError29: WideString = '������ ���������� ����� ����.';
  SError30: WideString = '������ ���������� ����� ����. ' + LF +
    '����������� ����� �������������.' + LF +
    '������ �� �����������';

  SError31: WideString = '����� ������ ������ ����� ���� (�������������� ���������)';
  SError32: WideString = '����� ������ ������ ����� ���� (�������������� ���������)';

  SError33: WideString = '������ ���������� ����� ����. ' + LF +
    '����� �� ��������� ��������� ������ ������������.';

  SError34: WideString = '������ ����������������/������/�������� ��������.';
  SError35: WideString = '������ ���������� �������� ���������� �����/������.';
  SError36: WideString = '�������������� ������ � �������';
  SError37: WideString = '��� ���������� ������� �������.';
  SError38: WideString = '�������� ����������� ���������� ����������.';
  SError39: WideString = '������������ �������� ������������.';
  SError40: WideString = '������� �� ��������� ��� �������� ����������� ������ ��������.';

  SError100: WideString = '���������� ����������� �� ��������.';

  SInvalidCrc: WideString = '�������� CRC';
  SNoHardware: WideString = '��� ����� � ��';
  SMaxSynCount: WideString = '���������� ������';
  SEmptyData: WideString = '������ ������ ��� ��������';
  SInvalidAnswerCode: WideString = '�������� ��� ������';
  SInvalidParamValue: WideString = '�������� �������� ��������� "%s"';
  SInvalidPasswordLength: WideString = '����� ������ ������ ���� ������ ��� ����� 4';
  SInvalidCodeValue: WideString = '�������� �������� ����';


const
  CP_Ukrainian = 21866;

  /////////////////////////////////////////////////////////////////////////////
  // Error codes

  EInvalidParams        = -1;

  DATECS_E_FAILURE      = -2;
  DATECS_E_NOHARDWARE   = -3;
  DATECS_E_CRC          = -4;

  CmdSaveSettings     = #$29; // ������ ������� �������� � ����������������� ����-������
  CmdSetHeaderFooter  = #$2B; // ��������� HEADER � FOOTER � ���������� ������
  CmdSetDateTime      = #$3D; // ��������� ���� � �������
  CmdGetDateTime      = #$3E; // ���������� ���� � �����


function GetCommandName(Code: Integer): WideString;
function GetErrorText(Code: Integer): WideString;
function DecodeStatus(const Data: string; var Status: TDatecsStatus): Boolean;
function EncodeStatus(const Status: TDatecsStatus): string;


implementation

///////////////////////////////////////////////////////////////////////////////
// Comand codes
(*
  // �������������
  29H	(41)	������ ������� �������� � ����������������� ����-������.
  2BH	(43)	��������� HEADER � FOOTER � ���������� ������
  3DH	(61)	��������� ���� � �������
  48H	(72)	������������
  53H	(83)	��������� ���������� ����� � ��������� ������
  54H	(84)	��������� ������ ������ (�������� ���)
  57H	(87)	���������������� �������������� ����� ������
  5BH	(91)	���������������� ��������� ������ � ������ ������
  5CH	(92)	���������������� ������ ��������� ������.
  62H	(98)	��������� ���
  65H	(101)	������ ������ ���������
  66H	(102)	������ ����� ���������
  68H	(104)	����� ������ ���������
  6BH	(107)	����������� � ����� �� �������
  73H	(115)	�������� ������������ ��������
  76H	(118)	������ ������ ��������������
  77H	(119)	����� ������ ���������

  // �������
  26H	(38)	������� ������������ ���
  27H	(39)	������� ������������ ���
  2AH	(42)	������ ������������� ���������� ������
��30H (48) ������� ���������� ���
��33H (51) ����� (������ � ��������)
��34H (52) ����������� �����-������� � �������
��35H (53) ������ ����� (������)
��36H (54) ������ ����������� ���������� ������
��37H (55) ������ ����� (������) � �������� ����
��38H (56) �������� ��������� ����.
��39H (57) ������ ��� ��������� ����������� ����
��3AH (58) ����������� ������� ������
��3BH (59) ������ / �������� ��� ����� �� �������� ������
  55H	(85)	�������� ���� ��������
  58H	(88)	������ ���������
  5DH	(93)	������ ������������� �����
  6DH	(109)	����� ����� ����

  ����� ���
  45H	(69) 	���������� ���������� ����� (� �������� ��� ���)

  ������
  32H	(50)	����� �� ���������� � ��������� ������� � ���������� ����� � ��������������� �������
  49H	(73)	��������� ����� �� ���������� ������ (�� ������� ����)
  5EH	(94)	��������� ����� �� ���������� ������ (�� �����)
  4FH	(79)	����������� ����� �� ���������� ������ (�� �����)
  5FH	(95)	����������� ����� �� ���������� ������ (�� ������� ����)
  69H	(105)	����� �� ����������
  6FH	(111)	����� �� �������

  ����������
  2�H	(46)	�������� ����������������� ������� �����
  3�H	(62)	���������� ���� � �����
  40H	(64)	���������� ��������� ���������� ������
  41H	(65)	���������� ����������� ���� �� ����
  43H	(67)	���������� � ����������� ����� �������������
  44H	(68)	���������� ��������� ������� � ���������� ������
  4AH	(74) 	�������� ���� ���������
  4CH	(76)	��������� ��������� ��������
  56H	(86)	�������� ���� ��������� ���������� ������
  5AH	(90)	��������� ��������������� ����������
  61H	(97)	��������� ��������� ������
  63H	(99)	��������� ���������� ������
  67H	(103)	���������� � ������� ����
  6EH	(110)	��������� ���������� � ������ ������ �� �����
  70H	(112)	��������� ���������� � ���������
  71H	(113)	��������� ������ ���������� �������������� ���������
  72H	(114)	��������� ���������� � ���������� ������� �� ������

  ������� ������
  2CH	(44)	�������� ������
  2DH	(45)	������� ������

  �������
  21H	(33)	�������� �������
  23H	(35)	������� ����� (������ ���)
  2FH	(47)	������� ����� (������� ���)
  3FH	(63)	�������� ���� � �����
  64H	(100)	������� - ����������

  ������ �������
  46H	(70)	�������� � ������� �������� �������.
  47H	(71)	������ ��������������� ����������
  50H	(80)	�������� ������
  59H	(89)	���������������� ���������������� ������� �����
  6AH	(106)	������� ����

  ��������� (����� ���������� ���������)
  80H	(128)	��������� ��������� RAM
  81H	(130)	��������� �������� ��������� ������
  83H	(131)	��������� �������������� ��������� ������
  84H	(132)	������ ���� �������� (������ ��������)
  85H	(133)	��������� ������ ������
��86H (134) ���������� ������ � ������������ ����������� ������.
��87H (135) ��������� ������ � ���������� ������
*)

const
  SCommand_29H: WideString = '������ ������� �������� � ����������������� ����-������';
  SCommand_2BH: WideString = '��������� HEADER � FOOTER � ���������� ������';
  SCommand_3DH: WideString = '��������� ���� � �������';
  SCommand_48H: WideString = '������������';
  SCommand_53H: WideString = '��������� ���������� ����� � ��������� ������';
  SCommand_54H: WideString = '��������� ������ ������ (�������� ���)';
  SCommand_57H: WideString = '���������������� �������������� ����� ������';
  SCommand_5BH: WideString = '���������������� ��������� ������ � ������ ������';
  SCommand_5CH: WideString = '���������������� ������ ��������� ������.';
  SCommand_62H: WideString = '��������� ���';
  SCommand_65H: WideString = '������ ������ ���������';
  SCommand_66H: WideString = '������ ����� ���������';
  SCommand_68H: WideString = '����� ������ ���������';
  SCommand_6BH: WideString = '����������� � ����� �� �������';
  SCommand_73H: WideString = '�������� ������������ ��������';
  SCommand_76H: WideString = '������ ������ ��������������';
  SCommand_77H: WideString = '����� ������ ���������';
  SCommand_26H: WideString = '������� ������������ ���';
  SCommand_27H: WideString = '������� ������������ ���';
  SCommand_2AH: WideString = '������ ������������� ���������� ������';
  SCommand_30H: WideString = '������� ���������� ���';
  SCommand_33H: WideString = '����� (������ � ��������)';
  SCommand_34H: WideString = '����������� �����-������� � �������';
  SCommand_35H: WideString = '������ ����� (������)';
  SCommand_36H: WideString = '������ ����������� ���������� ������';
  SCommand_37H: WideString = '� �������� ����';
  SCommand_38H: WideString = '�������� ��������� ����.';
  SCommand_39H: WideString = '������ ��� ��������� ����������� ����';
  SCommand_3AH: WideString = '����������� ������� ������';
  SCommand_3BH: WideString = '������ / �������� ��� ����� �� �������� ������';
  SCommand_55H: WideString = '�������� ���� ��������';
  SCommand_58H: WideString = '������ ���������';
  SCommand_5DH: WideString = '������ ������������� �����';
  SCommand_6DH: WideString = '����� ����� ����';
  SCommand_45H: WideString = '���������� ���������� ����� (� �������� ��� ���)';
  SCommand_32H: WideString = '����� �� ���������� � ��������� ������� � ���������� ����� � ��������������� �������';
  SCommand_49H: WideString = '��������� ����� �� ���������� ������ (�� ������� ����)';
  SCommand_5EH: WideString = '��������� ����� �� ���������� ������ (�� �����)';
  SCommand_4FH: WideString = '����������� ����� �� ���������� ������ (�� �����)';
  SCommand_5FH: WideString = '����������� ����� �� ���������� ������ (�� ������� ����)';
  SCommand_69H: WideString = '����� �� ����������';
  SCommand_6FH: WideString = '����� �� �������';
  SCommand_2EH: WideString = '�������� ����������������� ������� �����';
  SCommand_3EH: WideString = '���������� ���� � �����';
  SCommand_40H: WideString = '���������� ��������� ���������� ������';
  SCommand_41H: WideString = '���������� ����������� ���� �� ����';
  SCommand_43H: WideString = '���������� � ����������� ����� �������������';
  SCommand_44H: WideString = '���������� ��������� ������� � ���������� ������';
  SCommand_4AH: WideString = '�������� ���� ���������';
  SCommand_4CH: WideString = '��������� ��������� ��������';
  SCommand_56H: WideString = '�������� ���� ��������� ���������� ������';
  SCommand_5AH: WideString = '��������� ��������������� ����������';
  SCommand_61H: WideString = '��������� ��������� ������';
  SCommand_63H: WideString = '��������� ���������� ������';
  SCommand_67H: WideString = '���������� � ������� ����';
  SCommand_6EH: WideString = '��������� ���������� � ������ ������ �� �����';
  SCommand_70H: WideString = '��������� ���������� � ���������';
  SCommand_71H: WideString = '��������� ������ ���������� �������������� ���������';
  SCommand_72H: WideString = '��������� ���������� � ���������� ������� �� ������';
  SCommand_2CH: WideString = '�������� ������';
  SCommand_2DH: WideString = '������� ������';
  SCommand_21H: WideString = '�������� �������';
  SCommand_23H: WideString = '������� ����� (������ ���)';
  SCommand_2FH: WideString = '������� ����� (������� ���)';
  SCommand_3FH: WideString = '�������� ���� � �����';
  SCommand_64H: WideString = '������� - ����������';
  SCommand_46H: WideString = '�������� � ������� �������� �������.';
  SCommand_47H: WideString = '������ ��������������� ����������';
  SCommand_50H: WideString = '�������� ������';
  SCommand_59H: WideString = '���������������� ���������������� ������� �����';
  SCommand_6AH: WideString = '������� ����';
  SCommand_7AH: WideString = '������ ��������� ������';
  SCommand_80H: WideString = '��������� ��������� RAM';
  SCommand_81H: WideString = '��������� �������� ��������� ������';
  SCommand_83H: WideString = '��������� �������������� ��������� ������';
  SCommand_84H: WideString = '������ ���� �������� (������ ��������)';
  SCommand_85H: WideString = '��������� ������ ������';
  SCommand_86H: WideString = '���������� ������ � ������������ ����������� ������.';
  SCommand_87H: WideString = '��������� ������ � ���������� ������';
  SCommand_Unknown: WideString = '����������� �������';

function GetCommandName(Code: Integer): WideString;
begin
  case Code of
    $29: Result := SCommand_29H;
    $2B: Result := SCommand_2BH;
    $3D: Result := SCommand_3DH;
    $48: Result := SCommand_48H;
    $53: Result := SCommand_53H;
    $54: Result := SCommand_54H;
    $57: Result := SCommand_57H;
    $5B: Result := SCommand_5BH;
    $5C: Result := SCommand_5CH;
    $62: Result := SCommand_62H;
    $65: Result := SCommand_65H;
    $66: Result := SCommand_66H;
    $68: Result := SCommand_68H;
    $6B: Result := SCommand_6BH;
    $73: Result := SCommand_73H;
    $76: Result := SCommand_76H;
    $77: Result := SCommand_77H;
    $26: Result := SCommand_26H;
    $27: Result := SCommand_27H;
    $2A: Result := SCommand_2AH;
    $30: Result := SCommand_30H;
    $33: Result := SCommand_33H;
    $34: Result := SCommand_34H;
    $35: Result := SCommand_35H;
    $36: Result := SCommand_36H;
    $37: Result := SCommand_37H;
    $38: Result := SCommand_38H;
    $39: Result := SCommand_39H;
    $3A: Result := SCommand_3AH;
    $3B: Result := SCommand_3BH;
    $55: Result := SCommand_55H;
    $58: Result := SCommand_58H;
    $5D: Result := SCommand_5DH;
    $6D: Result := SCommand_6DH;
    $45: Result := SCommand_45H;
    $32: Result := SCommand_32H;
    $49: Result := SCommand_49H;
    $5E: Result := SCommand_5EH;
    $4F: Result := SCommand_4FH;
    $5F: Result := SCommand_5FH;
    $69: Result := SCommand_69H;
    $6F: Result := SCommand_6FH;
    $2E: Result := SCommand_2EH;
    $3E: Result := SCommand_3EH;
    $40: Result := SCommand_40H;
    $41: Result := SCommand_41H;
    $43: Result := SCommand_43H;
    $44: Result := SCommand_44H;
    $4A: Result := SCommand_4AH;
    $4C: Result := SCommand_4CH;
    $56: Result := SCommand_56H;
    $5A: Result := SCommand_5AH;
    $61: Result := SCommand_61H;
    $63: Result := SCommand_63H;
    $67: Result := SCommand_67H;
    $6E: Result := SCommand_6EH;
    $70: Result := SCommand_70H;
    $71: Result := SCommand_71H;
    $72: Result := SCommand_72H;
    $2C: Result := SCommand_2CH;
    $2D: Result := SCommand_2DH;
    $21: Result := SCommand_21H;
    $23: Result := SCommand_23H;
    $2F: Result := SCommand_2FH;
    $3F: Result := SCommand_3FH;
    $64: Result := SCommand_64H;
    $46: Result := SCommand_46H;
    $47: Result := SCommand_47H;
    $50: Result := SCommand_50H;
    $59: Result := SCommand_59H;
    $6A: Result := SCommand_6AH;
    $7A: Result := SCommand_7AH;
    $80: Result := SCommand_80H;
    $81: Result := SCommand_81H;
    $83: Result := SCommand_83H;
    $84: Result := SCommand_84H;
    $85: Result := SCommand_85H;
    $86: Result := SCommand_86H;
    $87: Result := SCommand_87H;
  else
    Result := SCommand_Unknown;
  end;
end;

function GetErrorText(Code: Integer): WideString;
begin
  case Code of
    0: Result := SErrorOK;
    -1: Result := SInvalidParams;
    1: Result := SError1;
    2: Result := SError2;
    3: Result := SError3;
    4: Result := SError4;
    5: Result := SError5;
    6: Result := SError6;
    7: Result := SError7;
    8: Result := SError8;
    10: Result := SError10;
    11: Result := SError11;
    12: Result := SError12;
    13: Result := SError13;
    14: Result := SError14;
    15: Result := SError15;
    16: Result := SError16;
    17: Result := SError17;
    18: Result := SError18;
    19: Result := SError19;
    20: Result := SError20;
    21: Result := SError21;
    22: Result := SError22;
    23: Result := SError23;
    24: Result := SError24;
    25: Result := SError25;
    26: Result := SError26;
    27: Result := SError27;
    28: Result := SError28;
    29: Result := SError29;
    30: Result := SError30;
    31: Result := SError31;
    32: Result := SError32;
    33: Result := SError33;
    34: Result := SError34;
    35: Result := SError35;
    36: Result := SError36;
    37: Result := SError37;
    38: Result := SError38;
    39: Result := SError39;
    40: Result := SError40;
    100: Result := SError100;
  else
    Result := '';
  end;
end;

function DecodeStatus(const Data: string; var Status: TDatecsStatus): Boolean;
var
  i: Integer;
  B: array [0..5] of Byte;
begin
  Result := Length(Data) >= 6;
  if not Result then Exit;

  for i := 1 to 6 do
    B[i-1] := Ord(Data[i]);


  Status.Data := Data;
  Status.GeneralError := TestBit(B[0], 5);
  Status.PrinterError := TestBit(B[0], 4);
  Status.DisplayDisconnected := TestBit(B[0], 3);
  Status.ClockNotSet := TestBit(B[0], 2);
  Status.InvalidCommandCode := TestBit(B[0], 1);
  Status.InvalidDataSyntax := TestBit(B[0], 0);

  // Byte 1
  Status.WrongPassword := TestBit(B[1], 6);
  Status.CutterError := TestBit(B[1], 5);
  Status.MemoryCleared := TestBit(B[1], 2);
  Status.InvalidCommandInMode := TestBit(B[1], 1);
  Status.SumsOverflow := TestBit(B[1], 0);

  // Byte 2
  Status.NonfiscalRecOpened := TestBit(B[2], 5);
  Status.JournalPaperNearEnd := TestBit(B[2], 4);
  Status.FiscalRecOpened := TestBit(B[2], 3);
  Status.JournalPaperEmpty := TestBit(B[2], 2);
  Status.RecJrnPaperNearEnd := TestBit(B[2], 1);
  Status.RecJrnStationEmpty := TestBit(B[2], 0);

  Status.JrnSmallFont := TestBit(B[3], 6);
  Status.DisplayCP866 := TestBit(B[3], 5);
  Status.PrinterCP866 := TestBit(B[3], 4);
  Status.TransparentDisplay := TestBit(B[3], 3);
  Status.AutoCut := TestBit(B[3], 2);
  Status.BaudRate := B[3] and 3;

  Status.FMError := TestBit(B[4], 5);
  Status.FMOverflow := TestBit(B[4], 4);
  Status.FM50ZReports := TestBit(B[4], 3);
  Status.FMMissing := TestBit(B[4], 2);
  Status.FMWriteError := TestBit(B[4], 0);

  Status.SerialNumber := TestBit(B[5], 5);
  Status.TaxRatesSet := TestBit(B[5], 4);
  Status.Fiscalized := TestBit(B[5], 3);
  Status.FMFormatted := TestBit(B[5], 1);
  Status.FMReadOnly := TestBit(B[5], 0);
end;

function EncodeStatus(const Status: TDatecsStatus): string;
begin

end;

end.
