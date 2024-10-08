unit DaisyPrinter;

interface

uses
  // VCL
  Windows, Classes, SysUtils, DateUtils, Registry, Graphics, Types, SyncObjs,
  // Tnt
  TntRegistry, TntClasses,
  // This
  PrinterPort, LogFile, DriverError, StringUtils, ByteUtils,
  DaisyPrinterInterface;

type
  { TDaisyFrame }

  TDaisyFrame = class
  public
    class function GetCrc(const Data: AnsiString): AnsiString;
    class function EncodeAnswer(const Data: TDaisyAnswer): AnsiString;
    class function EncodeCommand(const Data: TDaisyCommand): AnsiString;
    class function DecodeAnswer(const Data: AnsiString): TDaisyAnswer;
    class function DecodeCommand(const Data: AnsiString): TDaisyCommand;
    class function DecodeCommand2(const Data: AnsiString;
      var Command: TDaisyCommand): Boolean;
  end;

  { TDaisyPrinter }

  TDaisyPrinter = class(TInterfacedObject, IDaisyPrinter)
  private
    FTxData: AnsiString;
    FRxData: AnsiString;
    FLogger: ILogFile;
    FPort: IPrinterPort;
    FAnswer: TDaisyAnswer;
    FCommand: TDaisyCommand;
    FStatus: TDaisyStatus;
    FRegKeyName: WideString;
    FVATRates: TDFPVATRates;
    FConstants: TDFPConstants;
    FDiagnostic: TDFPDiagnosticInfo;
    FOnStatusUpdate: TNotifyEvent;
    FLastError: Integer;
    FCommandTimeout: Integer;
    FSeqNumber: Integer;

    function GetConstants: TDFPConstants;
    function GetDiagnostic: TDFPDiagnosticInfo;
    function GetLastError: Integer;
    function GetLogger: ILogFile;
    function GetOnStatusUpdate: TNotifyEvent;
    function GetPort: IPrinterPort;
    function GetRegKeyName: WideString;
    function GetStatus: TDaisyStatus;
    function GetVATRates: TDFPVATRates;
    procedure SetOnStatusUpdate(const Value: TNotifyEvent);
    procedure SetRegKeyName(const Value: WideString);
    function GetCommandTimeout: Integer;
    procedure SetCommandTimeout(const Value: Integer);
    function DoSend(const TxData: AnsiString;
      var RxData: AnsiString): Integer;
    procedure SetSeqNumber(const Value: Integer);
    function ValidSeqNumber(const Value: Integer): Boolean;
  public
    constructor Create(APort: IPrinterPort; ALogger: ILogFile);
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;
    procedure LoadParams;
    procedure SaveParams;
    function CheckStatus: Integer;
    function SaleCommand(Cmd: Char; const P: TDFPSale): Integer;
    function DecodePrinterText(const Text: AnsiString): WideString;
    function EncodePrinterText(const Text: WideString): AnsiString;
    procedure SendCommand(const Tx: AnsiString; var RxData: AnsiString);

    function Send(const TxData: AnsiString): Integer; overload;
    function Send(const TxData: AnsiString; var RxData: AnsiString): Integer; overload;

    procedure Check(Code: Integer);
    function Reset: Integer;
    function Connect: Integer;
    function Disconnect: Integer;
    function SearchDevice: Integer;

    function XReport(var R: TDFPReportAnswer): Integer;
    function ZReport(var R: TDFPReportAnswer): Integer;
    function ClearExternalDisplay: Integer;
    function FullCut: Integer;
    function PartialCut: Integer;
    function Succeeded(ResultCode: Integer): Boolean;
    function StartNonfiscalReceipt(var RecNumber: Integer): Integer;
    function EndNonfiscalReceipt(var RecNumber: Integer): Integer;
    function PrintNonfiscalText(const Text: WideString): Integer;
    function PrintNonfiscalLine(const Text: WideString): Integer;
    function PaperFeed(LineCount: Integer): Integer;
    function PaperCut(CutMode: Integer): Integer;
    function StartFiscalReceipt(const P: TDFPOperatorPassword; var R: TDFPRecNumber): Integer;
    function StartRefundReceipt(const P: TDFPOperatorPassword; var R: TDFPRecNumber): Integer;
    function Sale(const P: TDFPSale): Integer;
    function SaleAndDisplay(const P: TDFPSale): Integer;
    function ReadVATRatesOnDate(const P: TDFPDateRange; var R: TDFPVATRateResponse): Integer;

    function Subtotal(const P: TDFPSubtotal; var R: TDFPSubtotalResponse): Integer;
    function PrintTotal(const P: TDFPTotal; var R: TDFPTotalResponse): Integer;
    function PrintFiscalText(const Text: WideString): Integer;
    function EndFiscalReceipt(var R: TDFPRecNumber): Integer;
    function SaleByPLU(const P: TDFPPLU): Integer;
    function WriteDateTime(Date: TDateTime): Integer;
    function ReadDateTime(var Date: TDateTime): Integer;
    function DisplayDateTime: Integer;
    function FinalFiscalRecord(DataType: AnsiChar; var R: TDFPFiscalRecord): Integer;
    function ReadTotals(DataType: Integer; var R: TDFPTotals): Integer;
    function ReadFreeFiscalRecords(var R: TDFPFiscalrecords): Integer;
    function PrintDiagnosticInfo: Integer;
    function PrintReportByNumbers(StartNum, EndNum: Integer): Integer;
    function ReadStatus: Integer;
    function ReadDiagnosticInfo(CalcCRC: Boolean; var R: TDFPDiagnosticInfo): Integer;
    function CancelReceipt: Integer;
    function WritePrintOptions(const Options: TDFPPrintOptions): Integer;
    function ReadPrintOptions(var Options: TDFPPrintOptions): Integer;
    function WriteLogoEnabled(Value: Boolean): Integer;
    function ReadLogoEnabled(var Value: Boolean): Integer;
    function ReadCutMode(var Value: Integer): Integer;
    function WriteCutMode(Value: Integer): Integer;
    function WriteDetailedReceipt(Value: Boolean): Integer;
    function ReadDetailedReceipt(var Value: Boolean): Integer;
    function WriteText(N: Integer; const S: WideString): Integer;
    function ReadText(N: Integer; var S: WideString): Integer;
    function ReadParameter(N: Integer; var S: AnsiString): Integer;
    function WriteParameter(N: Integer; const S: AnsiString): Integer;
    function ReadIntParameter(N: Integer; var Value: Integer): Integer;
    function WriteIntParameter(N, Value: Integer): Integer;

    function ReadConstants(var R: TDFPConstants): Integer;
    function PrintVATRates: Integer;
    function PrintParameters: Integer;
    function ReadVATRates(var VATRates: TDFPVATRates): Integer;
    function WriteVATRates(const VATRates: TDFPVATRates): Integer;
    function LoadLogo(const Logo: TGraphic): Integer;
    function LoadLogoFile(const FileName: WideString): Integer;
    function PrintBarcode(const Data: AnsiString): Integer;
    function PrintBarcode2(const Barcode: TDFPBarcode): Integer;
    function PrintCash(const P: TDFPCashRequest; var R: TDFPCashResponse): Integer;
    function DuplicatePrint(Count,DocNo: Integer): Integer;
    function ReadOperator(N: Integer; var R: TDFPOperator): Integer;
    function WriteOperatorName(const P: TDFPOperatorName): Integer;
    function WritePrinterNumber(N: Integer): Integer;
    function ReadReceiptStatus(var R: TDFPReceiptStatus): Integer;
    function ReadDayStatus(var R: TDFPDayStatus): Integer;
    function ReadLastDocNo(var DocNo: Integer): Integer;
    function WriteFiscalNumber(const FiscalNumber: AnsiString): Integer;

    property Port: IPrinterPort read GetPort;
    property Logger: ILogFile read GetLogger;
    property Status: TDaisyStatus read GetStatus;
    property LastError: Integer read GetLastError;
    property VATRates: TDFPVATRates read GetVATRates;
    property Constants: TDFPConstants read GetConstants;
    property Diagnostic: TDFPDiagnosticInfo read GetDiagnostic;
    property SeqNumber: Integer read FSeqNumber write SetSeqNumber;
    property RegKeyName: WideString read GetRegKeyName write SetRegKeyName;
    property CommandTimeout: Integer read GetCommandTimeout write SetCommandTimeout;
    property OnStatusUpdate: TNotifyEvent read GetOnStatusUpdate write SetOnStatusUpdate;
  end;


function GetCommandName(Code: Integer): WideString;
function GetErrorText(Code: Integer): WideString;
function GetParameterName(Code: Integer): WideString;

implementation

function GetStrParam(const Data: AnsiString; N: Integer): AnsiString;
begin
  Result := GetString(Data, N, [',']);
end;

function GetIntParam(const Data: AnsiString; N: Integer): Int64;
begin
  Result := StrToInt64(GetStrParam(Data, N));
end;

function GetDblParam(const Data: AnsiString; N: Integer): Double;
begin
  Result := StrToDouble(GetString(Data, N, [',']));
end;

// D0-F0 -> 10D0-10F0
function GeorgianAnsiToWideString(const S: AnsiString): WideString;
var
  i: Integer;
  C: AnsiChar;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    C := S[i];
    if Ord(C) in [$D0..$F0] then
    begin
      Result := Result + WideChar(Ord(C) + $1000);
    end else
    begin
      Result := Result + C;
    end;
  end;
end;

// 10D0-10F0 -> D0-F0
function GeorgianWideStringToAnsi(const S: WideString): AnsiString;
var
  i: Integer;
  C: WideChar;
begin
  Result := '';
  for i := 1 to Length(S) do
  begin
    C := S[i];
    if (Ord(C) >= $10D0) and (Ord(C) <= $10F0) then
    begin
      Result := Result + AnsiChar(Ord(C) and $FF);
    end else
    begin
      Result := Result + C;
    end;
  end;
end;

function GetParameterName(Code: Integer): WideString;
begin
  case Code of
    1: Result := 'Decimal point';
    2: Result := 'Number of header lines';
    3: Result := 'Number of trailer lines';
    4: Result := 'Print options';
    5: Result := 'Detailed print';
    6: Result := 'Header type';
    7: Result := 'Trailer type';
    8: Result := 'Enable operations';
    9: Result := 'Authorization of payments';
    10: Result := 'Printer number';
    11: Result := 'Daily report type';
    12: Result := 'Print all';
    13: Result := 'Daily report clear';
    14: Result := 'System font';
    15: Result := 'Print advertising logo';
    16: Result := 'Amount of currency';
    17: Result := 'Feed lines';
    18: Result := 'Print contrast';
    19: Result := 'Display rows';
    20: Result := 'Display chars';
    21: Result := 'Display BaudRate';
    22: Result := 'Sales display';
    23: Result := 'Autocut';
    24: Result := 'Print errors';
  else
    Result := 'Unknown parameter';
  end;
end;

function StrToBool(const Value: AnsiString): Boolean;
begin
  Result := Value <> '0';
end;

function GetErrorText(Code: Integer): WideString;
begin
  case Code of
    0: Result := 'No errors';
    1: Result := 'This operation will lead to overflow';
    2: Result := 'Incorrect tax link';
    3: Result := 'You are not authorized to do more transactions in this receipt';
    4: Result := 'You are not authorized to make more payments in this receipt';
    5: Result := 'Try to make sale registration with zero amount';
    6: Result := 'Attempt to a sale registration after a payment has been started';
    7: Result := 'You are not authorized for chosen operation';
    8: Result := 'Tax Link Disabled';
    9: Result := 'Invoice No unlimited';
    10: Result := 'Wrong Date/Time';
    11: Result := 'More than one decimal point has been entered';
    12: Result := 'Too many plus/minus';
    13: Result := 'Plus/Minus incorrect position';
    14: Result := 'Incorrect symbol in command';
    15: Result := 'Too many symbols after the decimal point than acceptable';
    16: Result := 'Too many symbol have been entered than acceptable';
    19: Result := 'Try to exit sale register mode, when fiscal receipt is opened, but there is no payment';
    20: Result := 'In this case, you have pressed the wrong key';
    21: Result := 'The id is out of the acceptable range';
    22: Result := 'Operation discount or charge is forbidden';
    23: Result := 'Operation VOID is impossible';
    24: Result := 'Attempt  to make deep void to non-existing transaction. ';
    25: Result := 'Attempt to make payment before receipt is opened';
    26: Result := 'Attempt to sale a PLU with a quantity bigger than its stock';
    27: Result := 'Incorrect communication between ECR and electronic scales';
    29: Result := 'Empty Name';
    30: Result := 'Fiscal memory is full';
    31: Result := 'Fiscal memory is almost full';
    41: Result := 'Incorrect barcode (wrong control sum)';
    42: Result := 'Attempt to make a sale registration or report with zero barcode';
    43: Result := 'Attempt to program PLU with a weight type barcode';
    44: Result := 'Attempt to sale or report with a non-programmed barcode';
    45: Result := 'Attempt to program an already existing barcode")';
    46: Result := 'Weight barcode total';
    47: Result := 'Same name';
    50: Result := 'Not found';
    51: Result := 'SHA1 incorrect string';
    52: Result := 'Currency name not programmed';
    53: Result := 'Header not programmed';
    54: Result := 'Tax rates not programmed';
    55: Result := 'Chip not exists';
    60: Result := 'SD Card not empty';
    61: Result := 'Incorrect SD Card';
    62: Result := 'SD Card - File not found';
    63: Result := 'SD Card - Cannot open file';
    64: Result := 'SD Card - Not Rewrite';
    65: Result := 'SD Card - Write Error';
    66: Result := 'Incorrect Password';
    68: Result := 'Certificate not entered';
    70: Result := 'Fiscal memory does not exist';
    71: Result := 'Incorrect data in FM';
    72: Result := 'Error in FM record';
    73: Result := 'Error FM size';
    74: Result := 'FM size changed';
    75: Result := '';
    76: Result := 'Need server info';
    78: Result := 'End command received';
    79: Result := 'Daily report same date';
    80: Result := 'Overflow min';
    81: Result := 'The daily financial report is overflowed';
    82: Result := 'More than 24 hours from first receipt without issuing daily Z report';
    83: Result := 'The report by operators is overflowed';
    84: Result := 'The report by PLUs is overflowed';
    85: Result := 'Periodic report overflow';
    86: Result := 'Current date is greater than service one';
    88: Result := 'The EJT is overflowed';
    89: Result := 'Overflow Max';
    90: Result := 'Periodic Z-Report needed';
    91: Result := 'Have to issue daily Z report before executing the requested operation';
    92: Result := 'Have to issue Z report by operators before executing the requested operation';
    93: Result := 'Have to issue Z report by PLU/articles before executing the requested operation';
    95: Result := 'Have to issue Z report by category before executing the requested operation';
    96: Result := 'EJT not empty';
    97: Result := 'It is forbidden to change the id of this field';
    98: Result := 'SAM not active';
    99: Result := 'SAM different';
    100: Result := 'SAM not exist';
    101: Result := 'Terminal Not Enough Space';
    102: Result := 'Terminal Timeout';
    103: Result := 'Terminal Different';
    104: Result := 'Terminal Wrong Answer';
    107: Result := 'Terminal SIM Card Locked';
    108: Result := 'Incorrect Password';
    109: Result := 'Have to issue manual transfer before executing the requested operation';
    110: Result := 'Terminal SIM Card Different';
    111: Result := 'Terminal Server Communication';
    112: Result := 'Terminal Server No Permit';
    113: Result := 'Terminal Server Incorrect Data';
    114: Result := 'FTP File Exist';
    115: Result := 'NEXUS Need';
    116: Result := 'Terminal Is Not Empty';
    117: Result := 'Terminal Operator ID Communication';
    118: Result := 'Operation Forbidden';
    120: Result := 'Value Not Entered';
    121: Result := 'Incorrect FTP Settings';
    122: Result := 'GTAPP Get Near';
    123: Result := 'SD Card Wrong';
    124: Result := 'SD Card Changed';
    125: Result := 'SD Card Not Exist';
    126: Result := 'SD Card Full';
    127: Result := 'SD Card Empty';
    // Driver errors
    200: Result := 'Date and time not set';
    201: Result := 'Customer display not connected';
    202: Result := 'Invalid command code';
    203: Result := 'Printer error';
    204: Result := 'Totalizer overflow';
    205: Result := 'Command is invalid in this mode';
    206: Result := 'Receipt or journal station empty';
    207: Result := 'Invalid data syntax';
    208: Result := 'Wrong password';
    209: Result := 'Cutter error';
    210: Result := 'Memory cleared';
    211: Result := 'Document print not allowed';
    212: Result := 'Invalid answer length';
    213: result := 'Command failed';
  else
    Result := 'Unknown error';
  end;
  Result := Format('%d, %s', [Code, Result]);
end;

///////////////////////////////////////////////////////////////////////////////
//** You cannot continue working. Contact a service technician immediately
//*** In order to continue working, you must turn off and on again the FPr
//**** Contact a service specialist.
///////////////////////////////////////////////////////////////////////////////

function IsServiceError(Code: Integer): Boolean;
begin
  Result := Code in [71, 72];
end;

function GetCommandName(Code: Integer): WideString;
begin
  case Code of
    // INITIAL SETTINGS
    $3D: Result := 'Set date and time';
    $2B: Result := 'Header and print options';
    $60: Result := 'Write tax rates';
    $65: Result := 'Operator password';
    $66: Result := 'Operator name';
    $96: Result := 'Set System parameters';
    $83: Result := 'Program departments';
    $73: Result := 'Write logo';
    $95: Result := 'Set text field';
    $97: Result := 'Set payments';
    $5B: Result := 'Set MRC';
    $62: Result := 'Set TIN';
    $48: Result := 'Fiscalization';
    $E5: Result := 'Restore default passwords';
    // SALES
    $26: Result := 'Start nonfiscal receipt';
    $2A: Result := 'Print of non-fiscal text';
    $27: Result := 'End nonfiscal receipt';
    $30: Result := 'Start fiscal receipt';
    $3A: Result := 'Sale by PLU';
    $33: Result := 'SubTotal sum';
    $35: Result := 'Total sum';
    $36: Result := 'Print of fiscal text';
    $82: Result := 'Cancel receipt';
    $39: Result := 'Print information for the client';
    $54: Result := 'Print barcode';
    $38: Result := 'End fiscal receipt';
    $6D: Result := 'Duplicate print';
    // REPORTS
    $6F: Result := 'Reports by PLUs';
    $69: Result := 'Reports by operators';
    $32: Result := 'Get tax rates';
    $49: Result := 'Report from FM by number';
    $4F: Result := 'Short FM report by dates';
    $5E: Result := 'FM report by dates';
    $5F: Result := 'Short FM report by number';
    $A5: Result := 'Report by departments';
    $A6: Result := 'Print system parameters';
    $99: Result := 'Send reports in text type';
    $B0: Result := 'Print current tax rates';
    // BALANCE AT THE END OF THE DAY
    $45: Result := 'Daily financial report';
    $6C: Result := 'Detailed daily financial report';
    $68: Result := 'Reset sales by operators';
    // INFORMATION
    $3E: Result := 'Date and time information';
    $4A: Result := 'Read status';
    $41: Result := 'Current net / total sums';
    $40: Result := 'Final fiscal record';
    $44: Result := 'Free fiscal records';
    $4C: Result := 'Status of fiscal receipt';
    $5A: Result := 'Diagnostic information';
    $61: Result := 'Current tax rates';
    $63: Result := 'Information for TIN';
    $6B: Result := 'Information for PLU';
    $67: Result := 'Information for the receipt';
    $6E: Result := 'Information for the day';
    $70: Result := 'Information for operator';
    $71: Result := 'Number of last documents';
    $72: Result := 'Information from FM by number';
    $92: Result := 'Information from FM by date';
    $80: Result := 'Receiving constant values';
    $47: Result := 'Print diagnostic information';
    $B1: Result := 'Read EJT';
    // PRINTER
    $2C: Result := 'Paper feed';
    $2D: Result := 'Paper cut';
    // OTHER
    $46: Result := 'Service issued sums';
    $6A: Result := 'Open till';
    $3F: Result := 'Display date and time';
  else
    Result := 'Unknown command';
  end;
end;


function CanRepeatCommand(Code: Integer): Boolean;
begin
  Result := False;
  case Code of
    $3D, // Set date and time
    $2B, // Header and print options
    $60, // Write tax rates
    $65, // Operator password
    $66, // Operator name
    $96, // Set System parameters
    $83, // Program departments
    $73, // Write logo
    $95, // Set text field
    $97, // Set payments
    $5B, // Set MRC
    $62, // Set TIN
    // INFORMATION
    $3E, // Date and time information
    $4A, // Read status
    $41, // Current net / total sums
    $40, // Final fiscal record
    $44, // Free fiscal records
    $4C, // Status of fiscal receipt
    $5A, // Diagnostic information
    $61, // Current tax rates
    $63, // Information for TIN
    $6B, // Information for PLU
    $67, // Information for the receipt
    $6E, // Information for the day
    $70, // Information for operator
    $71, // Number of last documents
    $72, // Information from FM by number
    $92, // Information from FM by date
    $80, // Receiving constant values
    $47, // Print diagnostic information
    $B1: // Read EJT
      Result := True;
  end;
end;

function StrToDouble(const S: AnsiString): Double;
var
  Text: AnsiString;
  SaveDecimalSeparator: Char;
begin
  SaveDecimalSeparator := DecimalSeparator;
  try
    DecimalSeparator := '.';
    Text := StringReplace(S, ',', '.', []);
    Result := StrToFloat(Text);
  finally
    DecimalSeparator := SaveDecimalSeparator;
  end;
end;

function AmountToStr(Value: Double): string;
var
  DS: Char;
begin
  DS := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%.2f', [Round(Value*100)/100]);
  DecimalSeparator := DS;
end;

function DoubleToStr(Value: Double): string;
var
  DS: Char;
begin
  DS := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%.2f', [Value]);
  DecimalSeparator := DS;
end;

function QuantityToStr(Value: Double): string;
var
  DS: Char;
begin
  DS := DecimalSeparator;
  DecimalSeparator := '.';
  Result := Format('%.3f', [Round(Value*1000)/1000]);
  DecimalSeparator := DS;
end;

function DecodeStatus(const Data: string; var Status: TDaisyStatus): Boolean;
var
  i: Integer;
  B: array [0..5] of Byte;
begin
  Result := Length(Data) >= 6;
  if not Result then Exit;

  for i := 1 to 6 do
    B[i-1] := Ord(Data[i]);

  Status.Data := Data;
  // Byte 0
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
  Status.DocPrintAllowed := TestBit(B[2], 6);
  Status.NonfiscalOpened := TestBit(B[2], 5);
  Status.JrnNearEnd := TestBit(B[2], 4);
  Status.FiscalOpened := TestBit(B[2], 3);
  Status.JrnEmpty := TestBit(B[2], 2);
  Status.RecJrnNearEnd := TestBit(B[2], 1);
  Status.RecJrnEmpty := TestBit(B[2], 0);

  // Byte 3
  Status.FDError := Ord(B[3]) and $7F;

  // Byte 4
  Status.FMError := TestBit(B[4], 5);
  Status.FMOverflow := TestBit(B[4], 4);
  Status.FMLess50ZReports := TestBit(B[4], 3);
  Status.FMInvalidRecord := TestBit(B[4], 2);
  Status.FMWriteError := TestBit(B[4], 0);

  // Byte 5
  Status.SerialNumber := TestBit(B[5], 5);
  Status.VATRatesSet := TestBit(B[5], 4);
  Status.Fiscalized := TestBit(B[5], 3);
  Status.FMFormatted := TestBit(B[5], 1);
  Status.FMReadOnly := TestBit(B[5], 0);
end;

// DDMMYY
function FDDateToStr(const Date: TDateTime): AnsiString;
begin
  Result := FormatDateTime('ddmmyy', Date);
end;

// DDMMYY
function StrToFDDate(const S: string): TDateTime;
var
  Year, Month, Day: Word;
begin
  Day := StrToInt(Copy(S, 1, 2));
  Month := StrToInt(Copy(S, 3, 2));
  Year := StrToInt(Copy(S, 5, 2));
  Result := EncodeDate(Year, Month, Day);
end;

function DataTypeToChar(DataType: Integer): AnsiChar;
begin
  case DataType of
    DFP_DT_TOTAL: Result := 'T';
    DFP_DT_NET: Result := 'N';
  else
    raise Exception.CreateFmt('Invalid data type value, %d', [DataType]);
  end;
end;

resourcestring
  SInvalidPreambule = 'Invalid preambule code';

// 	<01><LEN><SEQ><CMD><DATA><05><BCC><03>
//	<01><LEN><SEQ><CMD><DATA><04><STATUS><05><BCC><03>

{ TDaisyFrame }

class function TDaisyFrame.GetCrc(const Data: AnsiString): AnsiString;
var
  i: Integer;
  Crc: Integer;
begin
  Crc := 0;
  for i := 1 to Length(Data) do
    Crc := Crc + Ord(Data[i]);
  Result := IntToHex(Crc, 4);
  for i := 1 to 4 do
    Result[i] := Chr(StrToInt('$' + Result[i]) + $30);
end;


//	<01><LEN><SEQ><CMD><DATA><04><STATUS><05><BCC><03>

class function TDaisyFrame.EncodeAnswer(
  const Data: TDaisyAnswer): AnsiString;
begin
  Result :=
    Chr(Length(Data.Data) + $2B) +
    Chr(Data.Sequence) +
    Chr(Data.Code) +
    Data.Data + #04 +
    Data.Status + #05;

  Result := #01 + Result + GetCrc(Result) + #03;
end;

class function TDaisyFrame.DecodeAnswer(
  const Data: AnsiString): TDaisyAnswer;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  if Data[1] <> #01 then
    raise Exception.Create(SInvalidPreambule);

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then
    RaiseError(DFP_E_CRC, SInvalidCrc);


  Len := Ord(Data[2]) - $2B;
  Result.Sequence := Ord(Data[3]);
  Result.Code := Ord(Data[4]);
  Result.Data := Copy(Data, 5, Len);
  Result.Status := Copy(Data, Len + 6, 6);
end;

// 	<01><LEN><SEQ><CMD><DATA><05><BCC><03>

class function TDaisyFrame.EncodeCommand(
  const Data: TDaisyCommand): AnsiString;
begin
  Result :=
    Chr(Length(Data.Data) + $24) +
    Chr(Data.Sequence) +
    Chr(Data.Code) +
    Data.Data + #05;

  Result := #01 + Result + GetCrc(Result) + #03;
end;

class function TDaisyFrame.DecodeCommand(
  const Data: AnsiString): TDaisyCommand;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  if Data[1] <> #01 then
    raise Exception.Create(SInvalidPreambule);

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then
    RaiseError(DFP_E_CRC, SInvalidCrc);


  Len := Ord(Data[2]) - $24;
  Result.Sequence := Ord(Data[3]);
  Result.Code := Ord(Data[4]);
  Result.Data := Copy(Data, 5, Len);
end;

class function TDaisyFrame.DecodeCommand2(
  const Data: AnsiString;
  var Command: TDaisyCommand): Boolean;
var
  Len: Integer;
  FrameCrc: AnsiString;
  FrameData: AnsiString;
begin
  Result := False;
  if Data[1] <> #01 then Exit;

  FrameData := Copy(Data, 2, Length(Data)-6);
  FrameCrc := Copy(Data, Length(Data)-4, 4);
  if GetCrc(FrameData) <> FrameCrc then Exit;

  Len := Ord(Data[2]) - $24;
  Command.Sequence := Ord(Data[3]);
  Command.Code := Ord(Data[4]);
  Command.Data := Copy(Data, 5, Len);
  Result := True;
end;

{ TDaisyPrinter }

constructor TDaisyPrinter.Create(APort: IPrinterPort; ALogger: ILogFile);
begin
  inherited Create;
  FPort := APort;
  FLogger := ALogger;
  FRegKeyName := 'SHTRIH-M\OposDaisy';
  FCommandTimeout := 30;
  SeqNumber := $20;
end;

destructor TDaisyPrinter.Destroy;
begin
  FPort := nil;
  FLogger := nil;
  inherited Destroy;
end;

function TDaisyPrinter.ValidSeqNumber(const Value: Integer): Boolean;
begin
  Result := Value in [$20..$FF];
end;

procedure TDaisyPrinter.SetSeqNumber(const Value: Integer);
begin
  if ValidSeqNumber(Value) then
    FSeqNumber := Value;
end;

function TDaisyPrinter.GetCommandTimeout: Integer;
begin
  Result := FCommandTimeout;
end;

procedure TDaisyPrinter.SetCommandTimeout(const Value: Integer);
begin
  FCommandTimeout := Value;
end;

function TDaisyPrinter.GetConstants: TDFPConstants;
begin
  Result := FConstants;
end;

function TDaisyPrinter.GetDiagnostic: TDFPDiagnosticInfo;
begin
  Result := FDiagnostic;
end;

function TDaisyPrinter.GetLastError: Integer;
begin
  Result := FLastError;
end;

function TDaisyPrinter.GetLogger: ILogFile;
begin
  Result := FLogger;
end;

function TDaisyPrinter.GetOnStatusUpdate: TNotifyEvent;
begin
  Result := FOnStatusUpdate;
end;

function TDaisyPrinter.GetPort: IPrinterPort;
begin
  Result := FPort;
end;

function TDaisyPrinter.GetRegKeyName: WideString;
begin
  Result := FRegKeyName;
end;

function TDaisyPrinter.GetStatus: TDaisyStatus;
begin
  Result := FStatus;
end;

function TDaisyPrinter.GetVATRates: TDFPVATRates;
begin
  Result := FVATRates;
end;

procedure TDaisyPrinter.SetOnStatusUpdate(const Value: TNotifyEvent);
begin
  FOnStatusUpdate := Value;
end;

procedure TDaisyPrinter.SetRegKeyName(const Value: WideString);
begin
  FRegKeyName := Value;
end;

procedure TDaisyPrinter.Lock;
begin
  Port.Lock;
end;

procedure TDaisyPrinter.Unlock;
begin
  Port.Unlock;
end;

procedure TDaisyPrinter.SaveParams;
var
  Reg: TTntRegistry;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_ALL_ACCESS;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegKeyName, True) then
    begin
      Reg.WriteInteger('FrameNumber', SeqNumber);
    end else
    begin
      FLogger.Error('Registry key open error');
    end;
  except
    on E: Exception do
    begin
      FLogger.Error('Save params failed, ' + E.Message);
    end;
  end;
  Reg.Free;
end;

procedure TDaisyPrinter.LoadParams;
var
  Reg: TTntRegistry;
begin
  Reg := TTntRegistry.Create;
  try
    Reg.Access := KEY_READ;
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(RegKeyName, False) then
    begin
      SeqNumber := Reg.ReadInteger('FrameNumber');
    end;
  except
    on E: Exception do
    begin
      FLogger.Error('Read params failed, ' + E.Message);
    end;
  end;
  Reg.Free;
end;

function TDaisyPrinter.Succeeded(ResultCode: Integer): Boolean;
begin
  Result := ResultCode = 0;
end;

function TDaisyPrinter.CheckStatus: Integer;
begin
  // Byte 0
  if Status.PrinterError then
  begin
    Result := EPrinterError;
    Exit;
  end;

  if Status.DisplayDisconnected then
  begin
    Result := EDisplayDisconnected;
    Exit;
  end;

  if Status.ClockNotSet then
  begin
    Result := EDateTimeNotSet;
    Exit;
  end;

  if Status.InvalidCommandCode then
  begin
    Result := EInvalidCommandCode;
    Exit;
  end;

  if Status.InvalidDataSyntax then
  begin
    Result := EInvalidDataSyntax;
    Exit;
  end;

  // Byte 1
  if Status.WrongPassword then
  begin
    Result := EWrongPassword;
    Exit;
  end;

  { !!! }
  if Status.CutterError then
  begin
    Result := ECutterError;
    Exit;
  end;

  if Status.MemoryCleared then
  begin
    Result := EMemoryCleared;
    Exit;
  end;

  if Status.InvalidCommandInMode then
  begin
    Result := EInvalidCommandInMode;
    Exit;
  end;

  if Status.SumsOverflow then
  begin
    Result := ESumsOverflow;
    Exit;
  end;
  // Byte 2
  (*
  if not Status.DocPrintAllowed then
  begin
    Result := EDocPrintAllowed;
    Exit;
  end;
  *)

  if Status.RecJrnEmpty then
  begin
    Result := ERecJrnEmpty;
    Exit;
  end;
  // Byte 3
  if Status.FDError <> 0 then
  begin
    Result := Status.FDError;
    Exit;
  end;

  Result := ENoError;
end;

function TDaisyPrinter.Send(const TxData: AnsiString): Integer;
var
  RxData: AnsiString;
begin
  Result := Send(TxData, RxData);
end;

function TDaisyPrinter.Send(const TxData: AnsiString; var RxData: AnsiString): Integer;
var
  i: Integer;
  CommandCode: Byte;
const
  MaxRepeatCount = 3;
begin
  Result := 0;
  CommandCode := Ord(TxData[1]);
  for i := 1 to MaxRepeatCount do
  begin
    try
      Result := DoSend(TxData, RxData);
      Break;
    except
      on E: Exception do
      begin
        if (not CanRepeatCommand(CommandCode)) or (i=MaxRepeatCount) then
          raise;
      end;
    end;
  end;
end;

function TDaisyPrinter.DoSend(const TxData: AnsiString; var RxData: AnsiString): Integer;
var
  TickCount: Integer;
  TimeText: AnsiString;
begin
  TickCount := GetTickCount;
  Logger.Debug(Logger.Separator);
  try
    SendCommand(TxData, RxData);
    FLastError := CheckStatus;
    Result := FLastError;
    if Assigned(FOnStatusUpdate) then
      FOnStatusUpdate(Self);

    TimeText := Format(' (time=%d ms)', [Integer(GetTickCount) - TickCount]);
    if Succeeded(Result) then
    begin
      Logger.Debug(GetErrorText(Result) + TimeText);
    end else
    begin
      Logger.Error(GetErrorText(Result) + TimeText);
    end;
  except
    on E: Exception do
    begin
      TimeText := Format(' (time=%d ms)', [Integer(GetTickCount) - TickCount]);
      Logger.Error(E.Message + TimeText);
      raise EConnectionError.Create(E.Message);
    end;
  end;
  Logger.Debug(Logger.Separator);
end;

function TDaisyPrinter.EncodePrinterText(const Text: WideString): AnsiString;
begin
  Result := GeorgianWideStringToAnsi(Text);
end;

function TDaisyPrinter.DecodePrinterText(const Text: AnsiString): WideString;
begin
  Result := GeorgianAnsiToWideString(Text);
end;

procedure TDaisyPrinter.SendCommand(const Tx: AnsiString; var RxData: AnsiString);
const
  STX = $01;
  SYN = $16;
  NAK = $15;
  MaxCommandCount = 3;
var
  B: Byte;
  S: string;
  i: Integer;
  TickCount: Integer;
begin
  Port.Lock;
  TickCount := GetTickCount;
  try
    if Length(Tx) = 0 then
      raise Exception.Create(SEmptyData);

    FCommand.Sequence := SeqNumber;
    FCommand.Code := Ord(Tx[1]);
    FCommand.Data := Copy(Tx, 2, Length(Tx));
    FTxData := TDaisyFrame.EncodeCommand(FCommand);

    S := Format('0x%.2x, %s', [FCommand.Code, GetCommandName(FCommand.Code)]);
    Logger.Debug(S);
    Logger.Debug('=> ' + Tx);

    for i := 1 to MaxCommandCount do
    begin
      Logger.WriteTxData(FTxData);

      Port.Write(FTxData);
      // 01
      B := 0;
      while True do
      begin
        B := Ord(Port.Read(1)[1]);
        Logger.Debug('<- ' + StrToHex(Chr(B)));
        case B of
          STX: Break;
          NAK:
          begin
            Break;
          end;
          SYN:
          begin
            if ((Integer(GetTickCount)-TickCount) > (CommandTimeout * 1000)) then
              RaiseError(DFP_E_NOHARDWARE, SMaxSynReached);

            Sleep(100);
            Continue;
          end;
        else
          // RaiseError(DFP_E_NOHARDWARE, SNoHardware); !!!
        end;
      end;
      if B = NAK then Continue;

      B := Ord(Port.Read(1)[1]);
      if not(B in [$20..$FF]) then
        RaiseError(DFP_E_NOHARDWARE, SInvalidLengthValue);

      FRxData := Port.Read(B - $20 + 4);
      Logger.WriteRxData(FRxData);
      FRxData := #$01 + Chr(B) + FRxData;
      FAnswer := TDaisyFrame.DecodeAnswer(FRxData);
      //FAnswer.Data := DecodePrinterText(FAnswer.Data);
      DecodeStatus(FAnswer.Status, FStatus);
      Logger.Debug('<= ' + FAnswer.Data);

      if FCommand.Sequence = FAnswer.Sequence then
      begin
        if FCommand.Code <> FAnswer.Code then
          raise Exception.Create(SInvalidAnswerCode);
        RxData := FAnswer.Data;
        Break;
      end;

      if i = MaxCommandCount then
        RaiseError(DFP_E_NOHARDWARE, SNoHardware);
    end;

    Inc(FSeqNumber);
    if not ValidSeqNumber(SeqNumber) then
    begin
      SeqNumber := $20;
    end;

    SaveParams;
  finally
    Port.Unlock;
  end;
end;

// <- 0000,000000000000,000000000000,000000000240,000000000000,000000000000,000000000000
function TDaisyPrinter.XReport(var R: TDFPReportAnswer): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.XReport');
  Result := Send(#$45'2', Answer);
  if Succeeded(Result) then
  begin
    R.ReportNumber := GetIntParam(Answer, 1);
    R.SalesTotalTaxFree := GetIntParam(Answer, 2);
    for i := 1 to 5 do
      R.SalesTotalTax[i] := GetIntParam(Answer, i+2);
  end;
end;

function TDaisyPrinter.ZReport(var R: TDFPReportAnswer): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ZReport');
  Result := Send(#$45'0', Answer);
  if Succeeded(Result) then
  begin
    R.ReportNumber := GetIntParam(Answer, 1);
    R.SalesTotalTaxFree := GetDblParam(Answer, 2);
    for i := 1 to 5 do
      R.SalesTotalTax[i] := GetDblParam(Answer, i+2);
  end;
end;

procedure TDaisyPrinter.Check(Code: Integer);
begin
  if Code <> 0 then
    RaiseError(Code, GetErrorText(Code));
end;

function TDaisyPrinter.ClearExternalDisplay: Integer;
begin
  Logger.Debug('TDaisyPrinter.ClearExternalDisplay');
  Result := Send(#$21);
end;

function TDaisyPrinter.StartNonfiscalReceipt(var RecNumber: Integer): Integer;
var
  Answer: AnsiString;
begin
  Result := Send(#$26, Answer);
  if Succeeded(Result) then
    RecNumber := GetIntParam(Answer, 1);
end;

function TDaisyPrinter.EndNonfiscalReceipt(var RecNumber: Integer): Integer;
var
  Answer: AnsiString;
begin
  Result := Send(#$27, Answer);
  if Succeeded(Result) then
    RecNumber := GetIntParam(Answer, 1);
end;

function TDaisyPrinter.PrintNonfiscalText(const Text: WideString): Integer;
var
  i: Integer;
  Lines: TTntStrings;
begin
  Result := 0;
  Lines := TTntStringList.Create;
  try
    Lines.Text := Text;
    for i := 0 to Lines.Count-1 do
    begin
      Result := PrintNonfiscalLine(Lines[i]);
      if Failed(Result) then Break;
    end;
  finally
    Lines.Free;
  end;
end;

function TDaisyPrinter.PrintNonfiscalLine(const Text: WideString): Integer;
begin
  Result := Send(#$2A + EncodePrinterText(Text));
end;

function TDaisyPrinter.PaperFeed(LineCount: Integer): Integer;
begin
  Result := Send(#$2C + IntToStr(LineCount));
end;

function TDaisyPrinter.PartialCut: Integer;
begin
  Logger.Debug('TDaisyPrinter.PartialCut');
  Result := PaperCut(DFP_CM_PARTIAL);
end;

function TDaisyPrinter.FullCut: Integer;
begin
  Logger.Debug('TDaisyPrinter.FullCut');
  Result := PaperCut(DFP_CM_FULL);
end;

function TDaisyPrinter.PaperCut(CutMode: Integer): Integer;
begin
  Result := Send(#$2D + IntToStr(CutMode));
end;

function TDaisyPrinter.StartFiscalReceipt(const P: TDFPOperatorPassword;
  var R: TDFPRecNumber): Integer;
var
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug(Format('TDaisyPrinter.StartFiscalReceipt(%d,%d)', [P.Number, P.Password]));
  Command := #$30 + Format('%d,%d', [P.Number, P.Password]);

  Result := Send(Command, Answer);
  if Succeeded(Result) then
  begin
    R.DocNumber := GetIntParam(Answer, 1);
    R.RecNumber := GetIntParam(Answer, 2);
  end;
end;

function TDaisyPrinter.StartRefundReceipt(const P: TDFPOperatorPassword;
  var R: TDFPRecNumber): Integer;
var
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug(Format('TDaisyPrinter.StartFiscalReceipt(%d,%d)', [P.Number, P.Password]));
  Command := #$30 + Format('%d,%d,1', [P.Number, P.Password]) + TAB + 'R0,34,23-08-24 15:05' + TAB + '123';

  Result := Send(Command, Answer);
  if Succeeded(Result) then
  begin
    R.DocNumber := GetIntParam(Answer, 1);
    R.RecNumber := GetIntParam(Answer, 2);
  end;
end;

function TDaisyPrinter.SaleCommand(Cmd: Char; const P: TDFPSale): Integer;
const
  TaxLetters = 'ABCD';
var
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.SaleCommand');
  if not(P.Tax in [1..4]) then
    raise Exception.CreateFmt('Invalid tax value, %d', [P.Tax]);

  Command := EncodePrinterText(P.Text1) + LF +
    EncodePrinterText(P.Text2) + TAB + TaxLetters[P.Tax] +
    AmountToStr(P.Price) + '*' + QuantityToStr(P.Quantity);

  if P.DiscountPercent <> 0 then
    Command := Command + Format(',%.2f', [P.DiscountPercent]);
  if P.DiscountAmount <> 0 then
    Command := Command + '$' + AmountToStr(P.DiscountAmount);

  Result := Send(Cmd + Command);
end;

function TDaisyPrinter.Sale(const P: TDFPSale): Integer;
begin
  Result := SaleCommand(#$31, P);
end;

function TDaisyPrinter.SaleAndDisplay(const P: TDFPSale): Integer;
begin
  Result := SaleCommand(#$34, P);
end;

function TDaisyPrinter.ReadVATRatesOnDate(const P: TDFPDateRange;
  var R: TDFPVATRateResponse): Integer;
var
  i: Integer;
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadVATRatesOnDate');
  Command := FDDateToStr(P.StartDate) + ',' +  FDDateToStr(P.EndDate);
  Result := Send(#$32 + Command, Answer);
  if Succeeded(Result) then
  begin
    R.DataFound := GetStrParam(Answer, 1) = 'P';
    for i := 1 to 5 do
      R.VATRate[i] := GetDblParam(Answer, i+1);
    R.Date := StrToFDDate(GetStrParam(Answer, 7));
  end;
end;

// <- 0000000114,0000000000,0000000114,0000000000,0000000000,0000000000
function TDaisyPrinter.Subtotal(const P: TDFPSubtotal;
  var R: TDFPSubtotalResponse): Integer;
var
  i: Integer;
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.Subtotal');
  Command := BoolToStr[P.PrintSubtotal] + BoolToStr[P.DisplaySubtotal];
  if P.AdjustmentPercent <> 0 then
    Command := Command + ',' + Format('%.2f', [P.AdjustmentPercent]);
  Result := Send(#$33 + Command, Answer);
  if Succeeded(Result) then
  begin
    R.SubTotal := GetIntParam(Answer, 1)/100;
    R.SalesTaxFree := GetIntParam(Answer, 2)/100;
    for i := 1 to 4 do
      R.TaxTotals[i] := GetIntParam(Answer,i+2)/100;
  end;

end;

function StrToPaidCode(C: AnsiChar): Integer;
begin
  case C of
    'F': Result := DFP_PC_ERROR;
    'I': Result := DFP_PC_VAT_NEGATIVE;
    'D': Result := DFP_PC_SUM_LESS_TOTAL;
    'R': Result := DFP_PC_SUM_GREATER_TOTAL;
    'E': Result := DFP_PC_NEGATIVE_SUBTOTAL;
  else
    raise Exception.CreateFmt('Unknown payment code, %s', [C]);
  end;
end;

function TDaisyPrinter.PrintTotal(const P: TDFPTotal; var R: TDFPTotalResponse): Integer;
const
  PaymentModeChar = 'PNCDE';
  PaymentModeChar2 = 'PNCUB';
var
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.PrintTotal');
  if not(P.PaymentMode in [DFP_PM_MIN..DFP_PM_MAX]) then
    raise Exception.CreateFmt('Invalid PaymentMode value, %d', [P.PaymentMode]);

  Command := #$35 + EncodePrinterText(P.Text1) + LF + EncodePrinterText(P.Text2) +
    TAB + PaymentModeChar[P.PaymentMode] + AmountToStr(P.Amount);
  Result := Send(Command, Answer);
  if Succeeded(Result) then
  begin
    if Answer = '' then
    begin
      Result := EInvalidAnswerLength;
      Exit;
    end;
    R.PaidCode := StrToPaidCode(Answer[1]);
    R.Amount := StrToDouble(Copy(Answer, 2, Length(Answer)));
  end;
end;

function TDaisyPrinter.PrintFiscalText(const Text: WideString): Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintFiscalText');
  Result := Send(#$36 + Text);
end;

function TDaisyPrinter.EndFiscalReceipt(var R: TDFPRecNumber): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.EndFiscalReceipt');
  Result := Send(#$38, Answer);
  if Succeeded(Result) then
  begin
    R.DocNumber := GetIntParam(Answer, 1);
    R.RecNumber := GetIntParam(Answer, 2);
  end;
end;

function TDaisyPrinter.SaleByPLU(const P: TDFPPLU): Integer;
var
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.SaleByPLU');
  Command := P.Sign + P.PLU + '*' + QuantityToStr(P.Quantity) + ',' +
    Format('%.2f', [P.DiscountPercent]) + '@' + AmountToStr(P.Price) + '$' +
    AmountToStr(P.DiscountAmount);
  Result := Send(#$3A + Command);
end;

function TDaisyPrinter.WriteDateTime(Date: TDateTime): Integer;
var
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.WriteDateTime');
  Command := FormatDateTime('dd-mm-yy hh:nn:ss', Date);
  Result := Send(#$3D + Command);
end;

function TDaisyPrinter.ReadDateTime(var Date: TDateTime): Integer;
var
  Answer: AnsiString;
  Year, Month, Day: Word;
  Hour, Min, Sec: Word;
begin
  Logger.Debug('TDaisyPrinter.ReadDateTime');
  Result := Send(#$3E, Answer);
  if Succeeded(Result) then
  begin
    if Length(Answer) < 17 then
     raise Exception.CreateFmt('Invalid date answer, %s', [Answer]);

    Day := StrToInt(Copy(Answer, 1, 2));
    Month := StrToInt(Copy(Answer, 4, 2));
    Year := 2000 + StrToInt(Copy(Answer, 7, 2));
    Hour := StrToInt(Copy(Answer, 10, 2));
    Min := StrToInt(Copy(Answer, 13, 2));
    Sec := StrToInt(Copy(Answer, 16, 2));
    Date := EncodeDate(Year, Month, Day) + EncodeTime(Hour, Min, Sec, 0);
  end;
end;

function TDaisyPrinter.DisplayDateTime: Integer;
begin
  Result := Send(#$3F);
end;

function TDaisyPrinter.FinalFiscalRecord(DataType: AnsiChar;
  var R: TDFPFiscalRecord): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.FinalFiscalRecord');
  Result := Send(#$40 + DataType, Answer);
  if Succeeded(Result) then
  begin
    R.Number := GetIntParam(Answer, 1);
    R.SalesTotalTaxFree := GetDblParam(Answer, 2);
    for i := 1 to 5 do
      R.SalesTotalTax[i] := GetDblParam(Answer, i+2);
    R.Date := StrToFDDate(GetStrParam(Answer, 8));
  end;
end;

function TDaisyPrinter.ReadTotals(DataType: Integer; var R: TDFPTotals): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadTotals');
  Result := Send(#$41 + DataTypeToChar(DataType), Answer);
  if Succeeded(Result) then
  begin
    R.SalesTotalTaxFree := GetDblParam(Answer, 1);
    for i := 1 to 5 do
      R.SalesTotalTax[i] := GetDblParam(Answer, i+1);
  end;
end;

function TDaisyPrinter.ReadFreeFiscalRecords(var R: TDFPFiscalrecords): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadFreeFiscalRecords');
  Result := Send(#$44, Answer);
  if Succeeded(Result) then
  begin
    R.LogicalNumber := GetIntParam(Answer, 1);
    R.PhysicalNumber := GetIntParam(Answer, 2);
  end;
end;

function TDaisyPrinter.PrintDiagnosticInfo: Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintDiagnosticInfo');
  Result := Send(#$47);
end;

function TDaisyPrinter.PrintReportByNumbers(StartNum, EndNum: Integer): Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintReportByNumbers');
  Result := Send(#$49  + IntToStr(StartNum) + ',' + IntToStr(EndNum));
end;

function TDaisyPrinter.ReadStatus: Integer;
begin
  Logger.Debug('TDaisyPrinter.ReadStatus');
  Result := Send(#$4A);
end;

function TDaisyPrinter.ReadDiagnosticInfo(CalcCRC: Boolean;
  var R: TDFPDiagnosticInfo): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadDiagnosticInfo');
  Result := Send(#$5A + BoolToStr[CalcCRC], Answer);
  if Succeeded(Result) then
  begin
    R.FirmwareVersion := GetString(Answer, 1, [' ', ',']);
    R.FirmwareDate := GetString(Answer, 2, [' ', ',']);
    R.FirmwareTime := GetString(Answer, 3, [' ', ',']);
    R.ChekSum := GetString(Answer, 4, [' ', ',']);
    R.Switches := GetInteger(Answer, 5, [' ', ',']);
    R.Country := GetInteger(Answer, 6, [' ', ',']);
    R.FDSerial := GetString(Answer, 7, [' ', ',']);
    R.FDNo := GetString(Answer, 8, [' ', ',']);
  end;
end;

function TDaisyPrinter.Reset: Integer;
var
  RecNumber: Integer;
begin
  Logger.Debug('TDaisyPrinter.Reset');
  Result := ReadStatus;
  if Succeeded(Result) then
  begin
    if Status.NonfiscalOpened then
    begin
      Result := EndNonfiscalReceipt(RecNumber);
    end;
    if Status.FiscalOpened then
    begin
      Result := CancelReceipt;
    end;
  end;
end;

function TDaisyPrinter.Connect: Integer;
begin
  Logger.Debug('TDaisyPrinter.Connect');
  Result := Reset;
  if Succeeded(Result) then
    Result := ReadConstants(FConstants);

  if Succeeded(Result) then
    Result := ReadVATRates(FVATRates);

  if Succeeded(Result) then
    Result := ReadDiagnosticInfo(False, FDiagnostic);

(*
  if Succeeded(Result) then
    Result := ReadParameters;
*)
end;

function TDaisyPrinter.Disconnect: Integer;
begin
  Logger.Debug('TDaisyPrinter.Disconnect');
  Result := 0;
end;

function TDaisyPrinter.CancelReceipt: Integer;
begin
  Logger.Debug('TDaisyPrinter.CancelReceipt');
  Result := Send(#$82);
end;

function TDaisyPrinter.WritePrintOptions(const Options: TDFPPrintOptions): Integer;
begin
  Logger.Debug('TDaisyPrinter.WritePrintOptions');
  Result := Send(#$2B + Format('P%s%s%s%s', [
    BoolToStr[Options.BlankLineAfterHeader],
    BoolToStr[Options.BlankLineAfterRegno],
    BoolToStr[Options.BlankLineAfterFooter],
    BoolToStr[Options.DelimiterLineBeforeTotal]]));
end;

function TDaisyPrinter.ReadPrintOptions(var Options: TDFPPrintOptions): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadPrintOptions');
  Result := Send(#$2B'IP', Answer);
  if Succeeded(Result) then
  begin
    Options.BlankLineAfterHeader := StrToBool(Answer[1]);
    Options.BlankLineAfterRegno := StrToBool(Answer[2]);
    Options.BlankLineAfterFooter := StrToBool(Answer[3]);
    Options.DelimiterLineBeforeTotal := StrToBool(Answer[4]);
  end;
end;

function TDaisyPrinter.WriteLogoEnabled(Value: Boolean): Integer;
begin
  Logger.Debug('TDaisyPrinter.WriteLogoEnabled');
  Result := Send(#$2B'L' + BoolToStr[Value]);
end;

function TDaisyPrinter.ReadLogoEnabled(var Value: Boolean): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadLogoEnabled');
  Result := Send(#$2B'IL', Answer);
  if Succeeded(Result) then
  begin
    Value := StrToBool(Answer);
  end;
end;

function TDaisyPrinter.WriteCutMode(Value: Integer): Integer;
begin
  Logger.Debug(Format('TDaisyPrinter.WriteCutMode(%d)', [Value]));
  Result := Send(#$2B'C' + IntToStr(Value));
end;

function TDaisyPrinter.ReadCutMode(var Value: Integer): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadCutMode');
  Result := Send(#$2B'IC', Answer);
  if Succeeded(Result) then
  begin
    Value := StrToInt(Answer);
  end;
end;

function TDaisyPrinter.WriteDetailedReceipt(Value: Boolean): Integer;
begin
  Logger.Debug(Format('TDaisyPrinter.WriteDetailedReceipt(%s)', [BoolToStr[Value]]));
  Result := Send(#$2B'A' + BoolToStr[Value]);
end;

function TDaisyPrinter.ReadDetailedReceipt(var Value: Boolean): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadDetailedReceipt');
  Result := Send(#$2B'IA', Answer);
  if Succeeded(Result) then
  begin
    Value := StrToBool(Answer);
  end;
end;

(*
40 to 53 � (Number � 40) � number of HEADER line/ FOOTER line
The text is limited to #CHARS_PER_LINE# symbols
60 to 64 � name of payment
The text is limited to #PAYNAME_LEN#symbols
600 to 610 � commentary lines
The text is limited to #COMMENT_LEN# symbols
*)

function TDaisyPrinter.WriteText(N: Integer; const S: WideString): Integer;
begin
  Logger.Debug('TDaisyPrinter.ReadText');
  Result := Send(#$95'P' + IntToStr(N) + ',' + EncodePrinterText(S));
end;

function TDaisyPrinter.ReadText(N: Integer; var S: WideString): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadText');
  Result := Send(#$95'R' + IntToStr(N), Answer);
  if Succeeded(Result) then
  begin
    S := DecodePrinterText(Answer);
  end;
end;

function TDaisyPrinter.ReadParameter(N: Integer; var S: AnsiString): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadParameter');
  Result := Send(#$96'R' + IntToStr(N), Answer);
  if Succeeded(Result) then
  begin
    S := GetStrParam(Answer, 2);
  end;
end;

function TDaisyPrinter.ReadIntParameter(N: Integer; var Value: Integer): Integer;
var
  S: AnsiString;
begin
  Result := ReadParameter(N, S);
  if Succeeded(Result) then
  begin
    Value := StrToInt(S);
  end;
end;

function TDaisyPrinter.WriteIntParameter(N, Value: Integer): Integer;
begin
  Result := WriteParameter(N, IntToStr(Value));
end;

function TDaisyPrinter.WriteParameter(N: Integer; const S: AnsiString): Integer;
begin
  Logger.Debug('TDaisyPrinter.WriteParameter');
  Result := Send(#$96 + Format('P%d,%s', [N, S]));
end;

(*
P1 Horizontal size of Graphical Logo in pixels.
P2 Vertical size of Graphical Logo in pixels..
P3 Number of payment types
P4 Number of tax group.
P5 Letter for non-taxable items (= 20h)
P6 It is not used for Georgia
P7 Symbol concerning first tax group
P8 Dimension of inner arithmetics
P9 Number of symbols per line..
P10 Number of symbols per comment line23
?11 Length of names (operators,PLUs,departments).
?12 Length (number of symbols)of the MRC of FD
?13 Length (number of symbols)of the Fiscal Memory Number
?15 Length (number of symbols)of REGNO
?16 Number of departments.
?17 Number of PLUs.
?18 Flag of stock field, described in PLU (0,1).
?19 Flag of barcode field,described in PLU (0,1).
?20 Number of stock groups.
?21 Number of operators..
?22 Length of the payment names
*)

function TDaisyPrinter.ReadConstants(var R: TDFPConstants): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadConstants');
  Result := Send(#$80, Answer);
  if Succeeded(Result) then
  begin
    R.MaxLogoWidth := GetIntParam(Answer, 1);
    R.MaxLogoHeight := GetIntParam(Answer, 2);
    R.NumPaymentTypes := GetIntParam(Answer, 3);
    R.NumVATRate := GetIntParam(Answer, 4);
    R.TaxFreeLetter := GetStrParam(Answer, 5);
    R.VATRate1Letter := GetStrParam(Answer, 7);
    R.Dimension := GetIntParam(Answer, 8);
    R.DescriptionLength := GetIntParam(Answer, 9);
    R.MessageLength := GetIntParam(Answer, 10);
    R.NameLength := GetIntParam(Answer, 11);
    R.MRCLength := GetIntParam(Answer, 12);
    R.FMNumberLength := GetIntParam(Answer, 13);
    R.REGNOLength := GetIntParam(Answer, 15);
    R.DepartmentsNumber := GetIntParam(Answer, 16);
    R.PLUNumber := GetIntParam(Answer, 17);
    R.NumberOfStockGroups := GetIntParam(Answer, 20);
    R.OperatorsNumber := GetIntParam(Answer, 21);
    R.PaymentNameLength := GetIntParam(Answer, 22);
  end;
end;

function TDaisyPrinter.PrintVATRates: Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintVATRates');
  Result := Send(#$B0);
end;

function TDaisyPrinter.PrintParameters: Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintParameters');
  Result := Send(#$A6);
end;

function TDaisyPrinter.ReadVATRates(var VATRates: TDFPVATRates): Integer;
var
  i: Integer;
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadVATRates');
  Result := Send(#$61, Answer);
  if Succeeded(Result) then
  begin
    for i := 1 to 5 do
    begin
      VATRates[i] := GetDblParam(Answer, i);
    end;
  end;
end;

function TDaisyPrinter.WriteVATRates(const VATRates: TDFPVATRates): Integer;
var
  i: Integer;
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.WriteVATRates');
  Command := '';
  for i := 1 to 5 do
  begin
    Command := Command + DoubleToStr(VATRates[i]);
    if i <> 5 then
      Command := Command + ',';
  end;
  Result := Send(#$60 + Command);
end;

function TDaisyPrinter.LoadLogoFile(const FileName: WideString): Integer;
var
  Picture: TPicture;
begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(FileName);
    Result := LoadLogo(Picture.Graphic);
  finally
    Picture.Free;
  end;
end;

function TDaisyPrinter.LoadLogo(const Logo: TGraphic): Integer;
var
  i, j: Integer;
  B: Byte;
  P: TPoint;
  kY: Double;
  Bitmap: TBitmap;
  Command: AnsiString;
  WidthInBytes: Integer;
  LogoWidth: Integer;
  LogoHeight: Integer;
begin
  Logger.Debug('TDaisyPrinter.LoadLogo');

  Result := 0;
  if Logo.Width = 0 then
    raise Exception.Create('Logo width 0');
  if Logo.Height = 0 then
    raise Exception.Create('Logo height 0');

  LogoHeight := Logo.Height;
  if LogoHeight > FConstants.MaxLogoHeight then
  begin
    LogoHeight := FConstants.MaxLogoHeight;
    kY := Logo.Height / FConstants.MaxLogoHeight;
    LogoWidth := Round(Logo.Width/kY);
  end else
  begin
    LogoWidth := Logo.Width;
    if LogoWidth > FConstants.MaxLogoWidth then
      LogoWidth := FConstants.MaxLogoWidth;
  end;
  P.X := (FConstants.MaxLogoWidth - LogoWidth) div 2;
  P.X := (P.X div 8) * 8;
  LogoWidth := (LogoWidth div 8) * 8;
  P.Y := 0;
  WidthInBytes := (P.X + LogoWidth) div 8;

  Bitmap := TBitmap.Create;
  try
    Bitmap.Monochrome := True;
    Bitmap.PixelFormat := pf1Bit;
    Bitmap.Width := P.X + LogoWidth;
    Bitmap.Height := LogoHeight;
    Bitmap.Canvas.StretchDraw(Rect(P.X, P.Y, P.X + LogoWidth, P.Y + LogoHeight), Logo);

    for i := 0 to Bitmap.Height-1 do
    begin
      Command := '';
      for j := 0 to WidthInBytes-1 do
      begin
        B := PByteArray(Bitmap.ScanLine[i])[j];
        B := B xor $FF;
        Command := Command + IntToHex(B, 2);
      end;
      Command := #$73 + Format('%d,%s', [i, Command]);
      Result := Send(Command);
      if Failed(Result) then Break;
    end;
  finally
    Bitmap.Free;
  end;
  if Succeeded(Result) then
  begin
    Result := WriteParameter(DFP_SP_TRAILER_LOGO, IntToStr(LogoHeight));
  end;
end;

function TDaisyPrinter.PrintBarcode(const Data: AnsiString): Integer;
begin
  Logger.Debug('TDaisyPrinter.PrintBarcode');
  Result := Send(#$54 + Data);
end;

// Type,Data[<TAB>Pos[,Scale[,Height[,PrnText]]]]
function TDaisyPrinter.PrintBarcode2(const Barcode: TDFPBarcode): Integer;
var
  Command: AnsiString;
const
  Position = 'CRL';
begin
  Logger.Debug('TDaisyPrinter.PrintBarcode2');
  if (Barcode.BType < DFP_BT_MIN) or (Barcode.BType > DFP_BT_MAX) then
    raise Exception.CreateFmt('Invalid barcode type, %d', [Barcode.BType]);

  if (Barcode.Position < DFP_BP_MIN) or (Barcode.Position > DFP_BP_MAX) then
    raise Exception.CreateFmt('Invalid barcode position, %d', [Barcode.Position]);

  Command := Format('%d,%s%s,%d,%d,%s', [Barcode.BType, Barcode.Data + TAB,
    Position[Barcode.Position], Barcode.Scale, Barcode.Heightmm,
    BoolToStr[Barcode.Text]]);

  Result := Send(#$54 + Command);
end;

function TDaisyPrinter.PrintCash(const P: TDFPCashRequest; var R: TDFPCashResponse): Integer;
var
  Code: AnsiString;
  Answer: AnsiString;
  Command: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.PrintCash');
  Command := #$46 + AmountToStr(P.Amount);
  if P.Text1 <> '' then
  begin
    Command := Command + ',' + EncodePrinterText(P.Text1);
    if P.Text2 <> '' then
    begin
      Command := Command + LF + EncodePrinterText(P.Text2);
    end;
    Command := Command + TAB;
  end;
  Result := Send(Command, Answer);
  if Succeeded(Result) then
  begin
    Code := GetStrParam(Answer, 1);
    if Code <> 'P' then
    begin
      Result := ECommandFailed;
      Exit;
    end;
    R.CashAmount := GetDblParam(Answer, 2);
    R.CashInAmount := GetDblParam(Answer, 3);
    R.CashOutAmount := GetDblParam(Answer, 4);
  end;
end;

function TDaisyPrinter.DuplicatePrint(Count, DocNo: Integer): Integer;
var
  Command: AnsiString;
begin
  Logger.Debug(Format('TDaisyPrinter.DuplicatePrint(%d,%d)', [Count, DocNo]));
  Command := #$6D;
  if Count <> 0 then
    Command := Command + IntToStr(Count);
  if DocNo <> 0 then
    Command := Command + ',' + IntToStr(DocNo);
  Result := Send(Command);
end;

(*

112 (70h) INFORMATION ABOUT OPERATORS
Data field: Operator
Reply: Receipts,Total,Discount,Surcharge,Void,Name
Operator Indicating operator number from 1 to #OPER_MAX_CNT#.
Receipts Indicating number of fiscal receipts which were issued by a certain operator.
Total Indicating number of sales and total sum divided by �;�.
Discount Number of discounts and total amount of discounts ,divided by �;�.
Surcharge Number of surcharges and total amount of surcharges ,divided by �;�.
Void Number of corrections and total amount, divided by �;�.
Name Operator name.
*)

// 000000,000000;0.00,000000;0.00,000000;0.00,000000;0.00,?????? 01

function TDaisyPrinter.ReadOperator(N: Integer; var R: TDFPOperator): Integer;
var
  Answer: AnsiString;
const
  Separators: TSetOfChar = [',',';'];
begin
  Logger.Debug(Format('TDaisyPrinter.ReadOperator((%d)', [N]));
  Result := Send(#$70 + IntToStr(N), Answer);
  if Succeeded(Result) then
  begin
    R.Number := N;
    R.NumReceipts := GetIntParam(Answer, 1);
    R.TotalNum := GetInteger(Answer, 2, Separators);
    R.TotalAmount := StrToDouble(GetString(Answer, 3, Separators));
    R.DiscountNum := GetInteger(Answer, 4, Separators);
    R.DiscountAmount := StrToDouble(GetString(Answer, 5, Separators));
    R.SurchargeNum := GetInteger(Answer, 6, Separators);
    R.SurchargeAmount := StrToDouble(GetString(Answer, 7, Separators));
    R.VoidNum := GetInteger(Answer, 8, Separators);
    R.VoidAmount := StrToDouble(GetString(Answer, 9, Separators));
    R.Name := DecodePrinterText(GetString(Answer, 10, Separators));
  end;
end;

function TDaisyPrinter.WriteOperatorName(const P: TDFPOperatorName): Integer;
begin
  Logger.Debug('TDaisyPrinter.WriteOperatorName');
  Result := Send(#$66 + Format('%d,%.4d,%s', [
    P.Number, P.Password, EncodePrinterText(P.Name)]));
end;

function TDaisyPrinter.WritePrinterNumber(N: Integer): Integer;
begin
  if not (N in [1..99]) then
    raise Exception.CreateFmt('Invalid printer number, %d', [N]);

  Result := WriteParameter(DFP_SP_PRINTER_NUMBER, IntToStr(N));
end;

///////////////////////////////////////////////////////////////////////////////
// 103 (67h) INFORMATION INCLUDED IN THE RECEIPT
// Data field: No data
// Reply: CanVoid,TaxFree,Tax1,Tax2,Tax3,Tax4,Tax5,InvoiceFlag,InvoiceNo

function TDaisyPrinter.ReadReceiptStatus(var R: TDFPReceiptStatus): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadReceiptStatus');
  Result := Send(#$67, Answer);
  if Succeeded(Result) then
  begin
    R.CanVoid := GetIntParam(Answer, 1) <> 0;
    R.TaxFreeTotal := GetIntParam(Answer, 2)/100;
    R.Tax1Total := GetIntParam(Answer, 3)/100;
    R.Tax2Total := GetIntParam(Answer, 4)/100;
    R.Tax3Total := GetIntParam(Answer, 5)/100;
    R.Tax4Total := GetIntParam(Answer, 6)/100;
    R.Tax5Total := GetIntParam(Answer, 7)/100;
    R.InvoiceFlag := GetIntParam(Answer, 8) <> 0;
    R.InvoiceNo := GetStrParam(Answer, 9);
  end;
end;

function TDaisyPrinter.ReadDayStatus(var R: TDFPDayStatus): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadDayStatus');
  Result := Send(#$6E'A', Answer);
  if Succeeded(Result) then
  begin
    R.CashTotal := GetIntParam(Answer, 1)/100;
    R.Pay1Total := GetIntParam(Answer, 2)/100;
    R.Pay2Total := GetIntParam(Answer, 3)/100;
    R.Pay3Total := GetIntParam(Answer, 4)/100;
    R.Pay4Total := GetIntParam(Answer, 5)/100;
    R.ZRepNo := GetIntParam(Answer, 6);
    R.DocNo := GetIntParam(Answer, 7);
    R.InvoiceNo := GetIntParam(Answer, 8);
  end;
end;

function TDaisyPrinter.ReadLastDocNo(var DocNo: Integer): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.ReadLastDocNo');
  Result := Send(#$71, Answer);
  if Succeeded(Result) then
  begin
    DocNo := GetIntParam(Answer, 1);
  end;
end;

function TDaisyPrinter.WriteFiscalNumber(
  const FiscalNumber: AnsiString): Integer;
var
  Answer: AnsiString;
begin
  Logger.Debug('TDaisyPrinter.WriteFiscalNumber');
  Result := Send(#$5C + FiscalNumber, Answer);
  if Succeeded(Result) then
  begin
    if Answer <> 'P' then
      Result := ECommandFailed;
  end;
end;

function TDaisyPrinter.SearchDevice: Integer;
begin
  { !!! }
  Result := 0;
end;

end.
